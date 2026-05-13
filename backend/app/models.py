"""SQLAlchemy ORM models matching the Sudoku app domain."""
import uuid
from datetime import datetime

from sqlalchemy import (
    Column, String, Integer, Float, Boolean, DateTime, ForeignKey, Text, JSON, Uuid
)
from sqlalchemy.orm import relationship

from .database import Base


class User(Base):
    """Registered user / player."""
    __tablename__ = "users"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    username = Column(String(100), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    avatar_url = Column(String(500), nullable=True)
    is_pro = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # relationships
    game_sessions = relationship("GameSession", back_populates="user", cascade="all, delete-orphan")
    stats = relationship("UserStats", back_populates="user", uselist=False, cascade="all, delete-orphan")
    achievements = relationship("UserAchievement", back_populates="user", cascade="all, delete-orphan")


class UserStats(Base):
    """Aggregate lifetime statistics for a user (one row per user)."""
    __tablename__ = "user_stats"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    total_games = Column(Integer, default=0)
    total_wins = Column(Integer, default=0)
    total_losses = Column(Integer, default=0)
    total_score = Column(Integer, default=0)
    best_time_easy = Column(Integer, nullable=True)       # seconds
    best_time_medium = Column(Integer, nullable=True)
    best_time_hard = Column(Integer, nullable=True)
    best_time_expert = Column(Integer, nullable=True)
    current_streak = Column(Integer, default=0)
    best_streak = Column(Integer, default=0)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="stats")


class GameSession(Base):
    """One completed (or abandoned) Sudoku game."""
    __tablename__ = "game_sessions"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    difficulty = Column(String(20), nullable=False)       # easy | medium | hard | expert
    result = Column(String(10), nullable=False)            # win | lose
    time_elapsed = Column(Integer, nullable=False)         # seconds
    mistakes = Column(Integer, default=0)
    hints_used = Column(Integer, default=0)
    score = Column(Integer, default=0)
    is_ai_coach = Column(Boolean, default=False)
    puzzle = Column(JSON, nullable=True)                   # 9x9 int list
    solution = Column(JSON, nullable=True)                 # 9x9 int list
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="game_sessions")


class Achievement(Base):
    """Master list of possible achievements."""
    __tablename__ = "achievements"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    key = Column(String(50), unique=True, nullable=False)        # e.g. "winner", "fire", "lightning"
    title = Column(String(100), nullable=False)
    description = Column(String(255), nullable=False)
    icon = Column(String(50), nullable=True)
    condition_type = Column(String(50), nullable=False)          # wins_count, streak, best_time
    condition_value = Column(Integer, nullable=False)            # threshold
    created_at = Column(DateTime, default=datetime.utcnow)

    user_achievements = relationship("UserAchievement", back_populates="achievement")


class UserAchievement(Base):
    """Many-to-many: which users have unlocked which achievements."""
    __tablename__ = "user_achievements"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    achievement_id = Column(Uuid, ForeignKey("achievements.id", ondelete="CASCADE"), nullable=False)
    unlocked_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="achievements")
    achievement = relationship("Achievement", back_populates="user_achievements")


class Article(Base):
    """Blog / news articles displayed on the home page."""
    __tablename__ = "articles"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    subtitle = Column(String(500), nullable=True)
    body = Column(Text, nullable=True)
    read_time = Column(String(20), nullable=True)         # "3 мин"
    color = Column(String(10), nullable=True)              # hex e.g. "#DD233B"
    image_url = Column(String(500), nullable=True)
    published_at = Column(DateTime, default=datetime.utcnow)
    is_published = Column(Boolean, default=True)


class Notification(Base):
    """In-app notifications for users."""
    __tablename__ = "notifications"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    icon = Column(String(50), nullable=True)
    color = Column(String(20), nullable=True)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User")
