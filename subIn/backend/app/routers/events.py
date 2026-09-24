from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text, and_
from typing import List, Optional
from datetime import datetime
from app.database import get_db
from app.models import Event, EventParticipant, User, Venue
from app.schemas import EventCreate, EventResponse
from app.dependencies import get_current_user

router = APIRouter(prefix="/events", tags=["Events"])

@router.post("/", response_model=EventResponse, status_code=201)
async def create_event(
    event_data: EventCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new event"""
    
    # Validate: Either venue_id OR custom coordinates must be provided
    if not event_data.venue_id and not (event_data.latitude and event_data.longitude):
        raise HTTPException(
            status_code=400,
            detail="Either venue_id or custom coordinates (latitude/longitude) must be provided"
        )
    
    # Get location data
    latitude = event_data.latitude
    longitude = event_data.longitude
    location_geom = None
    
    if event_data.venue_id:
        # Fetch venue to get coordinates
        result = await db.execute(select(Venue).where(Venue.id == event_data.venue_id))
        venue = result.scalar_one_or_none()
        if not venue:
            raise HTTPException(status_code=404, detail="Venue not found")
        
        latitude = venue.latitude
        longitude = venue.longitude
        location_geom = f"SRID=4326;POINT({longitude} {latitude})"
    else:
        # Use custom coordinates
        location_geom = f"SRID=4326;POINT({longitude} {latitude})"
    
    # Create event
    db_event = Event(
        title=event_data.title,
        description=event_data.description,
        sport=event_data.sport.value,
        venue_id=event_data.venue_id,
        custom_location=event_data.custom_location,
        latitude=latitude,
        longitude=longitude,
        location_geom=location_geom,
        start_time=event_data.start_time,
        end_time=event_data.end_time,
        max_players=event_data.max_players,
        min_players=event_data.min_players,
        current_players=1,  # Organizer counts as 1
        is_free=event_data.is_free,
        cost_per_player=event_data.cost_per_player,
        status="open",
        skill_level=event_data.skill_level.value,
        is_public=event_data.is_public,
        organizer_id=current_user.id,
    )
    
    db.add(db_event)
    await db.flush()  # Get the event ID
    
    # Add organizer as first participant
    participant = EventParticipant(
        event_id=db_event.id,
        user_id=current_user.id,
        status="joined"
    )
    db.add(participant)
    await db.commit()
    await db.refresh(db_event)
    
    # Build response
    response_data = {
        "id": db_event.id,
        "title": db_event.title,
        "description": db_event.description,
        "sport": db_event.sport,
        "venue_id": db_event.venue_id,
        "custom_location": db_event.custom_location,
        "latitude": db_event.latitude,
        "longitude": db_event.longitude,
        "start_time": db_event.start_time,
        "end_time": db_event.end_time,
        "max_players": db_event.max_players,
        "min_players": db_event.min_players,
        "current_players": db_event.current_players,
        "is_free": db_event.is_free,
        "cost_per_player": db_event.cost_per_player,
        "status": db_event.status, 
        "skill_level": db_event.skill_level,
        "is_public": db_event.is_public,
        "organizer_id": db_event.organizer_id,
        "organizer_name": current_user.full_name,
        "created_at": db_event.created_at,
        "spots_remaining": db_event.max_players - db_event.current_players,
    }
    
    return EventResponse(**response_data)


@router.get("/nearby", response_model=List[EventResponse])
async def get_nearby_events(
    lat: float = Query(..., description="Latitude"),
    lon: float = Query(..., description="Longitude"),
    radius_km: float = Query(10.0, description="Search radius"),
    sport: Optional[str] = Query(None, description="Filter by sport"),
    db: AsyncSession = Depends(get_db)
):
    """Find events near you"""
    
    query = text("""
        SELECT 
            e.id, e.title, e.description, e.sport, e.venue_id, e.custom_location,
            e.latitude, e.longitude, e.start_time, e.end_time,
            e.max_players, e.min_players, e.current_players,
            e.is_free, e.cost_per_player, e.status, e.skill_level, e.is_public,
            e.organizer_id, e.created_at,
            u.full_name as organizer_name,
            ST_Distance(
                e.location_geom::geography,
                ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography
            ) / 1000.0 as distance_km
        FROM events e
        JOIN users u ON e.organizer_id = u.id
        WHERE e.status = 'open'
          AND e.start_time > NOW()
          AND ST_DWithin(
              e.location_geom::geography,
              ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography,
              :radius_meters
          )
          (:sport IS NULL OR e.sport = :sport)
        ORDER BY e.start_time ASC
        LIMIT 50
    """)
    
    result = await db.execute(
        query,
        {
            "lat": lat,
            "lon": lon,
            "radius_meters": radius_km * 1000,
            "sport": sport.lower() if sport else None
        }
    )
    
    events = []
    for row in result.mappings():
        event_dict = dict(row)
        event_dict["spots_remaining"] = event_dict["max_players"] - event_dict["current_players"]
        events.append(EventResponse(**event_dict))
    
    return events


@router.post("/{event_id}/join", response_model=EventResponse)
async def join_event(
    event_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Join an event"""
    
    # Fetch event
    result = await db.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    if event.status != "open":
        raise HTTPException(status_code=400, detail="Event is not open for joining")
    
    if event.current_players >= event.max_players:
        raise HTTPException(status_code=400, detail="Event is full")
    
    # Check if already joined
    result = await db.execute(
        select(EventParticipant).where(
            and_(
                EventParticipant.event_id == event_id,
                EventParticipant.user_id == current_user.id,
                EventParticipant.status == "joined"
            )
        )
    )
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Already joined this event")
    
    # Add participant
    participant = EventParticipant(
        event_id=event_id,
        user_id=current_user.id,
        status="joined"
    )
    db.add(participant)
    
    # Update current_players
    event.current_players += 1
    
    # Check if event is now full
    if event.current_players >= event.max_players:
        event.status = "full"
    
    await db.commit()
    await db.refresh(event)
    
    # Fetch organizer name
    result = await db.execute(select(User).where(User.id == event.organizer_id))
    organizer = result.scalar_one()
    
    response_data = {
        "id": event.id,
        "title": event.title,
        "description": event.description,
        "sport": event.sport,
        "venue_id": event.venue_id,
        "custom_location": event.custom_location,
        "latitude": event.latitude,
        "longitude": event.longitude,
        "start_time": event.start_time,
        "end_time": event.end_time,
        "max_players": event.max_players,
        "min_players": event.min_players,
        "current_players": event.current_players,
        "is_free": event.is_free,
        "cost_per_player": event.cost_per_player,
        "status": event.status,
        "skill_level": event.skill_level,
        "is_public": event.is_public,
        "organizer_id": event.organizer_id,
        "organizer_name": organizer.full_name,
        "created_at": event.created_at,
        "spots_remaining": event.max_players - event.current_players,
    }
    
    return EventResponse(**response_data)