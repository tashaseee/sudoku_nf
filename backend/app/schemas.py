"""Pydantic schemas for API request / response validation."""
from datetime import datetime
from typing import Optional, List
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


# ─── Auth ─────────────────────────────────────────────
class UserRegister(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=2, max_length=100)
    password: str = Field(..., min_length=6, max_length=128)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: "UserOut"


# ─── User ─────────────────────────────────────────────
class UserOut(BaseModel):
    id: UUID
    email: str
    username: str
    avatar_url: Optional[str] = None
    is_pro: bool = False
    created_at: datetime

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    username: Optional[str] = None
    avatar_url: Optional[str] = None


# ─── User Stats ──────────────────────────────────────
class UserStatsOut(BaseModel):
    total_games: int = 0
    total_wins: int = 0
    total_losses: int = 0
    total_score: int = 0
    best_time_easy: Optional[int] = None
    best_time_medium: Optional[int] = None
    best_time_hard: Optional[int] = None
    best_time_expert: Optional[int] = None
    current_streak: int = 0
    best_streak: int = 0
    win_rate: float = 0.0

    class Config:
        from_attributes = True


# ─── Game Session ────────────────────────────────────
class GameSessionCreate(BaseModel):
    difficulty: str = Field(..., pattern="^(easy|medium|hard|expert)$")
    result: str = Field(..., pattern="^(win|lose)$")
    time_elapsed: int = Field(..., ge=0)
    mistakes: int = Field(0, ge=0)
    hints_used: int = Field(0, ge=0)
    score: int = Field(0, ge=0)
    is_ai_coach: bool = False
    puzzle: Optional[List[List[int]]] = None
    solution: Optional[List[List[int]]] = None


class GameSessionOut(BaseModel):
    id: UUID
    difficulty: str
    result: str
    time_elapsed: int
    mistakes: int
    hints_used: int
    score: int
    is_ai_coach: bool
    completed_at: datetime

    class Config:
        from_attributes = True


# ─── Achievement ─────────────────────────────────────
class AchievementOut(BaseModel):
    id: UUID
    key: str
    title: str
    description: str
    icon: Optional[str] = None
    condition_type: str
    condition_value: int
    unlocked: bool = False
    unlocked_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ─── Article ─────────────────────────────────────────
class ArticleOut(BaseModel):
    id: UUID
    title: str
    subtitle: Optional[str] = None
    body: Optional[str] = None
    read_time: Optional[str] = None
    color: Optional[str] = None
    image_url: Optional[str] = None
    published_at: datetime

    class Config:
        from_attributes = True


class ArticleCreate(BaseModel):
    title: str
    subtitle: Optional[str] = None
    body: Optional[str] = None
    read_time: Optional[str] = None
    color: Optional[str] = None
    image_url: Optional[str] = None


# ─── Notifications ─────────────────────────────────────
class NotificationOut(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    body: str
    icon: Optional[str] = None
    color: Optional[str] = None
    is_read: bool = False
    created_at: datetime

    class Config:
        from_attributes = True


# ─── Leaderboard ─────────────────────────────────────
class LeaderboardEntry(BaseModel):
    username: str
    total_score: int
    total_wins: int
    win_rate: float
    avatar_url: Optional[str] = None


# Forward-ref resolution
TokenResponse.model_rebuild()
