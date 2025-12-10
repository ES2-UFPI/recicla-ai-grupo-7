import logging
from sqlalchemy.orm import Session, joinedload
from src.schemas import residue_schema as prs
from src.models import models
from typing import cast
from datetime import datetime

class ResidueRepo:
    def __init__(self, db: Session):
        self.db = db

    def register_recyclable_material(
        self, material: prs.RecyclableMaterial
    ) -> models.RecyclableMaterial:
        try:
            db_material = models.RecyclableMaterial(
                type=material.type,
                description=material.description,
            )
            self.db.add(db_material)
            self.db.commit()
            self.db.refresh(db_material)
            return db_material
        except Exception as error:
            logging.error(f"Error register_recyclable_material: {error}")
            self.db.rollback()
            raise

    def get_all_recyclable_materials(self) -> list[models.RecyclableMaterial]:
        return self.db.query(models.RecyclableMaterial).all()

    def create_pickup_request(
        self, pickup_request: prs.PickupRequest, producer_id: str
    ) -> models.PickupRequest:
        try:
            db_pickup_request = models.PickupRequest(
                producer_id=producer_id,
                address_id=pickup_request.address_id,
                scheduled_time=pickup_request.scheduled_time,
                status="PENDENTE",
            )
            self.db.add(db_pickup_request)
            self.db.flush()  # pega o ID antes do commit

            pickup_id = db_pickup_request.id

            for item in pickup_request.items:
                db_item = models.PickupRequestItem(
                    request_id=pickup_id,
                    material_id=item.material_id,
                    quantity=item.quantity,
                    weight_kg=item.weight_kg,
                )
                self.db.add(db_item)

            self.db.commit()
            self.db.refresh(db_pickup_request)

            return db_pickup_request
        except Exception as error:
            logging.error(f"Error create_pickup_request: {error}")
            self.db.rollback()
            raise

    # 👇 ESSE É O MÉTODO QUE O ROUTER ESTÁ USANDO
    def get_pickup_requests_by_producer(
        self, producer_id: str
    ) -> list[models.PickupRequest]:
        try:
            return (
                self.db.query(models.PickupRequest)
                .filter(models.PickupRequest.producer_id == producer_id)
                .all()
            )
        except Exception as error:
            logging.error(f"Error get_pickup_requests_by_producer: {error}")
            self.db.rollback()
            raise

    def get_pickup_request_items(
        self, pickup_request_id: str
    ) -> list[models.PickupRequestItem]:
        try:
            return (
                self.db.query(models.PickupRequestItem)
                .filter(models.PickupRequestItem.request_id == pickup_request_id)
                .all()
            )
        except Exception as error:
            logging.error(f"Error get_pickup_request_items: {error}")
            self.db.rollback()
            raise

    # 👇 MÉTODO NOVO PARA O MAPA
    def get_pickups_with_location(self) -> list[dict]:
        """
        Retorna todas as coletas que possuem endereço com latitude/longitude,
        já prontas para o mapa.
        """
        try:
            results = (
                self.db.query(models.PickupRequest, models.Address)
                .join(
                    models.Address,
                    models.PickupRequest.address_id == models.Address.id,
                )
                .filter(
                    models.Address.latitude.isnot(None),
                    models.Address.longitude.isnot(None),
                )
                .all()
            )

            points: list[dict] = []

            for pickup, address in results:
                points.append(
                    {
                        "id": pickup.id,
                        "status": pickup.status,
                        "latitude": float(address.latitude),
                        "longitude": float(address.longitude),
                        "address": f"{address.street}, {address.number} - "
                                   f"{address.city}/{address.state}",
                    }
                )

            return points

        except Exception as error:
            logging.error(f"Error get_pickups_with_location: {error}")
            self.db.rollback()
            raise
    
    def get_pickup_points_for_map(self) -> list[prs.PickupMapPoint]:
        """
        Retorna as coletas com endereço geolocalizado para exibição no mapa,
        incluindo materiais, volume e horário.
        """
        try:
            pickups = (
                self.db.query(models.PickupRequest)
                .join(models.Address, models.PickupRequest.address)
                .options(
                    joinedload(models.PickupRequest.address),
                    joinedload(models.PickupRequest.items).joinedload(models.PickupRequestItem.material),
                )
                .filter(
                    models.Address.latitude.isnot(None),
                    models.Address.longitude.isnot(None),
                )
                .all()
            )

            result: list[prs.PickupMapPoint] = []

            for pickup in pickups:
                addr = pickup.address

                address_str = f"{addr.street}, {addr.number} - {addr.city}/{addr.state}"

                items = []
                for item in pickup.items:
                    material_type = item.material.type if item.material else "Desconhecido"

                    item_schema = prs.PickupMapItem(
                        material_type=material_type,
                        quantity=item.quantity,
                        weight_kg=float(item.weight_kg) if item.weight_kg is not None else None,
                    )
                    items.append(item_schema)

                point = prs.PickupMapPoint(
                    id=cast(str, pickup.id),
                    status=cast(str, pickup.status),
                    address=address_str,
                    latitude=float(addr.latitude),
                    longitude=float(addr.longitude),
                    scheduled_time=cast(datetime | None, pickup.scheduled_time),
                    items=items,
                )

                result.append(point)

            return result
        except Exception as error:
            logging.error(f"Error ao buscar pontos para o mapa: {error}")
            self.db.rollback()
            raise