"""Game session endpoints: save results, get history, leaderboard."""
from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc

from ..database import get_db
from .. import models, schemas
from ..auth import get_current_user

router = APIRouter(prefix="/api/games", tags=["games"])


def _calculate_score(difficulty: str, time_elapsed: int, mistakes: int, hints_used: int) -> int:
    """Calculate score based on difficulty, time, mistakes and hints."""
    base = {"easy": 100, "medium": 200, "hard": 400, "expert": 800}.get(difficulty, 100)
    # Time bonus: faster = more points (max 2x base)
    time_bonus = max(0, base - time_elapsed // 10)
    # Penalties
    mistake_penalty = mistakes * 30
    hint_penalty = hints_used * 20
    return max(0, base + time_bonus - mistake_penalty - hint_penalty)


def _update_best_time(stats: models.UserStats, difficulty: str, time_elapsed: int):
    """Update best time for the given difficulty if this is a new record."""
    attr = f"best_time_{difficulty}"
    current_best = getattr(stats, attr)
    if current_best is None or time_elapsed < current_best:
        setattr(stats, attr, time_elapsed)


def _check_achievements(db: Session, user_id, stats: models.UserStats):
    """Check and unlock any new achievements based on current stats."""
    achievements = db.query(models.Achievement).all()
    unlocked_ids = {
        ua.achievement_id
        for ua in db.query(models.UserAchievement).filter(
            models.UserAchievement.user_id == user_id
        ).all()
    }

    for ach in achievements:
        if ach.id in unlocked_ids:
            continue
        value = 0
        if ach.condition_type == "wins_count":
            value = stats.total_wins
        elif ach.condition_type == "streak":
            value = stats.best_streak
        elif ach.condition_type == "best_time":
            # Check all difficulty best times
            for attr in ["best_time_easy", "best_time_medium", "best_time_hard", "best_time_expert"]:
                bt = getattr(stats, attr)
                if bt is not None and bt <= ach.condition_value:
                    value = ach.condition_value  # trigger unlock
                    break
        elif ach.condition_type == "total_games":
            value = stats.total_games
        elif ach.condition_type == "total_score":
            value = stats.total_score

        if value >= ach.condition_value:
            ua = models.UserAchievement(user_id=user_id, achievement_id=ach.id)
            db.add(ua)
            # Create a notification
            notif = models.Notification(
                user_id=user_id,
                title="Достижение открыто!",
                body=f"Поздравляем! Вы открыли достижение: {ach.title}.",
                icon=ach.icon or "emoji_events_rounded",
                color="#F59E0B"
            )
            db.add(notif)


@router.post("", response_model=schemas.GameSessionOut, status_code=201)
def save_game(
    payload: schemas.GameSessionCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Save a completed game session and update user stats + achievements."""
    # Calculate score if won
    score = 0
    if payload.result == "win":
        score = _calculate_score(payload.difficulty, payload.time_elapsed, payload.mistakes, payload.hints_used)

    session = models.GameSession(
        user_id=current_user.id,
        difficulty=payload.difficulty,
        result=payload.result,
        time_elapsed=payload.time_elapsed,
        mistakes=payload.mistakes,
        hints_used=payload.hints_used,
        score=score,
        is_ai_coach=payload.is_ai_coach,
        puzzle=payload.puzzle,
        solution=payload.solution,
    )
    db.add(session)

    # Update aggregated stats
    stats = db.query(models.UserStats).filter(models.UserStats.user_id == current_user.id).first()
    if not stats:
        stats = models.UserStats(user_id=current_user.id)
        db.add(stats)
        db.flush()

    stats.total_games += 1
    stats.total_score += score

    if payload.result == "win":
        stats.total_wins += 1
        stats.current_streak += 1
        if stats.current_streak > stats.best_streak:
            stats.best_streak = stats.current_streak
        _update_best_time(stats, payload.difficulty, payload.time_elapsed)
    else:
        stats.total_losses += 1
        stats.current_streak = 0

    # Check achievements
    _check_achievements(db, current_user.id, stats)

    db.commit()
    db.refresh(session)
    return session


@router.get("/history", response_model=List[schemas.GameSessionOut])
def get_history(
    limit: int = Query(50, le=200),
    offset: int = Query(0, ge=0),
    result_filter: str = Query(None, pattern="^(win|lose)$"),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Get game history for the current user, newest first."""
    query = db.query(models.GameSession).filter(
        models.GameSession.user_id == current_user.id
    )
    if result_filter:
        query = query.filter(models.GameSession.result == result_filter)

    games = query.order_by(desc(models.GameSession.completed_at)).offset(offset).limit(limit).all()
    return games


@router.get("/leaderboard", response_model=List[schemas.LeaderboardEntry])
def get_leaderboard(
    limit: int = Query(20, le=100),
    db: Session = Depends(get_db),
):
    """Public leaderboard sorted by total score."""
    rows = (
        db.query(models.UserStats, models.User)
        .join(models.User, models.UserStats.user_id == models.User.id)
        .order_by(desc(models.UserStats.total_score))
        .limit(limit)
        .all()
    )

    result = []
    for stats, user in rows:
        total = stats.total_games or 1
        win_rate = round(stats.total_wins / total * 100, 1) if stats.total_games > 0 else 0.0
        result.append(schemas.LeaderboardEntry(
            username=user.username,
            total_score=stats.total_score,
            total_wins=stats.total_wins,
            win_rate=win_rate,
            avatar_url=user.avatar_url,
        ))
    return result
