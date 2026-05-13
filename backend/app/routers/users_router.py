"""User profile and stats endpoints."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from .. import models, schemas
from ..auth import get_current_user

router = APIRouter(prefix="/api/users", tags=["users"])


@router.get("/me", response_model=schemas.UserOut)
def get_profile(current_user: models.User = Depends(get_current_user)):
    """Get current user profile."""
    return current_user


@router.patch("/me", response_model=schemas.UserOut)
def update_profile(
    payload: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Update username or avatar."""
    if payload.username is not None:
        existing = db.query(models.User).filter(
            models.User.username == payload.username,
            models.User.id != current_user.id,
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="Это имя уже занято")
        current_user.username = payload.username
    if payload.avatar_url is not None:
        current_user.avatar_url = payload.avatar_url

    db.commit()
    db.refresh(current_user)
    return current_user


@router.get("/me/stats", response_model=schemas.UserStatsOut)
def get_my_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Return aggregated stats for the current user."""
    stats = db.query(models.UserStats).filter(models.UserStats.user_id == current_user.id).first()
    if not stats:
        # Auto-create if missing
        stats = models.UserStats(user_id=current_user.id)
        db.add(stats)
        db.commit()
        db.refresh(stats)

    total = stats.total_games or 1  # avoid /0
    win_rate = round(stats.total_wins / total * 100, 1) if stats.total_games > 0 else 0.0

    return schemas.UserStatsOut(
        total_games=stats.total_games,
        total_wins=stats.total_wins,
        total_losses=stats.total_losses,
        total_score=stats.total_score,
        best_time_easy=stats.best_time_easy,
        best_time_medium=stats.best_time_medium,
        best_time_hard=stats.best_time_hard,
        best_time_expert=stats.best_time_expert,
        current_streak=stats.current_streak,
        best_streak=stats.best_streak,
        win_rate=win_rate,
    )


@router.post("/me/upgrade-pro", response_model=schemas.UserOut)
def upgrade_to_pro(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Activate PRO subscription (simplified, no payment)."""
    current_user.is_pro = True
    db.commit()
    db.refresh(current_user)
    return current_user
