from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


def generate_hash(text: str) -> str:
    return pwd_context.hash(text)


def verify_hash(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)
