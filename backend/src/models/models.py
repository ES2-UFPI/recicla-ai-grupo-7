from sqlalchemy import (
    Column, Integer, String, Text, DECIMAL, TIMESTAMP, Boolean, 
    SmallInteger, ForeignKey, CheckConstraint
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
import uuid

Base = declarative_base()


def generate_uuid():
    return str(uuid.uuid4())


class User(Base):
    __tablename__ = 'users'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=False)
    password = Column(Text, nullable=False)
    role = Column(String(20), nullable=False)
    is_active = Column(Boolean, default=True)
    refresh_token = Column(String(256), nullable=True)  # Armazena hash do refresh token
    created_at = Column(TIMESTAMP, server_default=func.now())
    
    __table_args__ = (
        CheckConstraint("role IN ('PRODUTOR', 'COLETOR', 'COOPERATIVA', 'ADMIN')", name='check_user_role'),
    )
    
    # Relacionamentos
    addresses = relationship('Address', back_populates='user', cascade='all, delete-orphan')
    pickup_requests = relationship('PickupRequest', foreign_keys='PickupRequest.producer_id', back_populates='producer')
    collections_as_collector = relationship('Collection', foreign_keys='Collection.collector_id', back_populates='collector')
    collections_as_cooperative = relationship('Collection', foreign_keys='Collection.destination_cooperative_id', back_populates='cooperative')
    rewards = relationship('Reward', back_populates='user')
    wallet = relationship('Wallet', back_populates='user', uselist=False)
    reviews_given = relationship('Review', foreign_keys='Review.reviewer_id', back_populates='reviewer')
    reviews_received = relationship('Review', foreign_keys='Review.reviewed_user_id', back_populates='reviewed_user')

class Address(Base):
    __tablename__ = 'addresses'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey('users.id', ondelete='CASCADE'))
    street = Column(String(150))
    number = Column(String(20))
    city = Column(String(100))
    state = Column(String(50))
    zipcode = Column(String(15))
    latitude = Column(DECIMAL(10, 8))
    longitude = Column(DECIMAL(11, 8))
    
    # Relacionamentos
    user = relationship('User', back_populates='addresses')
    pickup_requests = relationship('PickupRequest', back_populates='address')


class RecyclableMaterial(Base):
    __tablename__ = 'recyclable_materials'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    type = Column(String(50), nullable=False)
    description = Column(Text)
    
    # Relacionamentos
    pickup_request_items = relationship('PickupRequestItem', back_populates='material')


class PickupRequest(Base):
    __tablename__ = 'pickup_requests'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    producer_id = Column(String(36), ForeignKey('users.id'))
    address_id = Column(String(36), ForeignKey('addresses.id'))
    scheduled_time = Column(TIMESTAMP)
    status = Column(String(20))
    created_at = Column(TIMESTAMP, server_default=func.now())
    
    __table_args__ = (
        CheckConstraint("status IN ('PENDENTE', 'ACEITA', 'COLETADA', 'ENTREGUE', 'CANCELADA')", name='check_pickup_status'),
    )
    
    # Relacionamentos
    producer = relationship('User', foreign_keys=[producer_id], back_populates='pickup_requests')
    address = relationship('Address', back_populates='pickup_requests')
    items = relationship('PickupRequestItem', back_populates='request', cascade='all, delete-orphan')
    collections = relationship('Collection', back_populates='request')


class PickupRequestItem(Base):
    __tablename__ = 'pickup_request_items'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    request_id = Column(String(36), ForeignKey('pickup_requests.id', ondelete='CASCADE'))
    material_id = Column(String(36), ForeignKey('recyclable_materials.id'))
    weight_kg = Column(DECIMAL(10, 2), default=0)
    quantity = Column(Integer, default=1)
    
    # Relacionamentos
    request = relationship('PickupRequest', back_populates='items')
    material = relationship('RecyclableMaterial', back_populates='pickup_request_items')


class Collection(Base):
    __tablename__ = 'collections'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    request_id = Column(String(36), ForeignKey('pickup_requests.id'))
    collector_id = Column(String(36), ForeignKey('users.id'))
    collected_at = Column(TIMESTAMP)
    delivered_at = Column(TIMESTAMP)
    destination_cooperative_id = Column(String(36), ForeignKey('users.id'))
    
    # Relacionamentos
    request = relationship('PickupRequest', back_populates='collections')
    collector = relationship('User', foreign_keys=[collector_id], back_populates='collections_as_collector')
    cooperative = relationship('User', foreign_keys=[destination_cooperative_id], back_populates='collections_as_cooperative')
    rewards = relationship('Reward', back_populates='collection')


class Reward(Base):
    __tablename__ = 'rewards'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey('users.id'))
    collection_id = Column(String(36), ForeignKey('collections.id'))
    amount = Column(DECIMAL(10, 2), nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
    
    # Relacionamentos
    user = relationship('User', back_populates='rewards')
    collection = relationship('Collection', back_populates='rewards')


class Wallet(Base):
    __tablename__ = 'wallet'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey('users.id'))
    balance = Column(DECIMAL(10, 2), default=0)
    
    # Relacionamentos
    user = relationship('User', back_populates='wallet')
    transactions = relationship('WalletTransaction', back_populates='wallet')


class WalletTransaction(Base):
    __tablename__ = 'wallet_transactions'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    wallet_id = Column(String(36), ForeignKey('wallet.id'))
    amount = Column(DECIMAL(10, 2))
    type = Column(String(20))
    description = Column(Text)
    created_at = Column(TIMESTAMP, server_default=func.now())
    
    __table_args__ = (
        CheckConstraint("type IN ('CREDITO', 'DEBITO')", name='check_transaction_type'),
    )
    
    # Relacionamentos
    wallet = relationship('Wallet', back_populates='transactions')


class Review(Base):
    __tablename__ = 'reviews'
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    reviewer_id = Column(String(36), ForeignKey('users.id'))
    reviewed_user_id = Column(String(36), ForeignKey('users.id'))
    rating = Column(Integer)
    comment = Column(Text)
    created_at = Column(TIMESTAMP, server_default=func.now())
    
    __table_args__ = (
        CheckConstraint('rating BETWEEN 1 AND 5', name='check_rating_range'),
    )
    
    # Relacionamentos
    reviewer = relationship('User', foreign_keys=[reviewer_id], back_populates='reviews_given')
    reviewed_user = relationship('User', foreign_keys=[reviewed_user_id], back_populates='reviews_received')
