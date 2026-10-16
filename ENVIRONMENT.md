# Welrent Act — Flutter Web Environment Configuration

## API Base URL

The Flutter frontend calls the existing PHP backend API. The base URL is configurable:

| Method | Variable | Description |
|--------|----------|-------------|
| Dart define | `--dart-define=API_BASE_URL=https://act.welrent.com` | Set at build time |
| Environment | `API_BASE_URL` | Read at runtime via `String.fromEnvironment` |

Default: `http://127.0.0.1:3000` (local development)

### Build with production API URL

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://act.welrent.com
```

## CORS (PHP Backend)

The PHP API routes must allow cross-origin requests from the Flutter frontend origin. Add CORS headers to your PHP API endpoints:

```php
header('Access-Control-Allow-Origin: *'); // or your specific Flutter origin
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

## Authentication

The Flutter app supports two auth modes:

1. **Demo mode** (no Firebase credentials): Accepts `admin@id.welrent.com` / `WelrentAdmin2026!#` and any `@id.welrent.com` email as admin. Other emails create a regular user.

2. **Firebase mode**: When Firebase is configured, use `firebase_auth` web SDK for email/password + Google sign-in, then sync the role via `POST /api/auth/session`.

## Backend Endpoints Reused

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/contracts` | GET | List contracts (by uid) |
| `/api/contracts` | POST | Create contract |
| `/api/contracts/[ref]` | GET | Get single contract |
| `/api/auth/session` | POST | Create session from Firebase token |
| `/api/auth/session` | DELETE | Logout |
| `/api/search?q=` | GET | Search pages/agreements/contracts |
| `/api/admin/pages` | GET | List pages (admin) |
| `/api/admin/pages` | POST | Update page content (admin) |
| `/api/admin/settings` | GET | List settings (admin) |
| `/api/admin/settings` | POST | Update settings (admin) |

## Database

No direct database access from Flutter. All DB access remains on the PHP server side. The existing MySQL/MariaDB schema is preserved.

## Build & Deploy

```bash
# Get dependencies
flutter pub get

# Build for web (release)
flutter build web --release

# Output: build/web/ — deploy to any static host (Netlify, Vercel, S3, etc.)
```

## Neon Integration (Optional)

The task references a Neon Postgres project. The existing PHP app uses MySQL/MariaDB. No database migration is performed without explicit approval. If you wish to migrate the backend to Neon Postgres, that is a separate backend task outside the Flutter frontend scope.
