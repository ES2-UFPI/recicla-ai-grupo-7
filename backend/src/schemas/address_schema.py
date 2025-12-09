from pydantic import BaseModel, Field

class AddressBase(BaseModel):
    street: str = Field(..., description="Rua")
    number: str | None = Field(default=None, description="Número")
    city: str = Field(..., description="Cidade")
    state: str = Field(..., description="Estado (UF)")
    zipcode: str | None = Field(default=None, description="CEP")


class AddressCreate(AddressBase):
    latitude: float = Field(..., description="Latitude do endereço")
    longitude: float = Field(..., description="Longitude do endereço")


class AddressOut(AddressBase):
    id: str
    latitude: float | None = None
    longitude: float | None = None

    model_config = {
        "from_attributes": True
    }
