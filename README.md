# nfactorial_sudoku

Мобильное приложение Sudoku типо коллаборация с nfactorial с бэкендом, уведомлениями, статьями и игровой статистикой. Сделана за один день
Сделана на флаттере, бэк на пайтоне, база данных postgresql. 
Это решение для любителей судоку, которые хотят тренировать логическое мышление, отслеживать прогресс и получать персональные уведомления о событиях в приложении. Самое главное что там есть коуч, который поможет обьяснит как играть в судоку, если ты начинаешь с нуля. Также специальный милый маскот с которым просто приятно смотреть приложение и играть, так как другие приложения из за отсутствия легкости маскота и игровой эстетики кажутся слишком серьезными что пугает и отбивает желания учиться играть в судоку.
Ценно тем, что сочетает удобный интерфейс, систему достижений и синхронизацию данных через API.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Деплой на Vercel

Чтобы опубликовать frontend на Vercel, лучше всего использовать Flutter Web как статический сайт:

1. Соберите веб-версию локально:
   - `flutter build web`
2. Убедитесь, что в корне проекта есть файл `vercel.json`.
3. Установите Vercel CLI (если нужно): `npm install -g vercel`
4. Разверните сайт:
   - `vercel --prod`

Vercel по умолчанию даст домен вида `nfactorial-sudoku.vercel.app`.
Если нужен свой домен, его можно подключить через Vercel-дэшборд.

> Важно: текущее приложение использует FastAPI + PostgreSQL на backend.
> Для полного рабочего приложения backend нужно разместить отдельно, например на Render, Railway, Fly.io или Azure.
> Затем замените `ApiConfig.baseUrl` в `lib/core/api/api_config.dart` на публичный URL вашего backend.

### Ключевые настройки

- `build/web` — статический вывод Flutter Web.
- `vercel.json` — конфигурация для раздачи статических файлов.
- `lib/core/api/api_config.dart` — настройка URL backend для production.
- `render.yaml` — пример Render конфигурации для backend и frontend.

Если хотите, я могу помочь настроить отдельный хостинг для FastAPI и связать его с проектом.

## Render (альтернатива Railway)

Если Railway не подходит, можно разместить backend на Render:

1. Зарегистрируйтесь на https://render.com и подключите GitHub.
2. В корне репозитория есть `render.yaml`.
3. Render автоматически развернёт backend из папки `backend`.
4. Backend будет запущен с командой:
   - `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. В Render создайте PostgreSQL базу и установите `DATABASE_URL`.
6. После деплоя проверьте:
   - `https://<ваш-backend>.onrender.com/api/health`

> Если backend не стартует, проверьте, что `DATABASE_URL` задан и доступен.

## Связка frontend + backend

1. Разверните frontend на Vercel через `flutter build web` и `vercel --prod`.
2. Разверните backend на Render / Railway / Azure.
3. Скопируйте публичный backend URL, например `https://your-backend-url.onrender.app`.
4. В `lib/core/api/api_config.dart` замените `baseUrl` на этот URL.

Пример:
```dart
static const String baseUrl = 'https://your-backend-url.onrender.app';
```

После этого frontend на Vercel будет работать с вашим backend.
