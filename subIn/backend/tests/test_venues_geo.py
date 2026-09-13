# tests/test_venues_geo.py
import pytest

@pytest.mark.anyio
async def test_venue_search_within_radius(client, auth_headers, seed_venues):
    resp = await client.get(
        "/venues/nearby",
        params={"lat": 12.9716, "lng": 77.5946, "radius_km": 5},
        headers=auth_headers,
    )
    assert resp.status_code == 200
    ids = {v["id"] for v in resp.json()}
    assert seed_venues["in_range"].id in ids
    assert seed_venues["out_of_range"].id not in ids