from fastapi import APIRouter, status, Depends, HTTPException
from fastapi.responses import JSONResponse
from src.database.repository import user_repo, residue_repo, address_repo
from src.routes.utility_router import get_logged_user, require_role
from src.schemas import return_schema, user_schema, residue_schema, address_schema
from sqlalchemy.orm import Session
from src.database.connection import get_db
from src.utils import hash_providers, token_providers


router = APIRouter(prefix="/address", tags=["Endereços"])


@router.post(
    "/register_address",
    response_model=return_schema.ReturnTrue,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar um novo endereço",
    responses={
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
    }
)
def register_address(
    address: address_schema.Address,
    db: Session = Depends(get_db),
    current_user: user_schema.TokenUser = Depends(get_logged_user)
):
    address_created = address_repo.AddressRepo(db).create_address(address)
    
    return JSONResponse(
        status_code=status.HTTP_201_CREATED,
        content=dict(return_schema.ReturnTrue(message="Endereço registrado com sucesso."))
    )