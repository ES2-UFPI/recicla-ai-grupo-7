from pydantic import BaseModel,Field, field_validator
from datetime import datetime
from typing import Optional
from sqlalchemy.orm import Mapped, mapped_column


class RecyclableMaterial(BaseModel):
    type: str = Field(..., description="Type of recyclable material", examples=["plastic", "paper", "glass"])
    description: str | None = Field(default=None, description="Description of the recyclable material")

    model_config = {
        "from_attributes": True
    }

class RecyclableMaterialOut(BaseModel):
    id: str
    type: str = Field(..., description="Type of recyclable material", examples=["plastic", "paper", "glass"])
    description: str | None = Field(default=None, description="Description of the recyclable material")

    model_config = {
        "from_attributes": True
    }

class RecyclableMaterialItem(BaseModel):
    material_id: str = Field(..., description="ID of the recyclable material")
    quantity: int = Field(..., gt=0, description="Quantity of the material items")
    weight_kg: float | None = Field(default=None, description="Weight of the material items in kilograms")

    material_type: str | None = Field(
        default=None,
        description="Human readable material type (e.g. 'Papel e Papelão')"
    )

    model_config = {
        "from_attributes": True
    }


class PickupRequest(BaseModel):
    address_id: str
    scheduled_time: datetime
    items: list[RecyclableMaterialItem] = Field(default_factory=list)


    model_config = {
        "from_attributes": True
    }

    
class PickupRequestOut(BaseModel):
    id: str
    producer_id: str
    address_id: str
    scheduled_time: datetime
    items: list[RecyclableMaterialItem] = Field(default_factory=list)

    address_text: str | None = Field(default=None, description="Endereço completo da coleta")

    model_config = {
        "from_attributes": True
    }


class PickupMapItem(BaseModel):
    material_type: str = Field(..., description="Tipo de material")
    quantity: Optional[int] = Field(default=None, description="Quantidade de itens")
    weight_kg: Optional[float] = Field(default=None, description="Peso em kg (estimado)")

class PickupMapPoint(BaseModel):
    id: str
    status: str
    address: str
    latitude: float
    longitude: float
    scheduled_time: Optional[datetime] = None
    items: list[PickupMapItem] = Field(default_factory=list)

    model_config = {
        "from_attributes": True
    }

