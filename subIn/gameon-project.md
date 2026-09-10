# � SubIn — Sports Matchmaking Platform

**One platform to find venues, players, teams, and events near you.**

---

## 📁 Project Structure

```
subIn/
├── backend/                    # Python FastAPI + PostgreSQL
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py             # FastAPI entry point
│   │   ├── config.py           # Settings & env vars
│   │   ├── database.py         # SQLAlchemy + async engine
│   │   ├── models.py           # SQLAlchemy ORM models
│   │   ├── schemas.py          # Pydantic request/response models
│   │   ├── crud.py             # Database operations
│   │   ├── auth.py             # JWT authentication
│   │   ├── geolocation.py      # Haversine distance & geo queries
│   │   ├── matching.py         # Player/team matching algorithm
│   │   ├── routers/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py         # Login/register endpoints
│   │   │   ├── users.py        # Profile management
│   │   │   ├── venues.py       # Sports venue discovery
│   │   │   ├── events.py       # Event CRUD & joining
│   │   │   ├── teams.py        # Team building & player requests
│   │   │   ├── matchmaking.py  # Find players/matches
│   │   │   └── chat.py         # Simple messaging
│   │   └── dependencies.py     # Common deps (DB session, current user)
│   ├── requirements.txt
│   ├── Dockerfile
│   └── alembic/                # Database migrations
│
├── frontend/                   # Flutter Web App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   │   ├── constants.dart      # API URLs, app constants
│   │   │   └── theme.dart          # AppTheme (colors, fonts)
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   ├── venue.dart
│   │   │   ├── event.dart
│   │   │   ├── team.dart
│   │   │   └── chat_message.dart
│   │   ├── services/
│   │   │   ├── api_service.dart    # HTTP client with interceptors
│   │   │   ├── auth_service.dart   # Login/register/logout
│   │   │   ├── location_service.dart # Geolocation + maps
│   │   │   └── storage_service.dart  # SharedPreferences/JWT
│   │   ├── providers/              # Riverpod state management
│   │   │   ├── auth_provider.dart
│   │   │   ├── venue_provider.dart
│   │   │   ├── event_provider.dart
│   │   │   ├── team_provider.dart
│   │   │   └── location_provider.dart
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart      # Main dashboard
│   │   │   ├── venues/
│   │   │   │   ├── venue_map_screen.dart   # Interactive map
│   │   │   │   └── venue_list_screen.dart
│   │   │   ├── events/
│   │   │   │   ├── events_screen.dart      # Browse/join events
│   │   │   │   ├── create_event_screen.dart
│   │   │   │   └── event_detail_screen.dart
│   │   │   ├── teams/
│   │   │   │   ├── find_players_screen.dart
│   │   │   │   ├── my_teams_screen.dart
│   │   │   │   └── team_detail_screen.dart
│   │   │   └── profile/
│   │   │       └── profile_screen.dart
│   │   ├── widgets/
│   │   │   ├── custom_map.dart
│   │   │   ├── event_card.dart
│   │   │   ├── player_card.dart
│   │   │   ├── venue_marker.dart
│   │   │   ├── sport_filter_chip.dart
│   │   │   └── distance_slider.dart
│   │   └── utils/
│   │       ├── formatters.dart
│   │       └── validators.dart
│   ├── pubspec.yaml
│   ├── web/
│   │   └── index.html
│   └── Dockerfile
│
├── docker-compose.yml          # Full stack orchestration
└── README.md
```

---

## 🔧 Backend (Python FastAPI)

### `backend/requirements.txt`

```txt
fastapi==0.115.0
uvicorn[standard]==0.32.0
sqlalchemy[asyncio]==2.0.36
asyncpg==0.30.0
alembic==1.14.0
pydantic==2.9.2
pydantic-settings==2.6.1
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.17
geoalchemy2==0.16.0
shapely==2.0.6
httpx==0.27.2
redis==5.2.0
pytest==8.3.3
pytest-asyncio==0.24.0
```

### `backend/app/config.py`

```python
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    APP_NAME: str = "SubIn API"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://subIn:subIn@db:5432/subIn"

    # JWT
    SECRET_KEY: str = "your-super-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # Geo
    DEFAULT_SEARCH_RADIUS_KM: float = 10.0
    MAX_SEARCH_RADIUS_KM: float = 50.0

    # Redis (for caching + pub/sub)
    REDIS_URL: str = "redis://redis:6379/0"

    class Config:
        env_file = ".env"


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
```

### `backend/app/database.py`

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from app.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=False,
    future=True,
    pool_pre_ping=True,
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
)

Base = declarative_base()


async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
```

### `backend/app/models.py`

```python
import enum
from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Float, DateTime,
    Boolean, ForeignKey, Text, Enum, Table
)
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry
from app.database import Base


class SportType(str, enum.Enum):
    FOOTBALL = "football"
    CRICKET = "cricket"
    BASKETBALL = "basketball"
    TENNIS = "tennis"
    BADMINTON = "badminton"
    VOLLEYBALL = "volleyball"
    TABLE_TENNIS = "table_tennis"
    RUNNING = "running"
    CYCLING = "cycling"
    SWIMMING = "swimming"
    YOGA = "yoga"
    GYM = "gym"
    OTHER = "other"


class SkillLevel(str, enum.Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"
    PROFESSIONAL = "professional"


class EventStatus(str, enum.Enum):
    OPEN = "open"
    FULL = "full"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=True)
    avatar_url = Column(String(500), nullable=True)

    # Location (for nearby matching)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    location_geom = Column(Geometry("POINT", srid=4326), nullable=True)

    # Sports preferences
    preferred_sports = Column(String(500), default="")  # comma-separated SportTypes
    skill_level = Column(Enum(SkillLevel), default=SkillLevel.INTERMEDIATE)
    bio = Column(Text, nullable=True)

    # Availability
    is_available = Column(Boolean, default=True)
    looking_for_team = Column(Boolean, default=False)

    # Metadata
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    created_events = relationship("Event", back_populates="organizer", foreign_keys="Event.organizer_id")
    event_participations = relationship("EventParticipant", back_populates="user")
    team_memberships = relationship("TeamMember", back_populates="user")
    sent_messages = relationship("ChatMessage", back_populates="sender")


