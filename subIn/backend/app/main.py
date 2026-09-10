from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config import settings
from app.database import engine, Base
from sqlalchemy import text
# Import our routers
from app.routers import venues,auth

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

# CORS for Flutter web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers

app.include_router(venues.router)
app.include_router(auth.router)

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
