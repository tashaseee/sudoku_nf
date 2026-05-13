"""Achievements endpoints."""
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from .. import models, schemas
from ..auth import get_current_user

router = APIRouter(prefix="/api/achievements", tags=["achievements"])


@router.get("", response_model=List[schemas.AchievementOut])
def get_all_achievements(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Return all achievements, marking which ones the current user has unlocked."""
    achievements = db.query(models.Achievement).all()
    unlocked = {
        ua.achievement_id: ua.unlocked_at
        for ua in db.query(models.UserAchievement).filter(
            models.UserAchievement.user_id == current_user.id
        ).all()
    }

    result = []
    for ach in achievements:
        result.append(schemas.AchievementOut(
            id=ach.id,
            key=ach.key,
            title=ach.title,
            description=ach.description,
            icon=ach.icon,
            condition_type=ach.condition_type,
            condition_value=ach.condition_value,
            unlocked=ach.id in unlocked,
            unlocked_at=unlocked.get(ach.id),
        ))
    return result
