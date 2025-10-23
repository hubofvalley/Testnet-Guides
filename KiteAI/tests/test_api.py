import os
import pytest
from api.app import create_app

@pytest.fixture
def app():
    # Ensure test environment
    os.environ["KITEAI_ENV"] = "test"
    # Point to a non-existent model to exercise readiness probe
    os.environ["KITEAI_MODEL_PATH"] = "./nonexistent-model.pt"
    os.environ["KITEAI_API_PORT"] = "8000"
    app = create_app()
    return app

@pytest.fixture
def client(app):
    return app.test_client()

def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data.get("status") == "ok"

def test_ready_without_model(client):
    resp = client.get("/ready")
    assert resp.status_code == 200
    data = resp.get_json()
    # model does not exist in this test
    assert data.get("ready") is False

def test_predict_empty_text(client):
    resp = client.post("/predict", json={})
    assert resp.status_code == 200
    data = resp.get_json()
    assert "prediction" in data
    assert data["prediction"]["length"] == 0