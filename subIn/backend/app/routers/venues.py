
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models import User, Venue
from app.schemas import VenueCreate, VenueResponse

router = APIRouter(prefix="/venues", tags=["Venues"])
# ==========================================
# ENDPOINT 1: CREATE VENUE (Protected)
# ==========================================
@router.post("/", response_model=VenueResponse, status_code=201)
async def create_venue(
    venue_in: VenueCreate,                     # Pydantic validates this automatically
    db: Annotated[AsyncSession, Depends(get_db)],        # Injects DB Session
    current_user: Annotated[User, Depends(get_current_user)] # Injects Logged-in User
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
        description=venue_in.description,
        address=venue_in.address,
        city=venue_in.city,
        latitude=venue_in.latitude,
        longitude=venue_in.longitude,
        location_geom=f"SRID=4326;POINT({venue_in.longitude} {venue_in.latitude})",
        sports=sports_str,
        has_lights=venue_in.has_lights,
        has_changing_room=venue_in.has_changing_room,
        has_parking=venue_in.has_parking,
        is_free=venue_in.is_free,
        price_per_hour=venue_in.price_per_hour,
        phone=venue_in.phone,
        website=venue_in.website,
    )

    # 3. Save to DB (Async)
    db.add(db_venue)
    await db.commit()
    await db.refresh(db_venue) # Fetches the generated ID

    # 4. Return Response (Pydantic converts ORM -> JSON)
    return db_venue

@router.get("/nearby", response_model=list[VenueResponse])
async def get_nearby_venues(
    lat: Annotated[float, Query(..., description="User latitude")],
    lon: Annotated[float | None, Query(description="User longitude")] = None,
    lng: Annotated[float | None, Query(description="User longitude (alias)")] = None,
    radius_km: Annotated[float, Query(description="Search radius")] = 10.0,
    *,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    # Accept both ?lon= and ?lng= (frontend/tests use lng, docs use lon)
    lon_val = lon if lon is not None else lng
    if lon_val is None:
        from fastapi import HTTPException
        raise HTTPException(status_code=422, detail="Missing query parameter: 'lon' (or 'lng')")
    # Using raw SQL with PostGIS ST_DWithin for performance
    # This is much faster than fetching all rows and calculating distance in Python
    query = text("""
        SELECT
            id, name, description, address, city, latitude, longitude,
            sports, has_lights, has_changing_room, has_parking,
            is_free, price_per_hour, rating, review_count,
            phone, website, image_urls,
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
        {"lat": lat, "lon": lon_val, "radius_meters": radius_km * 1000}
    )

    venues = []
    for row in result.mappings():
        venue_dict = dict(row)
        # Convert comma-separated strings back to lists for the frontend
        venue_dict['sports'] = venue_dict['sports'].split(',') if venue_dict['sports'] else []
        venue_dict['image_urls'] = venue_dict['image_urls'].split(',') if venue_dict.get('image_urls') else []
        venues.append(VenueResponse(**venue_dict))

    return venues

@router.get("/{venue_id}", response_model=VenueResponse)
async def get_venue(
    venue_id: int,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    from fastapi import HTTPException
    from sqlalchemy import select
    result = await db.execute(select(Venue).where(Venue.id == venue_id))
    venue = result.scalars().first()
    if venue is None:
        raise HTTPException(status_code=404, detail="Venue not found")
    return venue


