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
