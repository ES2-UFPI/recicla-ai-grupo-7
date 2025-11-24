import logging
from sqlalchemy.orm import Session
from sqlalchemy import or_
from src.schemas import address_schema as ads
from src.models import models
from datetime import datetime

class AddressRepo:
    def __init__(self, db: Session):
        self.db = db

    def create_address(self, address: ads.Address) -> models.Address:
        try:
            db_address = models.Address(
                street=address.street,
                number=address.number,
                city=address.city,
                state=address.state,
                zipcode=address.zipcode,
                latitude=address.latitude,
                longitude=address.longitude
            )
            self.db.add(db_address)
            self.db.commit()
            self.db.refresh(db_address)
            return db_address
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            raise

    def get_address_by_id(self, address_id: str) -> models.Address | None:
        return self.db.query(models.Address).filter(models.Address.id == address_id).first()