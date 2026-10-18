# SubIn
**Stop watching. Sub into the game.**

## CS50 Final Project — Video Demo

> 🎥 **Demo video:** [https://www.youtube.com/watch?v=g96hQKWOjS4](https://www.youtube.com/watch?v=g96hQKWOjS4)

## Overview

SubIn is a location-based sports meetup app. The problem it addresses is simple: people who want to play casual sports often have no team and no easy way to find an open game nearby. SubIn lets a player discover sports events and venues around their current location, view details and participants, join an event, or host one themselves.

The project has two parts that run separately:

- **Backend** (`subIn/backend/`): a FastAPI + PostgreSQL/PostGIS API that owns authentication, venues, events, and geographic search.
- **Frontend** (`subIn/frontend/`): a Flutter app (Riverpod + go_router + Dio) that signs users in, reads GPS location, calls the API, and renders events and venues on OpenStreetMap-based maps.

## Features (verified against the code)

Implemented end to end:

- **User registration and login** — `POST /auth/register` and `POST /auth/login` return a JWT access token plus the user object (`subIn/backend/app/routers/auth.py`). The Flutter login, registration, splash, and landing screens authenticate through `AuthService` and guard routes with `authIsLoggedInProvider` (`subIn/frontend/lib/router/app_router.dart`).
- **Nearby event discovery with sport and radius filtering** — `GET /events/nearby?lat=&lon=&radius_km=&sport=` backed by a PostGIS query; the home screen, events screen, and sport filter chips consume it via `nearByEventsProvider` (`subIn/frontend/lib/providers/event_provider.dart`).
- **Nearby venue discovery with map** — `GET /venues/nearby` backed by PostGIS `ST_DWithin`/`ST_Distance`; `VenueMapScreen` renders venues on `flutter_map` (OpenStreetMap tiles, no API key) with sport filter chips and a venue list bottom sheet.
- **Venue creation** — `POST /venues/` (requires login) with a bottom-sheet form (`create_venue_sheet.dart` → `VenueService.createVenue`).
- **Event details and joining** — `GET /events/{id}` plus `GET /events/{id}/participants` feed `EventDetailScreen` (info card, organizer card, participant list, mini map); `POST /events/{id}/join` joins directly and marks the event `full` when `current_players` reaches `max_players`. The organizer is detected from the stored user id and cannot join their own event.
- **Event creation (hosting)** — `POST /events/` (requires login) from `CreateEventScreen`: title, sport, skill level, venue picker or GPS/custom coordinates, start/end times, player limits, and optional cost. The organizer is automatically added as the first participant.
- **JWT authentication on requests** — the app attaches `Authorization: Bearer <token>` via a Dio interceptor (`api_service.dart`) and clears the stored token on `401`. Tokens are HS256 JWTs valid for 7 days (`ACCESS_TOKEN_EXPIRE_MINUTES` in `subIn/backend/app/config.py`).

Partially implemented (only the working portion is claimed above):

- **Venue ratings/amenities** — the database and schemas store `rating`, `review_count`, lights/changing-room/parking, but there is no API or UI to submit reviews; displayed ratings default to `0.0`.
- **Notifications/profile/social login** — the UI shows notification, profile, Google, and Apple buttons, but they display "not available yet" snackbars; the backend has no social login.

**Not implemented** (explicitly *not* claimed as features — see Future Improvements):

- Team creation/management, player matchmaking, in-app chat/messaging, join-request approval workflow, and JWT token refresh. The database models contain only `users`, `venues`, `events`, and `event_participants` tables; there are no team, matchmaking, or chat tables, routers, or screens in the submitted code (such items appear only in the aspirational `subIn/gameon-project.md` notes file).


## Technology stack (verified)

Backend (`subIn/backend/requirements.txt`, Dockerfiles, code):

- FastAPI 0.115 + Uvicorn, SQLAlchemy 2 async + `asyncpg`, Pydantic v2 + `pydantic-settings`
- Auth: `python-jose` (HS256 JWT) + `passlib[bcrypt]`
- Geo: `GeoAlchemy2` + `shapely`, PostgreSQL 16 + PostGIS 3.4 (`postgis/postgis:16-3.4` in `subIn/docker-compose.yml`)
- Also declared but unused at runtime by app code: `alembic`, `redis`, `httpx`, `python-multipart`
- Lint/test/CI: Ruff, pytest + pytest-asyncio, GitHub Actions (`fastapi-pipeline.yml`)

Frontend (`subIn/frontend/pubspec.yaml`, code):

- Flutter (Dart `>=3.6.0 <4.0.0`), Riverpod 3, `go_router` 18 for navigation
- Networking: `dio` 5 with an auth interceptor; `retrofit`/`json_serializable`/`freezed` for models
- Location/maps: `geolocator`, `geocoding`, `flutter_map` 8 + `latlong2` (OpenStreetMap tiles, no API key). `google_maps_flutter` is listed but the screens use `flutter_map`.
- UI/utils: `google_fonts`, `intl`, `url_launcher`, `shared_preferences`, `talker` logging + `sentry_flutter`
- CI: `flutter analyze`, `flutter test`, web build (`frontend/Dockerfile` multi-stage to nginx)

## How it works / architecture

1. The user registers or logs in. The backend hashes passwords with bcrypt and returns `{access_token, token_type: "bearer", user}`. The JWT `sub` claim is the user id.
2. The Flutter app saves the token and attaches it as `Authorization: Bearer <token>` on every API call (`api_service.dart`). A `401` clears local state and forces re-login.
3. Protected routes decode the JWT (`get_current_user` in `subIn/backend/app/dependencies.py`) and reject missing/expired/inactive users with `401`.
4. The app reads GPS via `geolocator` (`locationProvider`) and sends `lat`/`lon`/`radius_km` (plus optional `sport`) to `/events/nearby` and `/venues/nearby`.
5. PostGIS does the geographic work in SQL: venues and events store `location_geom POINT (SRID 4326)`; nearby queries use `ST_DWithin(... ::geography, ..., radius_meters)` to filter and `ST_Distance(...) / 1000` for `distance_km` ordering. This keeps radius filtering and distance sorting in one indexed query instead of fetching every row.
6. Joining is a single `POST /events/{id}/join`: the backend rejects full events, duplicate joins, inactive users, and organizer self-joins, then increments `current_players` and flips `status` to `full` at capacity.

Why PostGIS: "nearby games" is a radius query over latitude/longitude. PostGIS geography types measure in meters on the earth's surface with spatial indexes. Why separate frontend/backend: the Flutter client and FastAPI API communicate only over documented JSON endpoints, so either side can evolve or be replaced; the app points at local, Docker, or production backends via `API_BASE_URL` / `AppConstants.baseUrl`.

### API endpoints (all routes actually registered)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | `/`, `/health` | No | API info, health check |
| POST | `/auth/register` | No | Register; returns JWT + user |
| POST | `/auth/login` | No | Login; returns JWT + user |
| POST | `/venues/` | Yes | Create venue |
| GET | `/venues/nearby?lat=&lon(or lng)=&radius_km=` | No | Nearby venues by `distance_km` (limit 50) |
| GET | `/venues/{venue_id}` | No | Venue details |
| POST | `/events/` | Yes | Create event (venue or custom coords) |
| GET | `/events/nearby?lat=&lon=&radius_km=&sport=` | No | Nearby open events with `distance_km`, `spots_remaining` |
| GET | `/events/{event_id}` | No | Event details |
| POST | `/events/{event_id}/join` | Yes | Join event |
| GET | `/events/{event_id}/participants` | No | Participant list (defined twice identically in code; FastAPI uses the second) |

Sports (`SportType`): `football, cricket, basketball, tennis, badminton, volleyball, table_tennis, running, cycling, swimming, yoga, gym, other`. Skills: `beginner, intermediate, advanced, professional`.

## Important source files

Backend:

- `subIn/backend/app/main.py` — entry point; enables PostGIS, creates tables on startup, registers `auth`/`venues`/`events` routers, CORS for local Flutter web.
- `subIn/backend/app/models.py` — tables: `users`, `venues`, `events`, `event_participants` (with `location_geom` geography columns).
- `subIn/backend/app/schemas.py` — Pydantic request/response models and enums.
- `subIn/backend/app/auth.py` — bcrypt hashing, HS256 JWT create/decode.
- `subIn/backend/app/dependencies.py` — `get_current_user` Bearer guard.
- `subIn/backend/app/routers/auth.py`, `routers/venues.py`, `routers/events.py` — the endpoints above.
- `subIn/backend/app/config.py`, `app/database.py` — settings and async engine/session.
- `subIn/docker-compose.yml`, `subIn/backend/Dockerfile` — PostGIS + Redis + API + web services.

Frontend:

- `subIn/frontend/lib/main.dart` — `ProviderScope`, optional Sentry, `MaterialApp.router`.
- `subIn/frontend/lib/router/app_router.dart` — routes (`/`, `/landing`, `/login`, `/register`, `/home`, `/events`, `/venues`, `/create-event`, `/events/:id`) and login redirects.
- `subIn/frontend/lib/services/api_service.dart` — Dio client, base URL, auth interceptor, `401` handling.
- `subIn/frontend/lib/services/auth_services.dart` — login/register/logout, persists token + user name/id.
- `subIn/frontend/lib/services/event_service.dart`, `services/venue_service.dart` — typed API wrappers.
- `subIn/frontend/lib/providers/auth_provider.dart` — `AuthState {isLoggedIn, userName, userId}` + actions.
- `subIn/frontend/lib/providers/event_provider.dart`, `providers/location_provider.dart` — nearby-events feed, GPS state.
- `subIn/frontend/lib/screens/auth/`, `screens/splash_screen.dart`, `screens/landing/` — auth flow and entry screens.
- `subIn/frontend/lib/screens/home/home_screen.dart` (+ `widgets/`) — nearby events/venues preview, sport filter chips.
- `subIn/frontend/lib/screens/events/events_screen.dart`, `screens/events/event_detail_screen.dart`, `screens/events/create_event_screen.dart` — browse, view/join, host.
- `subIn/frontend/lib/screens/venues/venue_map_screen.dart`, `screens/venues/create_venue_sheet.dart` — map discovery, venue creation.
- `subIn/frontend/lib/models/event.dart`, `models/venue.dart`, `models/participant.dart` — Freezed/JSON models (generated files committed).
- `subIn/frontend/lib/config/app_constants.dart`, `config/app_theme.dart` — API base URL, sport lists, radii, theme.
- `subIn/frontend/Dockerfile`, `subIn/frontend/nginx.conf` — multi-stage web build served by nginx with SPA fallback.

## Setup and installation

Prerequisites: Git, Docker + Docker Compose (recommended), Python 3.11+ for a manual backend, Flutter stable 3.24+ for the frontend.

```bash
# Clone — this is the actual repository URL from the workspace remote
git clone git@github.com:muhammedfahadt/SubIn.git
cd SubIn/subIn
```

Code lives under the `subIn/` subdirectory (the git root holds this README, `LICENSE`, and `.gitignore`).

### Option A — Docker (recommended, matches `docker-compose.yml`)

```bash
docker compose up --build
```

Starts PostGIS (`5432`), Redis (`6379`), the API (`8000`), and builds the Flutter web image. The backend creates the PostGIS extension and tables automatically on startup (`Base.metadata.create_all` in `main.py`).

### Option B — manual backend

```bash
cd backend
python -m venv venv
# Windows (PowerShell): .\venv\Scripts\Activate.ps1
# macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API docs: `http://localhost:8000/docs`. Health: `http://localhost:8000/health`.

### Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

For a phone emulator use `flutter run` with the same `--dart-define` pointing at a host reachable from the device (not `localhost`). Production web builds inject the API URL at build time (`--dart-define=API_BASE_URL=<prod URL>`, see `flutter-pipeline.yml`).

## Database and environment configuration

- `DATABASE_URL` (default in `config.py`): `postgresql+asyncpg://subIn:subIn@127.0.0.1:5432/subIn`. Compose uses `...@db:5432/...`. A local `subIn/backend/.env` currently holds only that default — do not commit real secrets.
- `SECRET_KEY` / `ALGORITHM` / `ACCESS_TOKEN_EXPIRE_MINUTES`: JWT config (defaults: placeholder secret, `HS256`, 7 days). Set a strong `SECRET_KEY` in the environment for anything beyond local dev.
- `DEFAULT_SEARCH_RADIUS_KM` (10.0) / `MAX_SEARCH_RADIUS_KM` (50.0): backend radius defaults; app default is `AppConstants.defaultSearchRadiusKm = 10.0`.
- `REDIS_URL`: declared in config and Compose, but no app code currently uses Redis.
- Migrations: `alembic` is a declared dependency and CI references `alembic upgrade head`, but **no migration files exist in the repo** — tables come from `Base.metadata.create_all` at startup.
- Sample data: **no seed script exists**. To create a venue manually, first register/login to get a JWT, then call the authenticated endpoint with that token.
- Tests: backend `subIn/backend/tests/` and frontend `test/` suites exist and run in CI (PostGIS service container for backend). I did not execute either suite while writing this README.

## Design decisions and technical challenges

- **PostGIS geography for nearby search.** `location_geom` is `POINT, SRID 4326`, queried with `ST_DWithin`/`ST_Distance` on the `geography` cast so radius math is in meters with spatial-index support. The events query also joins the venue name and computes `spots_remaining` in SQL.
- **Venue-or-coordinates events.** An event references either a `venue_id` (coordinates copied from the venue) or free-form GPS coordinates, so park pickup games work without a venue row. The create screen falls back to GPS when no venue is picked.
- **Naive-UTC datetimes.** Postgres columns are `TIMESTAMP WITHOUT TIME ZONE` while the app sends ISO-8601 with `Z`; `EventCreate` normalizes to naive UTC so both sides agree.
- **Riverpod async auth state.** `AuthNotifier` checks stored credentials at startup; the router watches `authIsLoggedInProvider` so login/logout redirect automatically.
- **Free map stack.** `flutter_map` + OpenStreetMap tiles + `geolocator` need no API key; `google_maps_flutter` remains an unused declared dependency.
- **Bug fixed during development:** the event-detail header previously read a nonexistent `authNotifierProvider.user?.id` via `ref.read` and matched sport colors case-sensitively. It now watches `authNotifierProvider.value?.userId` and matches sport names case-insensitively.

## Known limitations and future improvements

Verified limitations:

- Tokens are stored in `SharedPreferences` under an **empty-string key** (`prefs.setString('', token)`); `flutter_secure_storage` is declared but unused. Token storage should move to secure storage with a real key.
- No token refresh: tokens expire after 7 days and a `401` clears local state for re-login. No password reset, email verification, or social login (buttons are UI-only placeholders).
- No teams, matchmaking, chat, join-request approvals, payments, review submission, push notifications, or booking integrations — roadmap only (some appear in the planning notes file `subIn/gameon-project.md`, which is not part of the shipped app).
- Duplicate `GET /events/{event_id}/participants` definition in `routers/events.py` (identical; harmless, should be deduped).
- CI references Coolify webhooks, Sentry releases, and Android builds needing secrets/variables; deployment was not verified for this submission.

Sensible next steps: secure token storage + refresh flow, organizer join-request approvals, teams/matchmaking/chat, venue reviews, push notifications, cost-splitting, real Alembic migrations.

## License

MIT — see [LICENSE](./LICENSE) (Copyright (c) 2026 Muhammed Fahad T).
