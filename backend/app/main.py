"""
FastAPI application entry point.

Run with:
    uvicorn app.main:app --reload --port 8000
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import engine, SessionLocal, Base
from .models import User, UserStats, GameSession, Achievement, UserAchievement, Article, Notification  # noqa: F401 — ensure models are registered
from .seed import seed_all
from .routers import auth_router, users_router, games_router, achievements_router, articles_router, notifications_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create tables on startup and seed initial data."""
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        seed_all(db)
    finally:
        db.close()

    yield  # application runs


app = FastAPI(
    title="Sudoku Premium API",
    description="Backend API для мобильного приложения Судоку Премиум",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS — allow Flutter dev to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth_router.router)
app.include_router(users_router.router)
app.include_router(games_router.router)
app.include_router(achievements_router.router)
app.include_router(articles_router.router)
app.include_router(notifications_router.router)


@app.get("/", tags=["health"])
def health_check():
    return {
        "status": "ok",
        "app": "Sudoku Premium API",
        "version": "1.0.0",
    }


@app.get("/api/health", tags=["health"])
def api_health():
    """Detailed health check including DB connectivity."""
    db = SessionLocal()
    try:
        db.execute(
            __import__("sqlalchemy").text("SELECT 1")
        )
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {str(e)}"
    finally:
        db.close()

    return {
        "status": "ok",
        "database": db_status,
    }
