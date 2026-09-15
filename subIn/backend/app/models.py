import enum
from datetime import datetime

from geoalchemy2 import Geometry
from sqlalchemy import Boolean, Column, DateTime, Enum, Float, Integer, String, Text

from app.database import Base


class SkillLevel(enum.StrEnum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"
    PROFESSIONAL = "professional"  

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
    #created_events = relationship("Event", back_populates="organizer", foreign_keys="Event.organizer_id")
    #event_participations = relationship("EventParticipant", back_populates="user")
    #team_memberships = relationship("TeamMember", back_populates="user")
    #sent_messages = relationship("ChatMessage", back_populates="sender")
