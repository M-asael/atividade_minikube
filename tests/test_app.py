from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

def test_healthz():
    r = client.get("/healthz")
    assert r.status_code == 200 and r.json()["status"] == "ok"

def test_list_quotes():
    r = client.get("/quotes")
    assert r.status_code == 200
    assert isinstance(r.json(), list) and len(r.json()) >= 1
