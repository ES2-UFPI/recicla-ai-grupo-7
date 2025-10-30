from pydantic import BaseModel
from typing import Generic, TypeVar, Literal

T = TypeVar("T")

class ReturnTrue(BaseModel,Generic[T]):
    success: bool = True

    errors: Literal[None] = None

    data: Literal[None] = None
 

    
 

class ReturnError(BaseModel,Generic[T]):
    success: bool = False
 
    errors: list[T]
 
    data: Literal[None] = None
 

    
 

class ReturnTrueData(BaseModel,Generic[T]):
    success: bool = True
 
    errors: Literal[None] = None
 
    data: T