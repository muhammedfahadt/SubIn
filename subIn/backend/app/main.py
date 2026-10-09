from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from app.config import settings
from app.database import Base, engine

# Import our routers
from app.routers import auth, venues, events  


@asynccontextmanager
async def lifespan(app: FastAPI):

    print("🚀 Starting SubIn API...")
    # Startup
    async with engine.begin() as conn:

        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS postgis;"))
        print("✅ PostGIS extension ensured.")
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown
    print("🛑 Shutting down SubIn API...")
    await engine.dispose()


app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    lifespan=lifespan
)

# CORS for Flutter web (dev: allow any localhost port, e.g. http://localhost:51585)
# NOTE: allow_origins=["*"] + allow_credentials=True is invalid — browsers
# drop the header in that combo. Use allow_origin_regex to echo the origin.
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost.*|http://127\.0\.0\.1.*",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers

app.include_router(venues.router)
app.include_router(auth.router)
app.include_router(events.router)  # Add the events router

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
