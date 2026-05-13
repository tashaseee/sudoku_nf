# Sudoku Premium — Backend API

## Архитектура

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app entry point
│   ├── config.py             # Settings from .env
│   ├── database.py           # SQLAlchemy engine & session
│   ├── models.py             # ORM models (PostgreSQL)
│   ├── schemas.py            # Pydantic request/response schemas
│   ├── auth.py               # JWT + bcrypt utilities
│   ├── seed.py               # Initial data (achievements, articles)
│   └── routers/
│       ├── auth_router.py        # POST /register, /login, GET /me
│       ├── users_router.py       # GET/PATCH /me, GET /stats, POST /upgrade-pro
│       ├── games_router.py       # POST /games, GET /history, GET /leaderboard
│       ├── achievements_router.py # GET /achievements
│       └── articles_router.py    # GET/POST /articles
├── requirements.txt
├── setup.sh                  # One-command setup script
├── .env                      # Environment variables
└── .env.example
```

## Быстрый старт

### 1. Убедитесь что PostgreSQL запущен

```bash
brew services start postgresql@16    # или @14
```

### 2. Создайте базу данных

```bash
createuser -s sudoku_user
createdb -O sudoku_user sudoku_db
psql -d sudoku_db -c "ALTER USER sudoku_user WITH PASSWORD 'sudoku_pass';"
```

### 3. Запустите backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Или одной командой:
```bash
cd backend && bash setup.sh
```

### 4. Откройте документацию

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints

| Метод  | URL                        | Описание                    | Auth |
|--------|----------------------------|-----------------------------|------|
| POST   | `/api/auth/register`       | Регистрация                 | ❌   |
| POST   | `/api/auth/login`          | Вход                        | ❌   |
| GET    | `/api/auth/me`             | Текущий пользователь        | ✅   |
| GET    | `/api/users/me`            | Профиль                     | ✅   |
| PATCH  | `/api/users/me`            | Обновить профиль            | ✅   |
| GET    | `/api/users/me/stats`      | Статистика                  | ✅   |
| POST   | `/api/users/me/upgrade-pro`| Активация PRO               | ✅   |
| POST   | `/api/games/`              | Сохранить результат игры    | ✅   |
| GET    | `/api/games/history`       | История игр                 | ✅   |
| GET    | `/api/games/leaderboard`   | Таблица лидеров             | ❌   |
| GET    | `/api/achievements/`       | Все достижения              | ✅   |
| GET    | `/api/articles/`           | Статьи и новости            | ❌   |
| POST   | `/api/articles/`           | Создать статью              | ✅   |
| GET    | `/api/health`              | Проверка состояния API      | ❌   |

## Деплой backend

Backend можно бесплатно разместить на Render, Railway или Azure.

### Render
1. Создайте аккаунт на https://render.com и подключите репозиторий GitHub.
2. Добавьте новый Web Service с папкой `backend`.
3. Build Command: `pip install -r requirements.txt`
4. Start Command: `uvicorn app.main:app --host 0.0.0.0 --port 8000`
5. Создайте PostgreSQL базу данных на Render (Starter / free).
6. В настройках сервиса установите `DATABASE_URL` из Render.

### Railway
1. Зарегистрируйтесь на https://railway.app и создайте проект.
2. Выберите Deploy from GitHub и папку `backend`.
3. Railway автоматически увидит `requirements.txt`.
4. Создайте PostgreSQL плагин.
5. В настройках проекта добавьте переменную `DATABASE_URL`.
   - Railway предложит готовый URL после создания PostgreSQL плагина.
6. Убедитесь, что `Procfile` в папке `backend` существует и содержит:
   - `web: uvicorn app.main:app --host 0.0.0.0 --port $PORT`
7. После деплоя проверьте:
   - `https://<ваш-backend>.up.railway.app/api/health`
   - если ответ `status: ok`, значит backend запущен.

> Важно: если `DATABASE_URL` не задан, backend будет пытаться подключиться к локальному PostgreSQL и запуск завершится с ошибкой.

### Azure
1. Создайте App Service for Linux (Python 3.13).
2. Подключите GitHub репозиторий и папку `backend`.
3. Set startup command: `uvicorn app.main:app --host 0.0.0.0 --port 8000`
4. Добавьте `DATABASE_URL` в Application Settings.

### Важно
- В production `DATABASE_URL` должен быть публичным URL вашей PostgreSQL.
- `backend/Dockerfile` помогает, если платформа просит Docker deploy.
- После деплоя вы получите публичный URL backend, например `https://sudoku-backend.onrender.com`.

## Модели базы данных

- **users** — пользователи (email, username, hashed_password, is_pro)
- **user_stats** — агрегированная статистика (wins, losses, score, streaks, best times)
- **game_sessions** — каждая завершённая игра (difficulty, result, time, mistakes, score)
- **achievements** — мастер-список достижений (6 штук, как в UI)
- **user_achievements** — разблокированные достижения у пользователя
- **articles** — статьи для главной страницы

## Подключение из Flutter

Flutter подключается через `lib/core/api/api_client.dart` — HTTP-клиент с JWT-менеджментом.
Замените `baseUrl` в `lib/core/api/api_config.dart` на ваш production URL.
