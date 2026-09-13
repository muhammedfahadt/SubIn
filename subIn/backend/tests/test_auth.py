# tests/test_auth.py
import pytest

@pytest.mark.anyio
async def test_login_returns_jwt(client, test_user):
    resp = await client.post("/auth/login", json={
        "email": test_user.email, "password": "correct-password"
    })
    assert resp.status_code == 200
    assert "access_token" in resp.json()

@pytest.mark.anyio
async def test_protected_route_rejects_missing_token(client):
    resp = await client.get("/venues/me")
    assert resp.status_code == 401

@pytest.mark.anyio
async def test_expired_token_rejected(client, expired_jwt):
    resp = await client.get("/venues/me", headers={"Authorization": f"Bearer {expired_jwt}"})
    assert resp.status_code == 401