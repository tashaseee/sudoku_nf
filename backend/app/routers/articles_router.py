"""Articles endpoints for the home page feed."""
from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc

from ..database import get_db
from .. import models, schemas
from ..auth import get_current_user

router = APIRouter(prefix="/api/articles", tags=["articles"])


@router.get("", response_model=List[schemas.ArticleOut])
def get_articles(
    limit: int = Query(20, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    """Get published articles, newest first. Public endpoint."""
    articles = (
        db.query(models.Article)
        .filter(models.Article.is_published == True)
        .order_by(desc(models.Article.published_at))
        .offset(offset)
        .limit(limit)
        .all()
    )
    return articles


@router.post("/", response_model=schemas.ArticleOut, status_code=201)
def create_article(
    payload: schemas.ArticleCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Create a new article (admin-like, any authed user for now)."""
    article = models.Article(
        title=payload.title,
        subtitle=payload.subtitle,
        body=payload.body,
        read_time=payload.read_time,
        color=payload.color,
        image_url=payload.image_url,
    )
    db.add(article)
    db.commit()
    db.refresh(article)
    return article
