from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from typing import List
from app.database import get_db
from app.schemas import VenueResponse, VenueSearch,VenueCreate
from app.dependencies import get_current_user
from app.models import User,Venue


router = APIRouter(prefix="/venues", tags=["Venues"])
# ==========================================
# ENDPOINT 1: CREATE VENUE (Protected)
# ==========================================
@router.post("/", response_model=VenueResponse, status_code=201)
async def create_venue(
    venue_in: VenueCreate,                     # Pydantic validates this automatically
    db: AsyncSession = Depends(get_db),        # Injects DB Session
    current_user: User = Depends(get_current_user) # Injects Logged-in User
):
    """
    Java Equivalent: @PostMapping + @Valid @RequestBody VenueDTO
    """
    # 1. Business Logic: Convert List[str] -> Comma Separated String for DB
    sports_str = ",".join([s.value for s in venue_in.sports])

    # 2. Create ORM Object
    # Note the special format for PostGIS: "SRID=4326;POINT(lon lat)"
    db_venue = Venue(
        name=venue_in.name,
        address=venue_in.address,
        city=venue_in.city,
        latitude=venue_in.latitude,
        longitude=venue_in.longitude,
        location_geom=f"SRID=4326;POINT({venue_in.longitude} {venue_in.latitude})",
        sports=sports_str,
        has_lights=venue_in.has_lights,
        has_parking=venue_in.has_parking,
        is_free=venue_in.is_free,
        price_per_hour=venue_in.price_per_hour,
    )

    # 3. Save to DB (Async)
    db.add(db_venue)
    await db.commit()
    await db.refresh(db_venue) # Fetches the generated ID

    # 4. Return Response (Pydantic converts ORM -> JSON)
    return db_venue

@router.get("/nearby", response_model=List[VenueResponse])
async def get_nearby_venues(
    lat: float = Query(..., description="User latitude"),
    lon: float = Query(..., description="User longitude"),
    radius_km: float = Query(10.0, description="Search radius"),
    db: AsyncSession = Depends(get_db)
):
    # Using raw SQL with PostGIS ST_DWithin for performance
    # This is much faster than fetching all rows and calculating distance in Python
    query = text("""
        SELECT
            id, name, address, city, latitude, longitude,
            sports, rating,
            ST_Distance(
                location_geom::geography,
                ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography
            ) / 1000.0 as distance_km
        FROM venues
        WHERE ST_DWithin(
            location_geom::geography,
            ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography,
            :radius_meters
        )
        ORDER BY distance_km
        LIMIT 50
    """)

    result = await db.execute(
        query,
        {"lat": lat, "lon": lon, "radius_meters": radius_km * 1000}
    )

    venues = []
    for row in result.mappings():
        venue_dict = dict(row)
        # Convert comma-separated string back to list for the frontend
        venue_dict['sports'] = venue_dict['sports'].split(',') if venue_dict['sports'] else []
        venues.append(VenueResponse(**venue_dict))

    return venues


