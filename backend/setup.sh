#!/bin/bash
# ──────────────────────────────────────────────
# Скрипт для инициализации PostgreSQL базы данных
# и запуска бэкенда Sudoku Premium
# ──────────────────────────────────────────────

set -e

echo "🐱 Sudoku Premium — Настройка Backend (PostgreSQL)"
echo "========================================"

# 1. Create virtual environment
echo ""
echo "🐍 Создаём виртуальное окружение..."
cd "$(dirname "$0")"
python3 -m venv venv
source venv/bin/activate

# 2. Install dependencies
echo ""
echo "📦 Устанавливаем зависимости..."
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "✅ Зависимости установлены"

# 3. Run the server
echo ""
echo "🚀 Запускаем сервер..."
echo "   API:  http://localhost:8000"
echo "   Docs: http://localhost:8000/docs"
echo ""
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
