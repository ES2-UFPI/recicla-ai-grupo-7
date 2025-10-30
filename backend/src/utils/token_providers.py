from datetime import datetime, timedelta
import hashlib
import logging
from fastapi import HTTPException
from jose import JWTError, jwt
import os
from dotenv import load_dotenv

from src.utils import hash_providers

# config

load_dotenv()
api_key = os.getenv("API_KEY")

SECRET_KEY = api_key
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRES_MINUTES = 60  # 1 hora
REFRESH_TOKEN_EXPIRES_DAYS = 7 # 7 dias


def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    """
    Cria um access token JWT de curta duração
    """
    data = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRES_MINUTES)

    data.update({
        "exp": expire,
        "type": "access" # Identifica como access token
        })

    token_jwt = jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

    return token_jwt

def create_refresh_token(data: dict) -> str:
    """
    Cria um refresh token JWT de longa duração
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRES_DAYS)
    
    to_encode.update({
        "exp": expire,
        "type": "refresh"  # Identifica como refresh token
    })
    
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt



def hash_token(token: str) -> str:
    """
    Cria um hash SHA256 do token para armazenamento seguro
    
    Args:
        token: Token JWT em texto plano
        
    Returns:
        Hash SHA256 do token em hexadecimal
    """
    return hash_providers.generate_hash(token)



def verify_access_token(token: str) -> str:
    """
    Verifica e decodifica um access token
    Retorna o user_id (sub) se válido
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        if payload.get("type") != "access":
            raise HTTPException(
                status_code=401, 
                detail="Token inválido: tipo incorreto"
            )
        
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Token inválido")
        
        return user_id
        
    except JWTError as e:
        logging.error(f"Erro ao verificar access token: {e}")
        raise HTTPException(status_code=401, detail="Token inválido ou expirado")

    return user_id

def verify_refresh_token(token: str) -> str:
    """
    Verifica e decodifica um refresh token
    Retorna o user_id (sub) se válido
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # Verifica se é um refresh token
        if payload.get("type") != "refresh":
            raise HTTPException(
                status_code=401, 
                detail="Token inválido: tipo incorreto"
            )
        
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Token inválido")
        
        return user_id
        
    except JWTError as e:
        logging.error(f"Erro ao verificar refresh token: {e}")
        raise HTTPException(status_code=401, detail="Refresh token inválido ou expirado")
    
def decode_token(token: str) -> dict:
    """
    Decodifica um token sem validar (para debug)
    """
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError as e:
        logging.error(f"Erro ao decodificar token: {e}")
        return {}