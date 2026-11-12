# Welrent Act — Flutter Web Environment Configuration

## API Base URL

The Flutter frontend calls the JSON API in this repository (`npm start`, port 8787). The base URL is configurable:

| Method | Variable | Description |
|--------|----------|-------------|
| Dart define | `--dart-define=API_BASE_URL=https://act.welrent.com` | Set at build time |
| Environment | `API_BASE_URL` | Read at runtime via `String.fromEnvironment` |

Default: `http://127.0.0.1:8787` (local API)

### Build with production API URL

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://act.welrent.com
```

## CORS

The Hono API allows browser calls from the Flutter web origin, including `Authorization`.

## Authentication

`POST /api/auth/login` checks the email and password against the `users` table. A wrong password returns 401. The client stores the bearer token and sends `Authorization` on later requests. Addresses ending in `@id.welrent.com`, plus `welrent.business@gmail.com`, receive the admin role. Rows in `workers` receive the worker role.

## Backend Endpoints Reused

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/contracts` | GET | List contracts (by uid) |
| `/api/contracts` | POST | Create contract |
| `/api/contracts/[ref]` | GET | Get single contract |
| `/api/auth/login` | POST | Email and password; returns a bearer token |
| `/api/auth/session` | DELETE | Logout |
| `/api/pages` | GET | Public legal pages |
| `/api/site-settings` | GET | Public placeholder values |
| `/api/search?q=` | GET | Search pages/agreements/contracts |
| `/api/admin/pages` | GET | List pages (admin) |
| `/api/admin/pages` | POST | Update page content (admin) |
| `/api/admin/settings` | GET | List settings (admin) |
| `/api/admin/settings` | POST | Update settings (admin) |

## Database

No direct database access from Flutter. The API uses the pooled `DATABASE_URL` in `.env` (Lakebase Postgres, database `welrent`) through `pg`, with a pool size of 5. Schema creation is additive (`CREATE TABLE IF NOT EXISTS`) and matches the tables already on the branch.

## Build & Deploy

```bash
# Get dependencies
flutter pub get

# Build for web (release)
flutter build web --release

# Output: build/web/ — deploy to any static host (Netlify, Vercel, S3, etc.)
```

## Neon

`neon.ts` declares the AI Gateway, a private `actfiles` bucket, and the `actapi` function (`functions/api/index.ts`). `neon init` wrote `.neon` for org `org-broad-bread-03975055`, project `royal-bread-75421306`, branch `production`. Deploying that function needs `neon login` first. Until then, run the same Hono app locally with `npm start`. Object storage uses the S3-compatible endpoint with `forcePathStyle: true`.
