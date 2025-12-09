from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session

from src.database.connection import get_db
from src.database.repository import address_repo
from src.routes.utility_router import get_logged_user
from src.schemas import address_schema, user_schema, return_schema

router = APIRouter(prefix="/address", tags=["Endereços"])


@router.post(
    "/register",
    status_code=status.HTTP_200_OK,
    summary="Cadastrar um endereço do usuário logado",
    response_model=return_schema.ReturnTrueData[address_schema.AddressOut],
    responses={
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
        status.HTTP_403_FORBIDDEN: {"model": return_schema.ReturnError},
    },
)
async def register_address(
    address_in: address_schema.AddressCreate,
    current_user: user_schema.TokenUser = Depends(get_logged_user),
    session: Session = Depends(get_db),
):
    try:
        repo = address_repo.AddressRepo(session)
        address = repo.create_address(current_user.id, address_in)
        address_out = address_schema.AddressOut.model_validate(address)
        return return_schema.ReturnTrueData(data=address_out)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao cadastrar endereço: {str(e)}",
        )


@router.get(
    "/my",
    status_code=status.HTTP_200_OK,
    summary="Listar endereços do usuário logado",
    response_model=return_schema.ReturnTrueData[list[address_schema.AddressOut]],
    responses={
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
        status.HTTP_403_FORBIDDEN: {"model": return_schema.ReturnError},
    },
)
async def get_my_addresses(
    current_user: user_schema.TokenUser = Depends(get_logged_user),
    session: Session = Depends(get_db),
):
    try:
        repo = address_repo.AddressRepo(session)
        addresses = repo.get_user_addresses(current_user.id)
        out = [address_schema.AddressOut.model_validate(a) for a in addresses]
        return return_schema.ReturnTrueData(data=out)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao listar endereços: {str(e)}",
        )
