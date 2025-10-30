from fastapi import APIRouter, status, Depends
from fastapi.responses import JSONResponse
from src.database.repository import user_repo
from src.routes.utility_router import get_logged_user
from src.schemas import return_schema, user_schema
from sqlalchemy.orm import Session
from src.database.connection import get_db
from src.utils import hash_providers, token_providers


router = APIRouter(prefix="/auth", tags=["Autenticação"])


@router.post(
    "/signup",
    status_code=status.HTTP_200_OK,
    summary="Registrar um novo usuário",
    response_model=return_schema.ReturnTrue,
    responses = {
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
    }
)
async def signup(user: user_schema.UserSignUp, session: Session = Depends(get_db)):
    user.password = hash_providers.generate_hash(user.password)
    user_query = user_repo.User(session).create_user(user)
    if not user_query:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content=dict(return_schema.ReturnError(errors=["Usuário já existe."]))
        )
    return return_schema.ReturnTrue(message="Usuário criado com sucesso.")

@router.post(
    "/login",
    status_code=status.HTTP_200_OK,
    summary="Login de usuário",
    response_model=return_schema.ReturnTrueData[user_schema.Token],
    responses = {
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
    }
)
async def login(user: user_schema.UserLogin, session: Session = Depends(get_db)):
    user_query = user_repo.User(session).get_user_by_email(user.email)
    if not user_query:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content=dict(return_schema.ReturnError(errors=["Credenciais inválidas."]))
        )
    if not hash_providers.verify_hash(user.password, user_query.password):
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content=dict(return_schema.ReturnError(errors=["Credenciais inválidas."]))
        )
    access_token = token_providers.create_access_token({"sub": str(user_query.id)})
    refresh_token = token_providers.create_refresh_token({"sub": str(user_query.id)})

    # Armazena o hash do refresh token no banco

    user_repo.User(session).save_refresh_token(user_query.id, refresh_token)
    user_repo.User(session).activate_user(user_query.id)

    return return_schema.ReturnTrueData(
        data=user_schema.Token(access_token=access_token, refresh_token=refresh_token, token_type="Bearer", expires_in_minutes=60),
    )
    
@router.post(
    "/refresh-token",
    status_code=status.HTTP_200_OK,
    summary="Renovar o access token usando o refresh token",
    response_model=return_schema.ReturnTrueData[user_schema.Token],
    responses = {
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
    }
)
async def refresh_token(token_data: user_schema.RefreshTokenRequest, session: Session = Depends(get_db)):
    user_id = token_providers.verify_refresh_token(token_data.refresh_token)

    if not user_repo.User(session).verify_refresh_token(user_id, token_data.refresh_token):
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content=dict(return_schema.ReturnError(errors=["Refresh token inválido."]))
        )
    
    user = user_repo.User(session).get_user_by_id(user_id)
    if not user or not user.is_active:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content=dict(return_schema.ReturnError(errors=["Usuário inválido ou inativo."]))
        )
    access_token = token_providers.create_access_token({"sub": str(user.id)})
    refresh_token = token_providers.create_refresh_token({"sub": str(user.id)})

    user_repo.User(session).save_refresh_token(user.id, refresh_token)

    return return_schema.ReturnTrueData(
        data=user_schema.Token(access_token=access_token, refresh_token=refresh_token, token_type="Bearer", expires_in_minutes=60),
        message="Token renovado com sucesso."
    )

@router.get(
    "/me",
    status_code=status.HTTP_200_OK,
    summary="Obter informações do usuário autenticado",
    response_model=return_schema.ReturnTrueData[user_schema.UserOut],
    responses={
        status.HTTP_401_UNAUTHORIZED: {"model": return_schema.ReturnError},
    }
)
async def get_me(session: Session = Depends(get_db), user: user_schema.UserOut = Depends(get_logged_user)):
    return return_schema.ReturnTrueData(
        data=user
    )

@router.post(
    "/logout",
    status_code=status.HTTP_200_OK,
    summary="Logout do usuário autenticado",
    response_model=return_schema.ReturnTrue,
    responses={
        status.HTTP_401_UNAUTHORIZED: {"model": return_schema.ReturnError},
    }
)
async def logout(session: Session = Depends(get_db), user: user_schema.UserOut = Depends(get_logged_user)):
    user_repo.User(session).deactivate_user(user.id)
    return return_schema.ReturnTrue(message="Logout realizado com sucesso.")