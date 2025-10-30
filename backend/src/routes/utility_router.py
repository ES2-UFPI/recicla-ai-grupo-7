from fastapi import Depends, status, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from src.utils import token_providers
from src.database.repository import user_repo
from src.database.connection import get_db
from src.models import models

# HTTPBearer é mais moderno que OAuth2PasswordBearer para APIs REST
security = HTTPBearer()


def get_logged_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    session: Session = Depends(get_db)
) -> models.User:
    """
    Dependency para obter o usuário logado a partir do access token
    
    Uso:
        @router.get("/me")
        def get_me(current_user: User = Depends(get_logged_user)):
            return current_user
    """
    token = credentials.credentials  # Extrai o token do header
    
    # Verifica e decodifica o access token
    try:
        user_id = token_providers.verify_access_token(token)
    except HTTPException:
        raise  # Re-lança exceções do verify_access_token
    
    # Busca o usuário no banco
    user = user_repo.User(session).get_user_by_id(user_id)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido: usuário não encontrado"
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido: usuário inativo"
        )
    
    return user


def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> str:
    """
    Dependency mais leve que só retorna o user_id
    Útil quando você não precisa dos dados completos do usuário
    
    Uso:
        @router.get("/my-data")
        def get_my_data(user_id: str = Depends(get_current_user_id)):
            return {"user_id": user_id}
    """
    token = credentials.credentials
    
    try:
        user_id = token_providers.verify_access_token(token)
        return user_id
    except HTTPException:
        raise


def require_role(required_roles: list[str]):
    """
    Dependency factory para verificar se o usuário tem uma role específica
    
    Uso:
        @router.post("/admin-only")
        def admin_endpoint(
            current_user: User = Depends(require_role(["ADMIN"]))
        ):
            return {"message": "Admin access"}
        
        @router.post("/collector-or-coop")
        def collector_endpoint(
            current_user: User = Depends(require_role(["COLETOR", "COOPERATIVA"]))
        ):
            return {"message": "Collector access"}
    """
    def role_checker(current_user: models.User = Depends(get_logged_user)) -> models.User:
        if current_user.role not in required_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Acesso negado. Roles permitidas: {', '.join(required_roles)}"
            )
        return current_user
    
    return role_checker