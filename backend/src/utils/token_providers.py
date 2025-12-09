from datetime import datetime, timedelta
import hashlib
import logging
from fastapi import HTTPException
from jose import JWTError, jwt
import os
from dotenv import load_dotenv
from typing import Any

from src.utils import hash_providers

# config

load_dotenv()
_SECRET_KEY_ENV = os.getenv("SECRET_KEY")

# Garante em tempo de execução que é uma string válida
if not _SECRET_KEY_ENV:
    raise RuntimeError("SECRET_KEY não configurada. Defina SECRET_KEY no arquivo .env.")

# A partir daqui, para o Pylance, SECRET_KEY é sempre str (sem None)
SECRET_KEY: str = _SECRET_KEY_ENV

ALGORITHM: str = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
REFRESH_TOKEN_EXPIRE_DAYS: int = 7


def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    token_jwt: str = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return token_jwt


def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    token_jwt: str = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return token_jwt


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
    try:
        payload: dict[str, Any] = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        raise HTTPException(status_code=401, detail="Token inválido.")

    sub = payload.get("sub")
    if not isinstance(sub, str):
        raise HTTPException(status_code=401, detail="Token inválido.")

    return sub  # aqui o tipo já é str


def verify_refresh_token(token: str) -> str:
    try:
        payload: dict[str, Any] = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        raise HTTPException(status_code=401, detail="Token inválido.")

    sub = payload.get("sub")
    if not isinstance(sub, str):
        raise HTTPException(status_code=401, detail="Token inválido.")

    return sub
    
def decode_token(token: str) -> dict:
    """
    Decodifica um token sem validar (para debug)
    """
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError as e:
        logging.error(f"Erro ao decodificar token: {e}")
        return {}