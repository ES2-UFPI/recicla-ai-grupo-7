"""
Seed test data for the database.
"""
from sqlalchemy.orm import Session
from src.models.models import User, Address, RecyclableMaterial
from src.utils.hash_providers import generate_hash
from datetime import datetime


def seed_test_data(session: Session):
    """
    Add test data to the database if it doesn't already exist.
    Idempotent: safe to call multiple times.
    """
    
    # Check if data already exists
    existing_user = session.query(User).filter_by(email="produtor@test.com").first()
    if existing_user:
        print("✅ Test data already seeded. Skipping.")
        return
    
    print("🌱 Seeding test data...")
    
    # Create test produtor user
    produtor = User(
        name="João Produtor",
        email="produtor@test.com",
        password=generate_hash("Senha@123"),
        role="PRODUTOR",
        is_active=True,
    )
    session.add(produtor)
    session.flush()  # Get the ID without committing
    
    # Create address for produtor
    address = Address(
        user_id=produtor.id,
        street="Rua das Flores",
        number="123",
        city="Teresina",
        state="PI",
        zipcode="64000-000",
        latitude=-5.0922,
        longitude=-42.7626,
    )
    session.add(address)
    session.flush()
    
    # Create test coletor user
    coletor = User(
        name="Maria Coletora",
        email="coletor@test.com",
        password=generate_hash("Senha@123"),
        role="COLETOR",
        is_active=True,
    )
    session.add(coletor)
    
    # Create test admin user
    admin = User(
        name="Admin User",
        email="admin@test.com",
        password=generate_hash("Senha@123"),
        role="ADMIN",
        is_active=True,
    )
    session.add(admin)
    session.flush()
    
    # Create test materials
    materials = [
        RecyclableMaterial(type="Plástico", description="Garrafas, sacolas e outros plásticos"),
        RecyclableMaterial(type="Alumínio", description="Latas e outros alumínios"),
        RecyclableMaterial(type="Vidro", description="Garrafas e outros vidros"),
        RecyclableMaterial(type="Papelão", description="Caixas e papelão em geral"),
        RecyclableMaterial(type="Papel", description="Papéis diversos"),
        RecyclableMaterial(type="Metais", description="Metais ferrosos e não-ferrosos"),
    ]
    session.add_all(materials)
    
    # Commit all changes
    session.commit()
    
    print("✅ Test data seeded successfully!")
    print(f"   - Produtor: produtor@test.com / Senha@123")
    print(f"   - Coletor: coletor@test.com / Senha@123")
    print(f"   - Admin: admin@test.com / Senha@123")
    print(f"   - Address ID: {address.id}")
