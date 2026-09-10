from pydantic import BaseModel, EmailStr, Field, ConfigDict,field_validator
from typing import Optional, List
from datetime import datetime
from enum import Enum

# ==========================================
# ENUMS (Like Java Enums or Dart Enums)
# ==========================================
# In Python, we inherit from (str, Enum) so they serialize directly to JSON strings.
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
    phone: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    # Provide safe defaults
    preferred_sports: List[SportType] = []
    skill_level: SkillLevel = SkillLevel.INTERMEDIATE

    bio: Optional[str] = None
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
    description: Optional[str] = None
    address: str
    city: str
    latitude: float
    longitude: float
    sports: List[str] = []
    has_lights: bool = False
    has_changing_room: bool = False
    has_parking: bool = False
    is_free: bool = True
    price_per_hour: Optional[float] = None
    rating: float = 0.0
    review_count: int = 0          # ✅ Added default
    phone: Optional[str] = None    # ✅ Added default
    website: Optional[str] = None  # ✅ Added default
    image_urls: List[str] = []     # ✅ Added default
    distance_km: Optional[float] = None

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
    sport: Optional[SportType] = None

# ==========================================
# AUTH SCHEMAS
# ==========================================
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
