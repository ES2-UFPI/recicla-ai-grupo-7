import logging
from sqlalchemy.orm import Session
from sqlalchemy import or_
from src.schemas import residue_schema as prs
from src.models import models
from datetime import datetime


class ResidueRepo:
    def __init__(self, db: Session):
        self.db = db
        

    def register_recyclable_material(self, material: prs.RecyclableMaterial) -> models.RecyclableMaterial:
        try:
            db_material = models.RecyclableMaterial(
                type=material.type,
                description=material.description
            )
            self.db.add(db_material)
            self.db.commit()
            self.db.refresh(db_material)
            return db_material
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            raise
    
    def get_all_recyclable_materials(self) -> list[models.RecyclableMaterial]:
        return self.db.query(models.RecyclableMaterial).all()

    def create_pickup_request(self, pickup_request: prs.PickupRequest, producer_id: str) -> models.PickupRequest:
        try:
            db_pickup_request = models.PickupRequest(
                producer_id=producer_id,
                address_id=pickup_request.address_id,
                scheduled_time=pickup_request.scheduled_time,
                status="PENDENTE"
            )
            self.db.add(db_pickup_request)
            self.db.flush()  # To get the ID before committing

            pickup_id = db_pickup_request.id  

            for item in pickup_request.items:
                db_item = models.PickupRequestItem(
                    request_id=pickup_id,
                    material_id=item.material_id,
                    quantity=item.quantity,
                    weight_kg=item.weight_kg
                )
                self.db.add(db_item)

            self.db.commit()
            self.db.refresh(db_pickup_request)

            return db_pickup_request
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            raise

    def get_pickup_requests_by_producer(self, producer_id: str) -> list[models.PickupRequest]:
        try:
            return self.db.query(models.PickupRequest).filter(models.PickupRequest.producer_id == producer_id).all()
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            raise

    def get_pickup_request_items(self, pickup_request_id: str) -> list[models.PickupRequestItem]:
        try:
            return self.db.query(models.PickupRequestItem).filter(models.PickupRequestItem.request_id == pickup_request_id).all()
        except Exception as error:
            logging.error(f"Error: {error}")
            self.db.rollback()
            raise
