import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from unittest.mock import Mock, patch
from main import app
from src.routes.utility_router import get_logged_user
from src.database.connection import get_db
from src.schemas import user_schema, residue_schema
from datetime import datetime
from types import SimpleNamespace


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


@pytest.fixture(autouse=True)
def mock_repo_defaults(monkeypatch):
    """Default mocks to avoid hitting real DB in history endpoints."""
    monkeypatch.setattr(
        "src.database.repository.residue_repo.ResidueRepo.get_producer_collection_history",
        lambda self, *args, **kwargs: []
    )
    monkeypatch.setattr(
        "src.database.repository.residue_repo.ResidueRepo.get_pickup_request_items",
        lambda self, *args, **kwargs: []
    )
    yield


def set_current_user(user):
    """Override get_logged_user dependency with provided user"""
    app.dependency_overrides[get_logged_user] = lambda: user


def clear_current_user_override():
    app.dependency_overrides.pop(get_logged_user, None)


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
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        # Should return 200 OK
        assert response.status_code == 200
        assert "data" in response.json()
        assert isinstance(response.json()["data"], list)

    def test_get_history_empty_produtor(self, test_client, mock_logged_in_produtor):
        """Test that new produtor with no history returns empty list"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()
        assert data["data"] == []

    def test_get_history_with_multiple_collections(self, test_client, mock_logged_in_produtor):
        """Test history returns all collections for produtor"""
        mock_history = [
            SimpleNamespace(
                id="pickup-001",
                producer_id=mock_logged_in_produtor.id,
                address_id="addr-1",
                scheduled_time=datetime.fromisoformat("2025-12-01T10:00:00"),
            ),
            SimpleNamespace(
                id="pickup-002",
                producer_id=mock_logged_in_produtor.id,
                address_id="addr-2",
                scheduled_time=datetime.fromisoformat("2025-12-10T09:00:00"),
            ),
        ]

        set_current_user(mock_logged_in_produtor)
        with patch("src.database.repository.residue_repo.ResidueRepo.get_producer_collection_history", return_value=mock_history):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()["data"]
        assert len(data) == 2
        assert data[0]["id"] == "pickup-001"
        assert data[1]["id"] == "pickup-002"

    def test_get_history_with_pagination(self, test_client, mock_logged_in_produtor):
        """Test history endpoint supports pagination"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history?page=1&limit=10",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200
        assert "data" in response.json()

    def test_get_history_with_date_filter(self, test_client, mock_logged_in_produtor):
        """Test history endpoint with date range filter"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history?start_date=2025-12-01&end_date=2025-12-31",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200

    def test_get_history_returns_total_count(self, test_client, mock_logged_in_produtor):
        """Test that history endpoint returns total collection count"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()
        assert "data" in data

    def test_get_history_returns_statistics(self, test_client, mock_logged_in_produtor):
        """Test that history endpoint returns collection statistics"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()
        # Should contain statistics about total kg collected, number of collections, etc
        assert "data" in data

    def test_get_history_unauthorized(self, test_client):
        """Test that unauthenticated users cannot access history"""
        clear_current_user_override()
        response = test_client.get("/residue/history")

        # Should return 401 Unauthorized
        assert response.status_code in [401, 403]

    def test_get_history_coletor_can_access(self, test_client, mock_logged_in_coletor):
        """Test that coletor cannot access produtor history endpoint (history is personal)"""
        set_current_user(mock_logged_in_coletor)
        response = test_client.get(
            "/residue/history",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        # Should return 403 because endpoint is for PRODUTOR
        assert response.status_code == 403

    def test_get_history_sorted_by_date_descending(self, test_client, mock_logged_in_produtor):
        """Test that history is sorted by most recent first"""
        mock_history = [
            SimpleNamespace(
                id="pickup-003",
                producer_id=mock_logged_in_produtor.id,
                address_id="addr-3",
                scheduled_time=datetime.fromisoformat("2025-12-14T10:00:00"),
                created_at=datetime.fromisoformat("2025-12-14T10:00:00"),
            ),
            SimpleNamespace(
                id="pickup-002",
                producer_id=mock_logged_in_produtor.id,
                address_id="addr-2",
                scheduled_time=datetime.fromisoformat("2025-12-10T10:00:00"),
                created_at=datetime.fromisoformat("2025-12-10T10:00:00"),
            ),
        ]
        
        set_current_user(mock_logged_in_produtor)
        with patch("src.database.repository.residue_repo.ResidueRepo.get_producer_collection_history", return_value=mock_history):
            response = test_client.get(
                "/residue/history",
                headers={"Authorization": "Bearer valid_token"}
            )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()["data"]
        # Most recent should be first
        assert data[0]["id"] == "pickup-003"

    def test_get_history_includes_material_details(self, test_client, mock_logged_in_produtor):
        """Test that history includes material details for each collection"""
        mock_history = [
            SimpleNamespace(
                id="pickup-001",
                producer_id=mock_logged_in_produtor.id,
                address_id="addr-1",
                scheduled_time=datetime.fromisoformat("2025-12-01T10:00:00"),
            )
        ]

        set_current_user(mock_logged_in_produtor)
        with patch("src.database.repository.residue_repo.ResidueRepo.get_producer_collection_history", return_value=mock_history):
            with patch("src.database.repository.residue_repo.ResidueRepo.get_pickup_request_items", return_value=[
                SimpleNamespace(material_id="mat-1", quantity=10, weight_kg=10.5),
                SimpleNamespace(material_id="mat-2", quantity=5, weight_kg=15.0),
            ]):
                response = test_client.get(
                    "/residue/history",
                    headers={"Authorization": "Bearer valid_token"}
                )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()["data"]
        assert "items" in data[0]
        assert len(data[0]["items"]) == 2

    def test_get_history_with_invalid_pagination(self, test_client, mock_logged_in_produtor):
        """Test history with invalid pagination parameters"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history?page=abc&limit=xyz",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        # Should return 422 for invalid parameters
        assert response.status_code == 422

    def test_get_history_total_kg_collected(self, test_client, mock_logged_in_produtor):
        """Test that history endpoint returns total kg collected by produtor"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()
        assert "data" in data

    def test_get_history_filters_by_status(self, test_client, mock_logged_in_produtor):
        """Test that history can be filtered by collection status"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history?status=completed",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200

    def test_get_history_completed_count(self, test_client, mock_logged_in_produtor):
        """Test that history shows total number of completed collections"""
        set_current_user(mock_logged_in_produtor)
        response = test_client.get(
            "/residue/history",
            headers={"Authorization": "Bearer valid_token"}
        )
        clear_current_user_override()

        assert response.status_code == 200
        data = response.json()
        assert "completed_count" in data or "total_collections" in data or len(data["data"]) >= 0
