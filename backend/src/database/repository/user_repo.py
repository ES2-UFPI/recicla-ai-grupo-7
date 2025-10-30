import logging
from sqlalchemy import or_
from sqlalchemy.orm import Session
from src.schemas import user_schema
from src.models import models
import uuid
from datetime import datetime

from src.utils import token_providers
from src.utils import hash_providers

class User:

    def __init__(self, db: Session):
        self.db = db

    def create_user(self, user: user_schema.UserSignUp) -> models.User | None:
        user_exists = (
            self.db.query(models.User).filter(models.User.email == user.email).first()
        )
        if user_exists:
            return None

        try:

            db_user = models.User(
                name=user.name,
                email=user.email,
                password=user.password,
                created_at=datetime.now(),
                is_active=False,
                role=user.role,
            )  

            self.db.add(db_user)
            self.db.commit()
            self.db.refresh(db_user)
            return db_user
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            return None

    def verify_user_id(self, user_id):
        try:
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            return user
        except Exception as error:
            logging.error(f"Error: {error}")
            return None

    def verify_token(self, user_id: str):
        try:
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            return user.is_active
        except Exception as error:
            logging.error(f"Error: {error}")
            return None

    def invalidate_token(self, user_id: str):
        try:
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            user.is_active = False
            self.db.commit()
            return True
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            return None

    def get_user_by_email(self, email: str):
        try:
            user = self.db.query(models.User).filter(models.User.email == email).first()
            return user
        except Exception as error:
            logging.error(f"Error: {error}")
            return None

    def activate_user(self, user_id):
        try:
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            if user:
                user.is_active = True
                self.db.commit()
                self.db.refresh(user)
                return True
            return False
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            return None
        
    def get_user_by_id(self, user_id: str):
        try:
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            return user
        except Exception as error:
            logging.error(f"Error: {error}")
            return None
        
    def save_refresh_token(self, user_id: str, refresh_token: str):
        try:
            user = self.get_user_by_id(user_id)
            if user:
                # ✅ Armazena o HASH do token, não o token em si
                token_hash = token_providers.hash_token(refresh_token)
                user.refresh_token = token_hash
                self.db.commit()
                return True
            return False
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            return None
        
    def verify_refresh_token(self, user_id: str, refresh_token: str) -> bool:
        """
        Verifica se o refresh token do usuário é válido
        
        Compara o hash do token fornecido com o hash armazenado
        """
        try:
            user = self.get_user_by_id(user_id)
            if not user or not user.refresh_token:
                return False
            
            # ✅ Compara os hashes, não os tokens em texto plano
            return hash_providers.verify_hash(refresh_token, user.refresh_token)
        except Exception as error:
            logging.error(f"Error: {error}")
            return False
    

    def revoke_refresh_token(self, user_id: str) -> bool:
        """Remove o refresh token do usuário (logout)"""
        try:
            user = self.get_user_by_id(user_id)
            if user:
                user.refresh_token = None
                self.db.commit()
                return True
            return False
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            return None

    def deactivate_user(self, user_id:str) -> models.User | None:
        try:
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            user.is_active = False
            self.db.commit()
            return user
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            return None

    def change_password(self, user_id, user_password):
        try:
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            user.password = user_password
            self.db.commit()
            return user
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            return None
    
   