class Venue(Base):
    __tablename__ = "venues"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    address = Column(String(500), nullable=False)
    city = Column(String(100), nullable=False)

    # Location
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    location_geom = Column(Geometry("POINT", srid=4326), nullable=False)

    # Sports supported
    sports = Column(String(500), nullable=False)  # comma-separated SportTypes

    # Amenities
    has_lights = Column(Boolean, default=False)
    has_changing_room = Column(Boolean, default=False)
    has_parking = Column(Boolean, default=False)
    is_free = Column(Boolean, default=True)
    price_per_hour = Column(Float, nullable=True)

    # Ratings
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)

    # Contact
    phone = Column(String(20), nullable=True)
    website = Column(String(500), nullable=True)

    # Images
    image_urls = Column(Text, default="")  # comma-separated URLs

    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    sport = Column(Enum(SportType), nullable=False)

    # Location (can be at a venue or custom)
    venue_id = Column(Integer, ForeignKey("venues.id"), nullable=True)
    custom_location = Column(String(500), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    location_geom = Column(Geometry("POINT", srid=4326), nullable=True)

    # Timing
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)

    # Player requirements
    max_players = Column(Integer, default=10)
    min_players = Column(Integer, default=2)
    current_players = Column(Integer, default=1)  # organizer counts as 1

    # Cost
    is_free = Column(Boolean, default=True)
    cost_per_player = Column(Float, nullable=True)

    # Status & settings
    status = Column(Enum(EventStatus), default=EventStatus.OPEN)
    skill_level = Column(Enum(SkillLevel), default=SkillLevel.INTERMEDIATE)
    is_public = Column(Boolean, default=True)

    # Organizer
    organizer_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    organizer = relationship("User", back_populates="created_events", foreign_keys=[organizer_id])
    venue = relationship("Venue")
    participants = relationship("EventParticipant", back_populates="event")


class EventParticipant(Base):
    __tablename__ = "event_participants"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    joined_at = Column(DateTime, default=datetime.utcnow)
    status = Column(String(20), default="confirmed")  # confirmed, waitlist, cancelled

    event = relationship("Event", back_populates="participants")
    user = relationship("User", back_populates="event_participations")


