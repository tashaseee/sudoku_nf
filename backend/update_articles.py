from app.database import SessionLocal
from app import models
from app.seed import seed_articles

db = SessionLocal()
db.query(models.Article).delete()
seed_articles(db)
db.commit()
print("Articles updated!")
