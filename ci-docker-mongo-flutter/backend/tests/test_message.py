from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_get_default_message():
    response = client.get("/message")
    assert response.status_code == 200
    assert "message" in response.json()

def test_post_message():
    new_msg = {"text": "pytest works!"}
    response = client.post("/message", json=new_msg)
    assert response.status_code == 200

    get_response = client.get("/message")
    assert get_response.status_code == 200
    assert get_response.json()["message"] == new_msg["text"]