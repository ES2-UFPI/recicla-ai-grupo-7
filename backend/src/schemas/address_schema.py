from pydantic import BaseModel,Field, field_validator
from datetime import datetime

class Address(BaseModel):
    street: str = Field(..., description="The street name", examples=["Av. Paulista"])
    number: str = Field(..., description="The street number", examples=["100"])
    city: str = Field(..., description="The city name", examples=["São Paulo"])
    state: str = Field(..., description="The state name", examples=["SP"])
    zipcode: str = Field(..., description="The ZIP code", examples=["01311000"])
    latitude: float = Field(..., description="The latitude coordinate", examples=[-23.5505])
    longitude: float = Field(..., description="The longitude coordinate", examples=[-46.6333])

    @field_validator("zipcode")
    def validate_zipcode(cls, value):
        if not value.isdigit() or len(value) != 8:
            raise ValueError("Invalid ZIP code")
        return value
    
    model_config = {
        "from_attributes": True
    }

class AddressCoordinates(BaseModel):
    latitude: float = Field(..., description="The latitude coordinate")
    longitude: float = Field(..., description="The longitude coordinate")

    model_config = {
        "from_attributes": True
    }
