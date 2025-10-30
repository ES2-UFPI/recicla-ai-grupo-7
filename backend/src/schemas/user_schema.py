from datetime import datetime
from pydantic import BaseModel,Field, field_validator

class UserSignUp(BaseModel):
    name: str = Field(...,  description="Nome do usuario", example="Jane Doe")
    email: str = Field(...,  description="Email do usuario", example="jane.doe@example.com")
    password: str = Field(...,  description="Senha do usuario", example="strongpassword")
    role: str = Field(..., pattern="^(PRODUTOR|COLETOR|COOPERATIVA|ADMIN)$")

    @field_validator('email')
    def validate_email(cls, email: str): 
        if not email or "@" not in email:
            raise ValueError("Email no formato incorreto")
        return email

    @field_validator("email")
    def normalize_email(cls, email: str): 
        return email.strip().lower()
    
    @field_validator("password")
    def validate_password(cls, password: str): 
        if len(password) < 8:
            raise ValueError("Senha deve ter pelo menos 8 caracteres")
        if not any(char.isdigit() for char in password):
            raise ValueError("Senha deve ter no mínimo 1 número.")
        if not any(char.isupper() for char in password):
            raise ValueError("Senha deve ter no mínimo 1 letra maiúscula.")
        if not any(char in ["!", "@", "#", "$", "%", "&", "*"] for char in password):
            raise ValueError("Senha deve ter no mínimo 1 caractere especial.")
        return password


    model_config = {
        "from_attributes": True
    }

class TokenUser(BaseModel):
    id: str
    name : str
    email: str
    role: str

    model_config = {
        "from_attributes": True
    }

class UserLogin(BaseModel):
    email: str = Field(...,  description="Email do usuario", example="jane.doe@example.com")
    password: str = Field(...,  description="Senha do usuario", example="strongpassword")

    @field_validator("email")
    def validate_email(cls, value: str):
        if "@" not in value:
            raise ValueError("E-mail inválido.")
        return value
    
    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: str):
        return value.strip().lower()

    model_config = {
        "from_attributes": True
    }

class UserOut(BaseModel):
    id: str = Field(..., description="ID do usuário", example="123e4567-e89b-12d3-a456-426614174000")
    name: str = Field(..., description="Nome do usuário", example="Jane Doe")
    email: str = Field(..., description="Email do usuário", example="jane.doe@example.com")
    role: str = Field(..., description="Papel do usuário", example="PRODUTOR")
    is_active: bool = Field(..., description="Status de atividade do usuário", example=True)
    created_at: datetime = Field(..., description="Data de criação do usuário", example=datetime.now())

    model_config = {
        "from_attributes": True
    }

class Token(BaseModel):
    access_token: str = Field(..., description="Token de acesso JWT")
    refresh_token: str = Field(..., description="Token de refresh JWT")
    token_type: str = Field(..., description="Tipo de token", example="Bearer")
    expires_in_minutes: int = Field(..., description="Tempo de expiração do token em minutos", example=60)

class RefreshTokenRequest(BaseModel):
    refresh_token: str = Field(..., description="Token de refresh JWT")

    model_config = {
        "from_attributes": True
    }



class Email(BaseModel):
    email: str = Field(..., description="Endereço de email", example="jane.doe@example.com")

    @field_validator("email")
    def validate_email(cls, value: str):
        if "@" not in value:
            raise ValueError("E-mail inválido.")
        return value.strip().lower()
    
    model_config = {
        "from_attributes": True
    }