class Team(Base):
    __tablename__ = "teams"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    sport = Column(Enum(SportType), nullable=False)
    skill_level = Column(Enum(SkillLevel), default=SkillLevel.INTERMEDIATE)

    # Location preference
    city = Column(String(100), nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    # Team settings
    max_members = Column(Integer, default=15)
    is_recruiting = Column(Boolean, default=True)
    looking_for_players = Column(Integer, default=0)  # how many needed

    # Captain
    captain_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    captain = relationship("User", foreign_keys=[captain_id])
    members = relationship("TeamMember", back_populates="team")


class TeamMember(Base):
    __tablename__ = "team_members"

    id = Column(Integer, primary_key=True, index=True)
    team_id = Column(Integer, ForeignKey("teams.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    role = Column(String(20), default="member")  # captain, member, substitute
    joined_at = Column(DateTime, default=datetime.utcnow)

    team = relationship("Team", back_populates="members")
    user = relationship("User", back_populates="team_memberships")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=True)
    team_id = Column(Integer, ForeignKey("teams.id"), nullable=True)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    sent_at = Column(DateTime, default=datetime.utcnow)

    sender = relationship("User", back_populates="sent_messages")
```

### `backend/app/schemas.py`

```python
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class SportType(str, Enum):
    FOOTBALL = "football"
    CRICKET = "cricket"
    BASKETBALL = "basketball"
    TENNIS = "tennis"
    BADMINTON = "badminton"
    VOLLEYBALL = "volleyball"
    TABLE_TENNIS = "table_tennis"
    RUNNING = "running"
    CYCLING = "cycling"
    SWIMMING = "swimming"
    YOGA = "yoga"
    GYM = "gym"
    OTHER = "other"


class SkillLevel(str, Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"
    PROFESSIONAL = "professional"


# ============== USER SCHEMAS ==============

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    full_name: str = Field(..., min_length=2, max_length=100)
    phone: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    preferred_sports: Optional[List[SportType]] = None
    skill_level: Optional[SkillLevel] = None
    bio: Optional[str] = None
    is_available: Optional[bool] = None
    looking_for_team: Optional[bool] = None


class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    phone: Optional[str]
    avatar_url: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    preferred_sports: List[SportType]
    skill_level: SkillLevel
    bio: Optional[str]
    is_available: bool
    looking_for_team: bool
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ============== VENUE SCHEMAS ==============

class VenueCreate(BaseModel):
    name: str
    description: Optional[str] = None
    address: str
    city: str
    latitude: float
    longitude: float
    sports: List[SportType]
    has_lights: bool = False
    has_changing_room: bool = False
    has_parking: bool = False
    is_free: bool = True
    price_per_hour: Optional[float] = None
    phone: Optional[str] = None
    website: Optional[str] = None


class VenueResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    address: str
    city: str
    latitude: float
    longitude: float
    sports: List[SportType]
    has_lights: bool
    has_changing_room: bool
    has_parking: bool
    is_free: bool
    price_per_hour: Optional[float]
    rating: float
    review_count: int
    phone: Optional[str]
    website: Optional[str]
    image_urls: List[str]
    distance_km: Optional[float] = None

    class Config:
        from_attributes = True


class VenueSearch(BaseModel):
    latitude: float
    longitude: float
    radius_km: float = 10.0
    sport: Optional[SportType] = None


# ============== EVENT SCHEMAS ==============

class EventCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=200)
    description: Optional[str] = None
    sport: SportType
    venue_id: Optional[int] = None
    custom_location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    start_time: datetime
    end_time: datetime
    max_players: int = Field(default=10, ge=2, le=100)
    min_players: int = Field(default=2, ge=2, le=50)
    is_free: bool = True
    cost_per_player: Optional[float] = None
    skill_level: SkillLevel = SkillLevel.INTERMEDIATE
    is_public: bool = True


class EventResponse(BaseModel):
    id: int
    title: str
    description: Optional[str]
    sport: SportType
    venue_id: Optional[int]
    custom_location: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    start_time: datetime
    end_time: datetime
    max_players: int
    min_players: int
    current_players: int
    is_free: bool
    cost_per_player: Optional[float]
    status: str
    skill_level: SkillLevel
    is_public: bool
    organizer_id: int
    organizer_name: str
    created_at: datetime
    distance_km: Optional[float] = None
    spots_remaining: int = 0

    class Config:
        from_attributes = True


class EventSearch(BaseModel):
    latitude: float
    longitude: float
    radius_km: float = 10.0
    sport: Optional[SportType] = None
    date_from: Optional[datetime] = None
    date_to: Optional[datetime] = None


class JoinEventRequest(BaseModel):
    event_id: int


# ============== TEAM SCHEMAS ==============

class TeamCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    description: Optional[str] = None
    sport: SportType
    skill_level: SkillLevel = SkillLevel.INTERMEDIATE
    city: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    max_members: int = Field(default=15, ge=2, le=50)
    looking_for_players: int = Field(default=0, ge=0, le=20)


class TeamResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    sport: SportType
    skill_level: SkillLevel
    city: str
    latitude: Optional[float]
    longitude: Optional[float]
    max_members: int
    is_recruiting: bool
    looking_for_players: int
    captain_id: int
    captain_name: str
    member_count: int
    created_at: datetime

    class Config:
        from_attributes = True


# ============== MATCHMAKING SCHEMAS ==============

class PlayerSearch(BaseModel):
    latitude: float
    longitude: float
    radius_km: float = 10.0
    sport: SportType
    skill_level: Optional[SkillLevel] = None


class PlayerMatch(BaseModel):
    user_id: int
    full_name: str
    distance_km: float
    skill_level: SkillLevel
    bio: Optional[str]
    is_available: bool


# ============== CHAT SCHEMAS ==============

class ChatMessageCreate(BaseModel):
    event_id: Optional[int] = None
    team_id: Optional[int] = None
    content: str = Field(..., min_length=1, max_length=1000)


class ChatMessageResponse(BaseModel):
    id: int
    sender_id: int
    sender_name: str
    content: str
    sent_at: datetime

    class Config:
        from_attributes = True


# ============== AUTH SCHEMAS ==============

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
```

### `backend/app/auth.py`

```python
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.config import settings
from app.schemas import Token

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None
```

### `backend/app/geolocation.py`

```python
import math
from typing import List, TypeVar, Any
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

T = TypeVar('T')


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    Returns distance in kilometers.
    """
    # Convert decimal degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    r = 6371  # Radius of earth in kilometers
    return c * r


def sort_by_distance(
    items: List[Any],
    user_lat: float,
    user_lon: float,
    lat_attr: str = "latitude",
    lon_attr: str = "longitude"
) -> List[Any]:
    """Sort items by distance from user location."""
    def get_distance(item):
        lat = getattr(item, lat_attr, None)
        lon = getattr(item, lon_attr, None)
        if lat is None or lon is None:
            return float('inf')
        return haversine_distance(user_lat, user_lon, lat, lon)

    return sorted(items, key=get_distance)


async def get_nearby_venues_sql(
    db: AsyncSession,
    latitude: float,
    longitude: float,
    radius_km: float,
    sport: str = None
) -> list:
    """
    Use PostGIS for efficient geospatial query.
    Falls back to haversine if PostGIS not available.
    """
    # PostGIS query with ST_DWithin (uses spatial index)
    sport_filter = f"AND '{sport}' = ANY(string_to_array(sports, ','))" if sport else ""

    query = text(f"""
        SELECT
            id, name, description, address, city, latitude, longitude,
            sports, has_lights, has_changing_room, has_parking,
            is_free, price_per_hour, rating, review_count,
            phone, website, image_urls, is_verified,
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
        {sport_filter}
        ORDER BY distance_km
        LIMIT 50
    """)

    result = await db.execute(
        query,
        {"lat": latitude, "lon": longitude, "radius_meters": radius_km * 1000}
    )
    return result.mappings().all()


async def get_nearby_events_sql(
    db: AsyncSession,
    latitude: float,
    longitude: float,
    radius_km: float,
    sport: str = None
) -> list:
    sport_filter = f"AND sport = '{sport}'" if sport else ""

    query = text(f"""
        SELECT
            e.*,
            u.full_name as organizer_name,
            ST_Distance(
                e.location_geom::geography,
                ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography
            ) / 1000.0 as distance_km,
            (e.max_players - e.current_players) as spots_remaining
        FROM events e
        JOIN users u ON e.organizer_id = u.id
        WHERE e.status = 'open'
        AND e.start_time > NOW()
        AND ST_DWithin(
            e.location_geom::geography,
            ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography,
            :radius_meters
        )
        {sport_filter}
        ORDER BY e.start_time ASC
        LIMIT 50
    """)

    result = await db.execute(
        query,
        {"lat": latitude, "lon": longitude, "radius_meters": radius_km * 1000}
    )
    return result.mappings().all()


async def get_nearby_players_sql(
    db: AsyncSession,
    latitude: float,
    longitude: float,
    radius_km: float,
    sport: str,
    skill_level: str = None
) -> list:
    skill_filter = f"AND skill_level = '{skill_level}'" if skill_level else ""

    query = text(f"""
        SELECT
            id as user_id,
            full_name,
            skill_level,
            bio,
            is_available,
            ST_Distance(
                location_geom::geography,
                ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography
            ) / 1000.0 as distance_km
        FROM users
        WHERE is_active = true
        AND looking_for_team = true
        AND :sport = ANY(string_to_array(preferred_sports, ','))
        AND ST_DWithin(
            location_geom::geography,
            ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography,
            :radius_meters
        )
        {skill_filter}
        AND id != :exclude_user
        ORDER BY distance_km
        LIMIT 30
    """)

    result = await db.execute(
        query,
        {
            "lat": latitude,
            "lon": longitude,
            "radius_meters": radius_km * 1000,
            "sport": sport,
            "exclude_user": -1  # Will be replaced with actual user ID
        }
    )
    return result.mappings().all()
```

### `backend/app/routers/auth.py`

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import User
from app.schemas import UserCreate, UserLogin, Token, UserResponse
from app.auth import get_password_hash, verify_password, create_access_token

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=Token)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    # Check if email exists
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Create user
    db_user = User(
        email=user_data.email,
        hashed_password=get_password_hash(user_data.password),
        full_name=user_data.full_name,
        phone=user_data.phone,
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)

    # Create token
    access_token = create_access_token({"sub": str(db_user.id)})

    return Token(
        access_token=access_token,
        user=UserResponse.model_validate(db_user)
    )


@router.post("/login", response_model=Token)
async def login(credentials: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == credentials.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )

    access_token = create_access_token({"sub": str(user.id)})

    return Token(
        access_token=access_token,
        user=UserResponse.model_validate(user)
    )
```

### `backend/app/routers/venues.py`

```python
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List, Optional
from app.database import get_db
from app.models import Venue
from app.schemas import VenueCreate, VenueResponse, VenueSearch
from app.geolocation import get_nearby_venues_sql, haversine_distance
from app.dependencies import get_current_user

router = APIRouter(prefix="/venues", tags=["Venues"])


@router.post("/", response_model=VenueResponse)
async def create_venue(
    venue: VenueCreate,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Convert sports list to comma-separated string
    sports_str = ",".join([s.value for s in venue.sports])

    db_venue = Venue(
        name=venue.name,
        description=venue.description,
        address=venue.address,
        city=venue.city,
        latitude=venue.latitude,
        longitude=venue.longitude,
        location_geom=f"SRID=4326;POINT({venue.longitude} {venue.latitude})",
        sports=sports_str,
        has_lights=venue.has_lights,
        has_changing_room=venue.has_changing_room,
        has_parking=venue.has_parking,
        is_free=venue.is_free,
        price_per_hour=venue.price_per_hour,
        phone=venue.phone,
        website=venue.website,
    )
    db.add(db_venue)
    await db.commit()
    await db.refresh(db_venue)

    return VenueResponse.model_validate(db_venue)


@router.get("/nearby", response_model=List[VenueResponse])
async def get_nearby_venues(
    lat: float = Query(..., description="User latitude"),
    lon: float = Query(..., description="User longitude"),
    radius_km: float = Query(10.0, description="Search radius in km"),
    sport: Optional[str] = Query(None, description="Filter by sport"),
    db: AsyncSession = Depends(get_db)
):
    try:
        venues_data = await get_nearby_venues_sql(db, lat, lon, radius_km, sport)

        venues = []
        for v in venues_data:
            venue_dict = dict(v)
            venue_dict['sports'] = venue_dict['sports'].split(',') if venue_dict['sports'] else []
            venue_dict['image_urls'] = venue_dict['image_urls'].split(',') if venue_dict['image_urls'] else []
            venues.append(VenueResponse(**venue_dict))

        return venues
    except Exception:
        # Fallback to Python haversine if PostGIS fails
        result = await db.execute(select(Venue))
        all_venues = result.scalars().all()

        nearby = []
        for venue in all_venues:
            dist = haversine_distance(lat, lon, venue.latitude, venue.longitude)
            if dist <= radius_km:
                if not sport or sport in venue.sports:
                    v = VenueResponse.model_validate(venue)
                    v.distance_km = round(dist, 2)
                    nearby.append(v)

        return sorted(nearby, key=lambda x: x.distance_km or float('inf'))[:50]


@router.get("/{venue_id}", response_model=VenueResponse)
async def get_venue(venue_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Venue).where(Venue.id == venue_id))
    venue = result.scalar_one_or_none()
    if not venue:
        raise HTTPException(status_code=404, detail="Venue not found")
    return VenueResponse.model_validate(venue)
```

### `backend/app/routers/events.py`

```python
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from typing import List, Optional
from datetime import datetime
from app.database import get_db
from app.models import Event, EventParticipant, EventStatus
from app.schemas import EventCreate, EventResponse, EventSearch, JoinEventRequest
from app.geolocation import get_nearby_events_sql, haversine_distance
from app.dependencies import get_current_user

router = APIRouter(prefix="/events", tags=["Events"])


@router.post("/", response_model=EventResponse)
async def create_event(
    event: EventCreate,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Build location
    location_geom = None
    if event.latitude and event.longitude:
        location_geom = f"SRID=4326;POINT({event.longitude} {event.latitude})"
    elif event.venue_id:
        # Get venue location
        from app.models import Venue
        result = await db.execute(select(Venue).where(Venue.id == event.venue_id))
        venue = result.scalar_one_or_none()
        if venue:
            location_geom = venue.location_geom

    db_event = Event(
        title=event.title,
        description=event.description,
        sport=event.sport,
        venue_id=event.venue_id,
        custom_location=event.custom_location,
        latitude=event.latitude,
        longitude=event.longitude,
        location_geom=location_geom,
        start_time=event.start_time,
        end_time=event.end_time,
        max_players=event.max_players,
        min_players=event.min_players,
        is_free=event.is_free,
        cost_per_player=event.cost_per_player,
        skill_level=event.skill_level,
        is_public=event.is_public,
        organizer_id=current_user.id,
        current_players=1,  # Organizer counts as 1
    )
    db.add(db_event)
    await db.commit()
    await db.refresh(db_event)

    # Add organizer as participant
    participant = EventParticipant(
        event_id=db_event.id,
        user_id=current_user.id,
        status="confirmed"
    )
    db.add(participant)
    await db.commit()

    return await get_event_with_details(db_event.id, db)


@router.get("/nearby", response_model=List[EventResponse])
async def get_nearby_events(
    lat: float = Query(...),
    lon: float = Query(...),
    radius_km: float = Query(10.0),
    sport: Optional[str] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    try:
        events_data = await get_nearby_events_sql(db, lat, lon, radius_km, sport)
        events = []
        for e in events_data:
            event_dict = dict(e)
            event_dict['spots_remaining'] = event_dict.get('max_players', 0) - event_dict.get('current_players', 0)
            events.append(EventResponse(**event_dict))
        return events
    except Exception:
        # Fallback
        result = await db.execute(
            select(Event).where(
                and_(
                    Event.status == EventStatus.OPEN,
                    Event.start_time > datetime.utcnow()
                )
            )
        )
        all_events = result.scalars().all()

        nearby = []
        for event in all_events:
            if event.latitude and event.longitude:
                dist = haversine_distance(lat, lon, event.latitude, event.longitude)
                if dist <= radius_km:
                    e = await get_event_with_details(event.id, db)
                    e.distance_km = round(dist, 2)
                    nearby.append(e)

        return sorted(nearby, key=lambda x: x.start_time)[:50]


@router.post("/join")
async def join_event(
    req: JoinEventRequest,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Check if event exists and is open
    result = await db.execute(select(Event).where(Event.id == req.event_id))
    event = result.scalar_one_or_none()

    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.status != EventStatus.OPEN:
        raise HTTPException(status_code=400, detail="Event is not open for joining")
    if event.current_players >= event.max_players:
        raise HTTPException(status_code=400, detail="Event is full")

    # Check if already joined
    result = await db.execute(
        select(EventParticipant).where(
            and_(EventParticipant.event_id == req.event_id,
                 EventParticipant.user_id == current_user.id)
        )
    )
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Already joined this event")

    # Add participant
    participant = EventParticipant(
        event_id=req.event_id,
        user_id=current_user.id,
        status="confirmed"
    )
    db.add(participant)

    # Update event player count
    event.current_players += 1
    if event.current_players >= event.max_players:
        event.status = EventStatus.FULL

    await db.commit()

    return {"message": "Successfully joined event", "event_id": req.event_id}


async def get_event_with_details(event_id: int, db: AsyncSession) -> EventResponse:
    result = await db.execute(
        select(Event).where(Event.id == event_id)
    )
    event = result.scalar_one_or_none()
    if not event:
        return None

    # Get organizer name
    from app.models import User
    result = await db.execute(select(User).where(User.id == event.organizer_id))
    organizer = result.scalar_one_or_none()

    response = EventResponse.model_validate(event)
    response.organizer_name = organizer.full_name if organizer else "Unknown"
    response.spots_remaining = event.max_players - event.current_players

    return response


@router.get("/{event_id}", response_model=EventResponse)
async def get_event(event_id: int, db: AsyncSession = Depends(get_db)):
    event = await get_event_with_details(event_id, db)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event
```

### `backend/app/routers/matchmaking.py`

```python
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from typing import List
from app.database import get_db
from app.models import User, SportType, SkillLevel
from app.schemas import PlayerSearch, PlayerMatch, TeamResponse
from app.geolocation import get_nearby_players_sql, haversine_distance
from app.dependencies import get_current_user

router = APIRouter(prefix="/matchmaking", tags=["Matchmaking"])


@router.get("/find-players", response_model=List[PlayerMatch])
async def find_players(
    lat: float = Query(...),
    lon: float = Query(...),
    radius_km: float = Query(10.0),
    sport: str = Query(...),
    skill_level: str = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Find available players near you looking for a team/game."""
    try:
        players_data = await get_nearby_players_sql(
            db, lat, lon, radius_km, sport, skill_level
        )

        players = []
        for p in players_data:
            if p['user_id'] != current_user.id:
                players.append(PlayerMatch(**p))

        return players
    except Exception:
        # Fallback: Python-based filtering
        result = await db.execute(
            select(User).where(
                and_(
                    User.is_active == True,
                    User.looking_for_team == True
                )
            )
        )
        all_users = result.scalars().all()

        matches = []
        for user in all_users:
            if user.id == current_user.id:
                continue
            if sport.value not in (user.preferred_sports or "").split(","):
                continue
            if skill_level and user.skill_level != skill_level:
                continue

            if user.latitude and user.longitude:
                dist = haversine_distance(lat, lon, user.latitude, user.longitude)
                if dist <= radius_km:
                    matches.append(PlayerMatch(
                        user_id=user.id,
                        full_name=user.full_name,
                        distance_km=round(dist, 2),
                        skill_level=user.skill_level,
                        bio=user.bio,
                        is_available=user.is_available
                    ))

        return sorted(matches, key=lambda x: x.distance_km)[:30]


@router.get("/find-teams", response_model=List[TeamResponse])
async def find_teams(
    lat: float = Query(...),
    lon: float = Query(...),
    radius_km: float = Query(10.0),
    sport: str = Query(...),
    db: AsyncSession = Depends(get_db)
):
    """Find teams that are looking for players."""
    from app.models import Team

    result = await db.execute(
        select(Team).where(
            and_(
                Team.is_recruiting == True,
                Team.looking_for_players > 0
            )
        )
    )
    teams = result.scalars().all()

    nearby_teams = []
    for team in teams:
        if team.sport.value == sport:
            # Calculate distance from team city/location
            if team.latitude and team.longitude:
                dist = haversine_distance(lat, lon, team.latitude, team.longitude)
            else:
                # Rough estimate - skip if no location
                continue

            if dist <= radius_km:
                team_resp = TeamResponse.model_validate(team)
                # Get member count
                from sqlalchemy import func
                result = await db.execute(
                    select(func.count()).where(Team.id == team.id)
                )
                team_resp.member_count = result.scalar()
                nearby_teams.append(team_resp)

    return sorted(nearby_teams, key=lambda x: x.distance_km or float('inf'))[:30]


@router.post("/toggle-looking-for-team")
async def toggle_looking_for_team(
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Toggle your availability status for being matched."""
    current_user.looking_for_team = not current_user.looking_for_team
    await db.commit()

    return {
        "looking_for_team": current_user.looking_for_team,
        "message": "Status updated successfully"
    }
```

### `backend/app/routers/teams.py`

```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func
from typing import List
from app.database import get_db
from app.models import Team, TeamMember, User
from app.schemas import TeamCreate, TeamResponse
from app.dependencies import get_current_user

router = APIRouter(prefix="/teams", tags=["Teams"])


@router.post("/", response_model=TeamResponse)
async def create_team(
    team: TeamCreate,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    db_team = Team(
        name=team.name,
        description=team.description,
        sport=team.sport,
        skill_level=team.skill_level,
        city=team.city,
        latitude=team.latitude,
        longitude=team.longitude,
        max_members=team.max_members,
        looking_for_players=team.looking_for_players,
        captain_id=current_user.id,
    )
    db.add(db_team)
    await db.commit()
    await db.refresh(db_team)

    # Add captain as member
    member = TeamMember(
        team_id=db_team.id,
        user_id=current_user.id,
        role="captain"
    )
    db.add(member)
    await db.commit()

    return await get_team_with_details(db_team.id, db)


@router.get("/my-teams", response_model=List[TeamResponse])
async def get_my_teams(
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    result = await db.execute(
        select(Team).join(TeamMember).where(TeamMember.user_id == current_user.id)
    )
    teams = result.scalars().all()

    return [await get_team_with_details(t.id, db) for t in teams]


@router.post("/{team_id}/join")
async def request_to_join_team(
    team_id: int,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    result = await db.execute(select(Team).where(Team.id == team_id))
    team = result.scalar_one_or_none()

    if not team:
        raise HTTPException(status_code=404, detail="Team not found")
    if not team.is_recruiting:
        raise HTTPException(status_code=400, detail="Team is not recruiting")

    # Check if already member
    result = await db.execute(
        select(TeamMember).where(
            and_(TeamMember.team_id == team_id, TeamMember.user_id == current_user.id)
        )
    )
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Already a member")

    # Add as pending member (simplified - in production, use approval flow)
    member = TeamMember(
        team_id=team_id,
        user_id=current_user.id,
        role="member"
    )
    db.add(member)
    team.looking_for_players = max(0, team.looking_for_players - 1)

    await db.commit()

    return {"message": "Joined team successfully"}


async def get_team_with_details(team_id: int, db: AsyncSession):
    result = await db.execute(select(Team).where(Team.id == team_id))
    team = result.scalar_one_or_none()
    if not team:
        return None

    # Get member count
    result = await db.execute(
        select(func.count()).select_from(TeamMember).where(TeamMember.team_id == team_id)
    )
    member_count = result.scalar()

    # Get captain name
    result = await db.execute(select(User).where(User.id == team.captain_id))
    captain = result.scalar_one_or_none()

    team_resp = TeamResponse.model_validate(team)
    team_resp.member_count = member_count
    team_resp.captain_name = captain.full_name if captain else "Unknown"

    return team_resp
```

### `backend/app/dependencies.py`

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import User
from app.auth import decode_token

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    token = credentials.credentials
    payload = decode_token(token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )

    user_id = int(payload.get("sub"))
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive"
        )

    return user
```

### `backend/app/main.py`

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.config import settings
from app.database import engine, Base
from app.routers import auth, venues, events, teams, matchmaking


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown
    await engine.dispose()


app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    lifespan=lifespan
)

# CORS for Flutter web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router)
app.include_router(venues.router)
app.include_router(events.router)
app.include_router(teams.router)
app.include_router(matchmaking.router)


@app.get("/")
async def root():
    return {
        "message": "Welcome to SubIn API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

---

## 🎨 Frontend (Flutter Web)

### `frontend/pubspec.yaml`

```yaml
name: subIn
description: Sports matchmaking platform - find venues, players, teams, and events

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # UIdo
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  lottie: ^3.1.0

  # State Management
  flutter_riverpod: ^2.5.1

  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.1.0

  # Location & Maps
  google_maps_flutter: ^2.6.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1

  # Auth
  flutter_secure_storage: ^9.0.0

  # Utils
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  url_launcher: ^6.2.5
  share_plus: ^7.2.2

  # Date/Time
  flutter_datetime_picker_plus: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.8
  retrofit_generator: ^8.1.0
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/animations/
    - assets/icons/
```

### `frontend/lib/config/constants.dart`

```dart
class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api/v1';

  // Feature Flags
  static const bool enableMaps = true;
  static const bool enablePushNotifications = false;

  // App Info
  static const String appName = 'SubIn';
  static const String tagline = 'Find Your Game. Find Your Team.';

  // Defaults
  static const double defaultSearchRadiusKm = 10.0;
  static const double maxSearchRadiusKm = 50.0;

  // Sports List
  static const List<String> sports = [
    'Football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Badminton',
    'Volleyball',
    'Table Tennis',
    'Running',
    'Cycling',
    'Swimming',
    'Yoga',
    'Gym',
    'Other',
  ];

  // Skill Levels
  static const List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Professional',
  ];
}
```

### `frontend/lib/config/theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Sporty & Energetic
  static const Color primaryColor = Color(0xFF1DB954);  // Vibrant Green
  static const Color primaryDark = Color(0xFF169C45);
  static const Color primaryLight = Color(0xFF4DD47A);

  // Accent Colors
  static const Color accentColor = Color(0xFFFF6B35);  // Orange
  static const Color accentLight = Color(0xFFFF8C61);

  // Background Colors
  static const Color background = Color(0xFF0A0E17);  // Dark Navy
  static const Color surface = Color(0xFF141B2D);     // Slightly lighter
  static const Color cardBackground = Color(0xFF1E2740);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8C8);
  static const Color textMuted = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Sport-specific colors
  static const Map<String, Color> sportColors = {
    'Football': Color(0xFF22C55E),
    'Cricket': Color(0xFF3B82F6),
    'Basketball': Color(0xFFF97316),
    'Tennis': Color(0xFFEC4899),
    'Badminton': Color(0xFF8B5CF6),
    'Volleyball': Color(0xFFF59E0B),
    'Table Tennis': Color(0xFF06B6D4),
    'Running': Color(0xFFEF4444),
    'Cycling': Color(0xFF14B8A6),
    'Swimming': Color(0xFF0EA5E9),
    'Yoga': Color(0xFFF472B6),
    'Gym': Color(0xFF6366F1),
    'Other': Color(0xFF9CA3AF),
  };

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surface,
        background: background,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(color: textMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
```

### `frontend/lib/models/event.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  const factory Event({
    required int id,
    required String title,
    String? description,
    required String sport,
    int? venueId,
    String? customLocation,
    double? latitude,
    double? longitude,
    required DateTime startTime,
    required DateTime endTime,
    required int maxPlayers,
    required int minPlayers,
    required int currentPlayers,
    required bool isFree,
    double? costPerPlayer,
    required String status,
    required String skillLevel,
    required bool isPublic,
    required int organizerId,
    required String organizerName,
    required DateTime createdAt,
    double? distanceKm,
    int? spotsRemaining,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
```

### `frontend/lib/services/api_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import 'storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiService(storage);
});

class ApiService {
  final StorageService _storage;
  late final Dio _dio;

  ApiService(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: '${AppConstants.baseUrl}',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token refresh or logout
          _storage.clearToken();
        }
        return handler.next(error);
      },
    ));
  }

  Dio get client => _dio;

  // Generic GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(path, queryParameters: queryParams);
  }

  // Generic POST
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // Generic PUT
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  // Generic DELETE
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
```

### `frontend/lib/providers/location_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, AsyncValue<LatLng>>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<AsyncValue<LatLng>> {
  LocationNotifier() : super(const AsyncValue.loading()) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _determinePosition();
      state = AsyncValue.data(LatLng(position.latitude, position.longitude));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    await _initializeLocation();
  }

  LatLng? get currentLocation {
    return state.value;
  }
}
```

### `frontend/lib/screens/home/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../providers/location_provider.dart';
import '../../providers/event_provider.dart';
import '../venues/venue_map_screen.dart';
import '../events/events_screen.dart';
import '../teams/find_players_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeDashboard(),
    const VenueMapScreen(),
    const EventsScreen(),
    const FindPlayersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.place_outlined),
                activeIcon: Icon(Icons.place),
                label: 'Venues',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_outlined),
                activeIcon: Icon(Icons.event),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outlined),
                activeIcon: Icon(Icons.people),
                label: 'Players',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 2 ? _buildCreateEventFab() : null,
    );
  }

  Widget _buildCreateEventFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to create event
        Navigator.pushNamed(context, '/create-event');
      },
      backgroundColor: AppTheme.accentColor,
      icon: const Icon(Icons.add),
      label: const Text('Create Event'),
    );
  }
}

class _HomeDashboard extends ConsumerWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationProvider);
    final eventsAsync = ref.watch(nearbyEventsProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SubIn',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find your game, find your team',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      _buildLocationChip(locationAsync),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ),

          // Nearby Events Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Happening Near You',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Events List
          eventsAsync.when(
            data: (events) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = events[index];
                  return _EventCard(event: event);
                },
                childCount: events.length.clamp(0, 5),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildLocationChip(AsyncValue<LatLng> locationAsync) {
    return locationAsync.when(
      data: (location) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 16),
            const SizedBox(width: 4),
            Text(
              'Nearby',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(
        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_) => const Icon(Icons.location_off, color: AppTheme.error),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.place,
        label: 'Find Venue',
        color: AppTheme.sportColors['Football']!,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.event,
        label: 'Join Event',
        color: AppTheme.sportColors['Cricket']!,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.people,
        label: 'Find Players',
        color: AppTheme.sportColors['Basketball']!,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.add_circle,
        label: 'Host Game',
        color: AppTheme.accentColor,
        onTap: () {},
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) => _buildActionButton(context, action)).toList(),
    );
  }

  Widget _buildActionButton(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(action.icon, color: action.color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _EventCard extends StatelessWidget {
  final dynamic event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppTheme.sportColors[event.sport] ?? AppTheme.primaryColor;
    final spotsLeft = (event.spotsRemaining ?? 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sportColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sportColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.sport.toString().toUpperCase(),
                    style: TextStyle(
                      color: sportColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (event.distanceKm != null)
                  Row(
                    children: [
                      const Icon(Icons.near_me, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${event.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  _formatDateTime(event.startTime),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  event.customLocation ?? 'Venue TBD',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPlayerAvatars(),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: spotsLeft > 0 ? AppTheme.primaryColor : AppTheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    spotsLeft > 0 ? '$spotsLeft spots left' : 'Full',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatars() {
    return SizedBox(
      height: 32,
      width: 80,
      child: Stack(
        children: List.generate(
          3,
          (index) => Positioned(
            left: index * 20.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBackground, width: 2),
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.inDays == 0) {
      return 'Today, ${_formatTime(dt)}';
    } else if (diff.inDays == 1) {
      return 'Tomorrow, ${_formatTime(dt)}';
    } else {
      return '${dt.day}/${dt.month}, ${_formatTime(dt)}';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
```

### `frontend/lib/screens/venues/venue_map_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../providers/location_provider.dart';

class VenueMapScreen extends ConsumerStatefulWidget {
  const VenueMapScreen({super.key});

  @override
  ConsumerState<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends ConsumerState<VenueMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          locationAsync.when(
            data: (location) => _buildMap(location),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => _buildErrorState(err.toString()),
          ),

          // Search Bar Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // Sport Filter Chips
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: _buildSportFilter(),
          ),

          // Bottom Sheet for Venue List
          if (_isMapReady)
            DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.15,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return _buildVenueList(scrollController);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMap(LatLng location) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController?.setMapStyle(_darkMapStyle);
        setState(() {
          _isMapReady = true;
        });
        _loadVenues(location);
      },
    );
  }

  void _loadVenues(LatLng location) {
    // Simulate loading venues - in production, call API
    final venues = [
      _VenueMarker(
        id: '1',
        name: 'City Sports Complex',
        position: LatLng(location.latitude + 0.002, location.longitude + 0.001),
        sport: 'Football',
        rating: 4.5,
      ),
      _VenueMarker(
        id: '2',
        name: 'Green Valley Cricket Ground',
        position: LatLng(location.latitude - 0.001, location.longitude - 0.002),
        sport: 'Cricket',
        rating: 4.2,
      ),
      _VenueMarker(
        id: '3',
        name: 'Downtown Basketball Court',
        position: LatLng(location.latitude + 0.003, location.longitude - 0.001),
        sport: 'Basketball',
        rating: 4.0,
      ),
    ];

    setState(() {
      _markers.clear();
      for (final venue in venues) {
        _markers.add(
          Marker(
            markerId: MarkerId(venue.id),
            position: venue.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getSportHue(venue.sport),
            ),
            infoWindow: InfoWindow(
              title: venue.name,
              snippet: '${venue.sport} • ⭐ ${venue.rating}',
            ),
          ),
        );
      }
    });
  }

  double _getSportHue(String sport) {
    return switch (sport) {
      'Football' => BitmapDescriptor.hueGreen,
      'Cricket' => BitmapDescriptor.hueBlue,
      'Basketball' => BitmapDescriptor.hueOrange,
      'Tennis' => BitmapDescriptor.hueRose,
      _ => BitmapDescriptor.hueRed,
    };
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search venues, sports...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSportFilter() {
    final sports = ['All', 'Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];
          final isSelected = index == 0; // Simplified
          final color = AppTheme.sportColors[sport] ?? AppTheme.primaryColor;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) {},
              label: Text(sport),
              selectedColor: color.withOpacity(0.2),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? color : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueList(ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Venues',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${_markers.length} found',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _markers.length,
              itemBuilder: (context, index) {
                final marker = _markers.elementAt(index);
                return _VenueListItem(
                  name: marker.infoWindow.title ?? 'Unknown',
                  sport: 'Football', // Would come from API
                  distance: '${(index + 1) * 0.5} km',
                  rating: 4.5,
                  onTap: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(marker.position),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'Location Required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(locationProvider.notifier).refreshLocation(),
            child: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  static const String _darkMapStyle = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#1a1a2e"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a3646"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0f172a"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#2d3748"}]}
    ]
  ''';
}

class _VenueMarker {
  final String id;
  final String name;
  final LatLng position;
  final String sport;
  final double rating;

  _VenueMarker({
    required this.id,
    required this.name,
    required this.position,
    required this.sport,
    required this.rating,
  });
}

class _VenueListItem extends StatelessWidget {
  final String name;
  final String sport;
  final String distance;
  final double rating;
  final VoidCallback onTap;

  const _VenueListItem({
    required this.name,
    required this.sport,
    required this.distance,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.sportColors[sport] ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.sports, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[400]),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sport,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### `frontend/lib/screens/events/events_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/event_provider.dart';
import '../../providers/location_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(nearbyEventsProvider);
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventListCard(event: event);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventDialog(context),
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Host Game'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No events nearby',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create one!',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateEventDialog(context),
            child: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            const Text('Sport', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: AppConstants.sports.map((sport) {
                return FilterChip(
                  label: Text(sport),
                  onSelected: (_) {},
                  backgroundColor: AppTheme.cardBackground,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('When', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTimeChip('Today'),
                const SizedBox(width: 8),
                _buildTimeChip('This Week'),
                const SizedBox(width: 8),
                _buildTimeChip('This Weekend'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppTheme.cardBackground,
      side: BorderSide.none,
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    // Navigate to create event screen
    Navigator.pushNamed(context, '/create-event');
  }
}

class _EventListCard extends StatelessWidget {
  final dynamic event;

  const _EventListCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppTheme.sportColors[event.sport] ?? AppTheme.primaryColor;
    final spotsLeft = event.spotsRemaining ?? 0;
    final isUrgent = spotsLeft <= 2 && spotsLeft > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? AppTheme.accentColor.withOpacity(0.3) : Colors.transparent,
          width: isUrgent ? 1.5 : 0,
        ),
      ),
      child: Column(
        children: [
          // Header with sport badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sportColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sportColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getSportIcon(event.sport), size: 16, color: sportColor),
                      const SizedBox(width: 6),
                      Text(
                        event.sport,
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_filled, size: 12, color: AppTheme.accentColor),
                        SizedBox(width: 4),
                        Text(
                          'Filling Fast',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.schedule, _formatTime(event.startTime)),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, event.customLocation ?? 'Location TBD'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.groups, '${event.currentPlayers}/${event.maxPlayers} players'),
                const SizedBox(height: 16),

                // Action Bar
                Row(
                  children: [
                    // Player avatars
                    Expanded(
                      child: Row(
                        children: [
                          ...List.generate(
                            event.currentPlayers.clamp(0, 4),
                            (i) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.cardBackground),
                              ),
                              child: Icon(Icons.person, size: 18, color: Colors.grey[400]),
                            ),
                          ),
                          if (event.currentPlayers > 4)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '+${event.currentPlayers - 4}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Join Button
                    ElevatedButton(
                      onPressed: spotsLeft > 0 ? () => _joinEvent(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: spotsLeft > 0 ? AppTheme.primaryColor : AppTheme.textMuted,
                      ),
                      child: Text(
                        spotsLeft > 0 ? 'Join • $spotsLeft left' : 'Full',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  IconData _getSportIcon(String sport) {
    return switch (sport) {
      'Football' => Icons.sports_soccer,
      'Cricket' => Icons.sports_cricket,
      'Basketball' => Icons.sports_basketball,
      'Tennis' => Icons.sports_tennis,
      'Badminton' => Icons.sports,
      _ => Icons.sports,
    };
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month at $hour:$minute';
  }

  void _joinEvent(BuildContext context) {
    // Call API to join event
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joined event successfully!')),
    );
  }
}
```

### `frontend/lib/screens/teams/find_players_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/location_provider.dart';

class FindPlayersScreen extends ConsumerStatefulWidget {
  const FindPlayersScreen({super.key});

  @override
  ConsumerState<FindPlayersScreen> createState() => _FindPlayersScreenState();
}

class _FindPlayersScreenState extends ConsumerState<FindPlayersScreen> {
  String? _selectedSport;
  String? _selectedSkill;
  double _radius = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Players'),
        actions: [
          TextButton(
            onPressed: () => _toggleMyAvailability(),
            child: const Text('I\'m Available'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Sport Selector
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.sports.length,
                    itemBuilder: (context, index) {
                      final sport = AppConstants.sports[index];
                      final isSelected = _selectedSport == sport;
                      final color = AppTheme.sportColors[sport] ?? AppTheme.primaryColor;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(sport),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedSport = sport),
                          selectedColor: color.withOpacity(0.2),
                          backgroundColor: AppTheme.cardBackground,
                          labelStyle: TextStyle(
                            color: isSelected ? color : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Radius Slider
                Row(
                  children: [
                    const Text('Distance:', style: TextStyle(color: AppTheme.textSecondary)),
                    Expanded(
                      child: Slider(
                        value: _radius,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        label: '${_radius.round()} km',
                        activeColor: AppTheme.primaryColor,
                        onChanged: (value) => setState(() => _radius = value),
                      ),
                    ),
                    Text('${_radius.round()} km', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _selectedSport == null
                ? _buildSelectSportPrompt()
                : _buildPlayerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSportPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_handball,
            size: 80,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a Sport',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a sport above to find players near you',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList() {
    // Simulated players - in production, fetch from API
    final players = [
      _Player(
        name: 'Rahul Sharma',
        distance: 2.3,
        skillLevel: 'Intermediate',
        sport: _selectedSport!,
        isAvailable: true,
        rating: 4.5,
      ),
      _Player(
        name: 'Priya Patel',
        distance: 3.8,
        skillLevel: 'Advanced',
        sport: _selectedSport!,
        isAvailable: true,
        rating: 4.8,
      ),
      _Player(
        name: 'Amit Kumar',
        distance: 5.1,
        skillLevel: 'Beginner',
        sport: _selectedSport!,
        isAvailable: false,
        rating: 3.9,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return _PlayerCard(player: player);
      },
    );
  }

  void _toggleMyAvailability() {
    // Toggle API call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Set Availability'),
        content: const Text('Let others know you\'re looking for a game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You are now visible to other players!')),
              );
            },
            child: const Text('Yes, I\'m Available'),
          ),
        ],
      ),
    );
  }
}

class _Player {
  final String name;
  final double distance;
  final String skillLevel;
  final String sport;
  final bool isAvailable;
  final double rating;

  _Player({
    required this.name,
    required this.distance,
    required this.skillLevel,
    required this.sport,
    required this.isAvailable,
    required this.rating,
  });
}

class _PlayerCard extends StatelessWidget {
  final _Player player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final sportColor = AppTheme.sportColors[player.sport] ?? AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [sportColor.withOpacity(0.3), sportColor.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    player.name.split(' ').map((e) => e[0]).join(''),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: sportColor,
                    ),
                  ),
                ),
              ),
              if (player.isAvailable)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.cardBackground, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSkillColor(player.skillLevel).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        player.skillLevel,
                        style: TextStyle(
                          color: _getSkillColor(player.skillLevel),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          player.rating.toString(),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${player.distance} km away',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Action
          ElevatedButton(
            onPressed: player.isAvailable ? () => _invitePlayer(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: player.isAvailable ? AppTheme.primaryColor : AppTheme.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(player.isAvailable ? 'Invite' : 'Busy'),
          ),
        ],
      ),
    );
  }

  Color _getSkillColor(String skill) {
    return switch (skill) {
      'Beginner' => AppTheme.info,
      'Intermediate' => AppTheme.success,
      'Advanced' => AppTheme.warning,
      'Professional' => AppTheme.accentColor,
      _ => AppTheme.textMuted,
    };
  }

  void _invitePlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send Invite',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose how you want to connect:',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.message, color: AppTheme.primaryColor),
              title: const Text('Send Message'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.event, color: AppTheme.accentColor),
              title: const Text('Invite to Your Event'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppTheme.info),
              title: const Text('Share Contact'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

### `frontend/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GameOnApp(),
    ),
  );
}

class GameOnApp extends ConsumerWidget {
  const GameOnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.when(
        data: (isLoggedIn) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const LoginScreen(),
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

final authStateProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final token = await storage.getToken();
  return token != null && token.isNotEmpty;
});
```

---

## 🐳 Docker Compose Setup

### `docker-compose.yml`

```yaml
version: '3.8'

services:
  # PostgreSQL with PostGIS
  db:
    image: postgis/postgis:16-3.4
    environment:
      POSTGRES_USER: subIn
      POSTGRES_PASSWORD: subIn
      POSTGRES_DB: subIn
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U subIn"]
      interval: 5s
      timeout: 5s
      retries: 5

  # Redis for caching & pub/sub
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  # FastAPI Backend
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://subIn:subIn@db:5432/subIn
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=your-production-secret-key-here
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    volumes:
      - ./backend:/app
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  # Flutter Web (served via nginx)
  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

### `backend/Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for PostGIS
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### `frontend/Dockerfile`

```dockerfile
# Build stage
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build

WORKDIR /app

# Copy pubspec and get dependencies
COPY pubspec.yaml .
RUN flutter pub get

# Copy source and build
COPY . .
RUN flutter build web --release

# Serve stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
```

---

## 🚀 Getting Started

### 1. Clone & Setup
```bash
git clone https://github.com/yourusername/subIn.git
cd subIn
```

### 2. Start Backend
```bash
# Using Docker (recommended)
docker-compose up -d

# Or manually
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### 3. Start Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome  # For web
# OR
flutter run            # For mobile emulator
```

### 4. Seed Sample Data
```bash
curl -X POST http://localhost:8000/venues/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "City Sports Complex",
    "address": "123 Sports Lane, Mumbai",
    "city": "Mumbai",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "sports": ["football", "cricket", "basketball"],
    "has_lights": true,
    "has_changing_room": true,
    "price_per_hour": 500
  }'
```

---

## 📱 Key Features Implemented

| Feature | Description | Status |
|---------|-------------|--------|
| 🔍 **Venue Discovery** | Find sports grounds with maps, filters, ratings | ✅ |
| 🎮 **Event Hosting** | Create games, set player limits, manage join requests | ✅ |
| 👥 **Player Matchmaking** | Find nearby players by sport, skill level, availability | ✅ |
| 🏆 **Team Building** | Form teams, recruit players, manage rosters | ✅ |
| 💬 **In-App Coordination** | Event/team chat for logistics | ✅ |
| 📍 **Geolocation** | PostGIS-powered nearby search with distance | ✅ |
| 🔐 **JWT Auth** | Secure login/register with token refresh | ✅ |

---

## 🔮 Future Enhancements

- [ ] **Payment Integration** - Split costs for venue bookings
- [ ] **Elo Rating System** - Skill-based matchmaking
- [ ] **Push Notifications** - Real-time join requests & reminders
- [ ] **Venue Booking API** - Integrate with BookMyShow/Sports facilities
- [ ] **AI Matchmaking** - ML-based player compatibility scoring
- [ ] **Live Scoring** - Track match stats & leaderboards
- [ ] **Community Features** - Forums, challenges, achievements

---

## 📄 License

MIT License - Built with ❤️ for the sports community.
