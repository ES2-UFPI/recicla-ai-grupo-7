import logging
from sqlalchemy.orm import Session

from src.models import models
from src.schemas import address_schema as sch


class AddressRepo:
    def __init__(self, db: Session):
        self.db = db

    def create_address(self, user_id: str, address_in: sch.AddressCreate) -> models.Address:
        try:
            db_addr = models.Address(
                user_id=user_id,
                street=address_in.street,
                number=address_in.number,
                city=address_in.city,
                state=address_in.state,
                zipcode=address_in.zipcode,
                latitude=address_in.latitude,
                longitude=address_in.longitude,
            )
            self.db.add(db_addr)
            self.db.commit()
            self.db.refresh(db_addr)
            return db_addr
        except Exception as e:
            logging.error(f"Error create_address: {e}")
            self.db.rollback()
            raise

    def get_user_addresses(self, user_id: str) -> list[models.Address]:
        try:
            return (
                self.db.query(models.Address)
                .filter(models.Address.user_id == user_id)
                .all()
            )
        except Exception as e:
            logging.error(f"Error get_user_addresses: {e}")
            self.db.rollback()
            raise

