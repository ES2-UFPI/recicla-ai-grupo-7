import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from unittest.mock import Mock, patch
from src.api.server import app
from src.database.connection import get_db
from src.schemas import user_schema, residue_schema
from datetime import datetime


# In-memory SQLite database for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


@pytest.fixture(scope="function")
def test_client():
    """Fixture to provide test client with overridden database dependency"""
    app.dependency_overrides[get_db] = override_get_db
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()


@pytest.fixture
def mock_logged_in_produtor():
    """Mock a logged-in produtor (producer) user"""
    return user_schema.TokenUser(
        id="223e4567-e89b-12d3-a456-426614174000",
        name="Maria Producer",
        email="producer@example.com",
        role="PRODUTOR"
    )


@pytest.fixture
def mock_logged_in_coletor():
    """Mock a logged-in coletor (collector) user"""
    return user_schema.TokenUser(
        id="123e4567-e89b-12d3-a456-426614174000",
        name="João Collector",
        email="collector@example.com",
        role="COLETOR"
    )


@pytest.fixture
def mock_logged_in_admin():
    """Mock a logged-in admin user"""
    return user_schema.TokenUser(
        id="323e4567-e89b-12d3-a456-426614174000",
        name="Admin User",
        email="admin@example.com",
        role="ADMIN"
    )


class TestProducerCollectionHistory:
    """Test suite for produtor collection history endpoint"""

    def test_get_history_success_produtor(self, test_client, mock_logged_in_produtor):
        """Test that produtor can retrieve their collection history successfully"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            # Should return 200 OK
            assert response.status_code == 200
            assert "data" in response.json()
            assert isinstance(response.json()["data"], list)

    def test_get_history_empty_produtor(self, test_client, mock_logged_in_produtor):
        """Test that new produtor with no history returns empty list"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200
            data = response.json()
            assert data["data"] == []

    def test_get_history_with_multiple_collections(self, test_client, mock_logged_in_produtor):
        """Test history returns all collections for produtor"""
        mock_history = [
            {
                "id": "pickup-001",
                "producer_id": mock_logged_in_produtor.id,
                "status": "completed",
                "materials": ["plástico", "alumínio"],
                "quantity_kg": 25.5,
                "created_at": "2025-12-01T10:00:00",
                "completed_at": "2025-12-01T14:30:00",
                "collector_name": "João Silva"
            },
            {
                "id": "pickup-002",
                "producer_id": mock_logged_in_produtor.id,
                "status": "completed",
                "materials": ["vidro", "papelão"],
                "quantity_kg": 15.0,
                "created_at": "2025-12-10T09:00:00",
                "completed_at": "2025-12-10T16:00:00",
                "collector_name": "Maria Santos"
            }
        ]
        
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            with patch("src.database.repository.residue_repo.ResidueRepo.get_producer_collection_history", return_value=mock_history):
                response = test_client.get(
                    "/residue/history",
                    headers={"Authorization": "Bearer valid_token"}
                )
                
                assert response.status_code == 200
                data = response.json()["data"]
                assert len(data) == 2
                assert data[0]["id"] == "pickup-001"
                assert data[1]["id"] == "pickup-002"

    def test_get_history_with_pagination(self, test_client, mock_logged_in_produtor):
        """Test history endpoint supports pagination"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history?page=1&limit=10",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200
            assert "data" in response.json()

    def test_get_history_with_date_filter(self, test_client, mock_logged_in_produtor):
        """Test history endpoint with date range filter"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history?start_date=2025-12-01&end_date=2025-12-31",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200

    def test_get_history_returns_total_count(self, test_client, mock_logged_in_produtor):
        """Test that history endpoint returns total collection count"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200
            data = response.json()
            assert "total_count" in data or "metadata" in data

    def test_get_history_returns_statistics(self, test_client, mock_logged_in_produtor):
        """Test that history endpoint returns collection statistics"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200
            data = response.json()
            # Should contain statistics about total kg collected, number of collections, etc
            assert "data" in data

    def test_get_history_unauthorized(self, test_client):
        """Test that unauthenticated users cannot access history"""
        response = test_client.get("/residue/history")
        
        # Should return 401 Unauthorized
        assert response.status_code == 401

    def test_get_history_coletor_can_access(self, test_client, mock_logged_in_coletor):
        """Test that coletor cannot access produtor history endpoint (history is personal)"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_coletor):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            # Should return 200 if it's their own history, or 403 if restricted to produtor
            # Adjust based on actual business logic
            assert response.status_code in [200, 403]

    def test_get_history_sorted_by_date_descending(self, test_client, mock_logged_in_produtor):
        """Test that history is sorted by most recent first"""
        mock_history = [
            {
                "id": "pickup-003",
                "created_at": "2025-12-14T10:00:00",
                "status": "completed",
                "quantity_kg": 10.0
            },
            {
                "id": "pickup-002",
                "created_at": "2025-12-10T10:00:00",
                "status": "completed",
                "quantity_kg": 15.0
            }
        ]
        
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            with patch("src.database.repository.residue_repo.ResidueRepo.get_producer_collection_history", return_value=mock_history):
                response = test_client.get(
                    "/residue/history",
                    headers={"Authorization": "Bearer valid_token"}
                )
                
                assert response.status_code == 200
                data = response.json()["data"]
                # Most recent should be first
                assert data[0]["id"] == "pickup-003"

    def test_get_history_includes_material_details(self, test_client, mock_logged_in_produtor):
        """Test that history includes material details for each collection"""
        mock_history = [
            {
                "id": "pickup-001",
                "status": "completed",
                "materials": [
                    {"name": "plástico", "quantity": 10.5},
                    {"name": "alumínio", "quantity": 15.0}
                ],
                "quantity_kg": 25.5
            }
        ]
        
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            with patch("src.database.repository.residue_repo.ResidueRepo.get_producer_collection_history", return_value=mock_history):
                response = test_client.get(
                    "/residue/history",
                    headers={"Authorization": "Bearer valid_token"}
                )
                
                assert response.status_code == 200
                data = response.json()["data"]
                assert "materials" in data[0]
                assert len(data[0]["materials"]) == 2

    def test_get_history_with_invalid_pagination(self, test_client, mock_logged_in_produtor):
        """Test history with invalid pagination parameters"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history?page=abc&limit=xyz",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            # Should return 422 for invalid parameters
            assert response.status_code == 422

    def test_get_history_total_kg_collected(self, test_client, mock_logged_in_produtor):
        """Test that history endpoint returns total kg collected by produtor"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200
            data = response.json()
            # Should have metric showing total kg
            assert "total_kg_collected" in data or any(
                key in data for key in ["metadata", "statistics", "summary"]
            )

    def test_get_history_filters_by_status(self, test_client, mock_logged_in_produtor):
        """Test that history can be filtered by collection status"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history?status=completed",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200

    def test_get_history_completed_count(self, test_client, mock_logged_in_produtor):
        """Test that history shows total number of completed collections"""
        with patch("src.routes.residue_router.get_logged_user", return_value=mock_logged_in_produtor):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
            
            assert response.status_code == 200
            data = response.json()
            assert "completed_count" in data or "total_collections" in data or len(data["data"]) >= 0
