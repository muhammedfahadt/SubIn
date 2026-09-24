import enum
from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


# ==========================================
# ENUMS (Like Java Enums or Dart Enums)
# ==========================================
# In Python, we inherit from (str, Enum) so they serialize directly to JSON strings.
class SportType(enum.StrEnum):
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
class SkillLevel(enum.StrEnum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"
    PROFESSIONAL = "professional"
# ==========================================
# USER SCHEMAS
# ==========================================
class UserCreate(BaseModel):
    """Data required to register a new user."""
    # EmailStr automatically validates email format (Like Java's @Email)
    email: EmailStr
    # Field(...) allows strict validation. '...' means it's required.
    password: str = Field(..., min_length=6, max_length=72)
    full_name: str = Field(..., min_length=2, max_length=100)
    # Optional[T] is like T? in Dart or @Nullable in Java
    phone: str | None = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    phone: str | None = None
    avatar_url: str | None = None
    latitude: float | None = None
    longitude: float | None = None

    # Provide safe defaults
    preferred_sports: list[SportType] = []
    skill_level: SkillLevel = SkillLevel.INTERMEDIATE

    bio: str | None = None
    is_available: bool = True
    looking_for_team: bool = False
    is_verified: bool = False
    created_at: datetime

    # 🪄 MAGIC: Convert DB string "football,cricket" -> List[SportType]
    @field_validator('preferred_sports', mode='before')
    @classmethod
    def parse_sports(cls, v):
        if isinstance(v, str):
            if not v:
                return []
            return [s.strip() for s in v.split(',') if s.strip()]
        return v

    # 🪄 MAGIC: Handle None values for skill_level gracefully
    @field_validator('skill_level', mode='before')
    @classmethod
    def parse_skill_level(cls, v):
        if v is None:
            return SkillLevel.INTERMEDIATE
        return v

    # Pydantic V2 syntax (replaces the old "class Config:")
    model_config = ConfigDict(from_attributes=True)

# ==========================================
# VENUE SCHEMAS
# ==========================================
class VenueCreate(BaseModel):
    name: str = Field(..., min_length=3)
    description: str | None = None
    address: str
    city: str
    latitude: float
    longitude: float
    sports: list[SportType]
    has_lights: bool = False
    has_changing_room: bool = False
    has_parking: bool = False
    is_free: bool = True
    price_per_hour: float | None = None
    phone: str | None = None
    website: str | None = None

class VenueResponse(BaseModel):
    id: int
    name: str
    description: str | None = None
    address: str
    city: str
    latitude: float
    longitude: float
    sports: list[str] = []
    has_lights: bool = False
    has_changing_room: bool = False
    has_parking: bool = False
    is_free: bool = True
    price_per_hour: float | None = None
    rating: float = 0.0
    review_count: int = 0          # ✅ Added default
    phone: str | None = None    # ✅ Added default
    website: str | None = None  # ✅ Added default
    image_urls: list[str] = []     # ✅ Added default
    distance_km: float | None = None

    # Pydantic V2 syntax to allow reading from SQLAlchemy objects
    model_config = ConfigDict(from_attributes=True)
     # mode='before' is CRITICAL: it runs BEFORE Pydantic checks if it's a list
    @field_validator('sports', 'image_urls', mode='before')
    @classmethod
    def split_comma_strings(cls, value: str | list | None) -> list:
        # If it's already a list (or None), return as-is
        if isinstance(value, list) or value is None:
            return value or []

        # If it's a string, split it
        if isinstance(value, str):
            # Handle empty strings gracefully
            if not value.strip():
                return []
            # Split by comma and strip whitespace from each item
            return [item.strip() for item in value.split(',')]

        return []
class VenueSearch(BaseModel):
    latitude: float
    longitude: float
    radius_km: float = 10.0
    sport: SportType | None = None

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
    sport: str
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
    skill_level: str
    is_public: bool
    organizer_id: int
    organizer_name: str
    created_at: datetime
    distance_km: Optional[float] = None
    spots_remaining: int = 0
    
    model_config = ConfigDict(from_attributes=True)    

# ==========================================
# AUTH SCHEMAS
# ==========================================
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
