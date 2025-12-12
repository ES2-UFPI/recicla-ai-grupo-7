from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

import sys
import os

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir))

if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

from src.models.models import Base, User, Address, PickupRequest
from src.database.connection import get_db
from main import app  # seu main.py na raiz do backend

SQLALCHEMY_DATABASE_URL = "sqlite:///./test_recicla_ai_map.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def setup_module(module):
    Base.metadata.create_all(bind=engine)

    db = TestingSessionLocal()

    # cria usuário produtor
    producer = User(
        name="Produtor Teste",
        email="produtor@test.com",
        password="hash",
        role="PRODUTOR",
    )
    db.add(producer)
    db.commit()
    db.refresh(producer)

    # cria endereço com lat/lon
    address = Address(
        user_id=producer.id,
        street="Rua X",
        number="123",
        city="São Paulo",
        state="SP",
        zipcode="00000-000",
        latitude=-23.55948,
        longitude=-46.65889,
    )
    db.add(address)
    db.commit()
    db.refresh(address)

    # cria pickup request
    pickup = PickupRequest(
        producer_id=producer.id,
        address_id=address.id,
        status="PENDENTE",
    )
    db.add(pickup)
    db.commit()
    db.close()


def teardown_module(module):
    Base.metadata.drop_all(bind=engine)


def test_get_map_points_sem_auth():
    response = client.get("/residue/map_points")
