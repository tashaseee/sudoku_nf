from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List, Dict

from ..database import get_db
from ..auth import get_current_user
from .. import models
from .. import schemas

router = APIRouter(prefix="/api/notifications", tags=["Notifications"])

@router.get("", response_model=List[schemas.NotificationOut])
def get_notifications(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
) -> List[Dict]:
    notifications = db.query(models.Notification).filter(
        models.Notification.user_id == current_user.id
    ).order_by(models.Notification.created_at.desc()).limit(20).all()
    
    # Generate some welcome notifications if the user has none
    if not notifications:
        welcome_notif = models.Notification(
            user_id=current_user.id,
            title="Добро пожаловать в Sudoku!",
            body="Мы рады видеть вас. Попробуйте сыграть свою первую игру.",
            icon="emoji_events_rounded",
            color="#F59E0B"
        )
        pro_notif = models.Notification(
            user_id=current_user.id,
            title="PRO-подписка",
            body="Откройте безлимитные подсказки и AI-обучение. Первые 7 дней бесплатно!",
            icon="diamond_rounded",
            color="#DD233B"
        )
        db.add_all([welcome_notif, pro_notif])
        db.commit()
        db.refresh(welcome_notif)
        db.refresh(pro_notif)
        notifications = [welcome_notif, pro_notif]

    res = []
    for n in notifications:
        res.append({
            "id": str(n.id),
            "user_id": str(n.user_id),
            "title": n.title,
            "body": n.body,
            "icon": n.icon,
            "color": n.color,
            "is_read": n.is_read,
            "created_at": n.created_at.isoformat()
        })
    return res

@router.post("/read-all")
def mark_all_read(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    db.query(models.Notification).filter(
        models.Notification.user_id == current_user.id,
        models.Notification.is_read == False
    ).update({"is_read": True})
    db.commit()
    return {"status": "ok"}
