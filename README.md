# Welrent Act — Flutter Web Migration

## Overview

This is a genuine Flutter Web application that migrates the frontend of the Welrent Act PHP/Next.js system (https://github.com/welrent/Act).

The Flutter app preserves the original design, user experience, features, and business workflows. It talks to a JSON API in this repository. The API stores data in Lakebase Postgres and files in Neon Object Storage. The Flutter client never opens a database connection.

## Architecture

- **Frontend**: Flutter Web (Dart), compiled to static HTML/JS/CSS
- **Routing**: `go_router` — mirrors original Next.js/PHP routes
- **State Management**: `provider` (ChangeNotifier) — `AppState` holds `AuthService` + `ApiClient`
- **API Client**: `http` package — calls the JSON API (no direct DB access)
- **Theme**: Custom `ThemeData` matching original design tokens (Inter font, color palette, spacing)
- **Auth**: email and password checked by `POST /api/auth/login`; the client stores a bearer token

## Project Structure

```
lib/
  main.dart              # Entry point + GoRouter config
  theme/
    colors.dart          # Design tokens from original CSS
    app_theme.dart       # ThemeData
  models/
    user.dart            # AppUser model
    contract.dart        # Contract model
    page.dart            # PageItem, SiteSetting, Agreement
  providers/
    app_state.dart       # Combined state (auth + data)
  services/
    api_client.dart      # HTTP API client
    auth_service.dart    # Email/password sessions against the API
  widgets/
    layout/
      app_scaffold.dart  # Sidebar + Header + Footer layout
      sidebar.dart       # Role-based navigation
      header.dart        # Logo, search, user menu
      footer.dart        # Language switcher, cookie consent
      login_modal.dart   # Email/password login modal
    design_message.dart  # DesignMessage, RentalCardPill, GradientButton, StatusBanner
  screens/
    home.dart            # / — Homepage
    agreements.dart      # /agreements — Agreements listing
    page_detail.dart     # /pages/:slug — Dynamic page
    contract_detail.dart # /contracts/:ref — Contract detail
    profile.dart         # /profile — My profile + contracts
    portal.dart          # /portal/:username — Portal profile
    secret_panel.dart    # /secret-panel — Control panel
    settings.dart        # /secret-panel/settings — Company settings
    editor.dart          # /secret-panel/editor — Site text editor
assets/
  img/                   # Reused original branding assets
web/
  index.html             # HTML entry point
```

## Migrated Pages & Features

| # | Route | Feature | Backend Endpoint |
|---|-------|---------|-----------------|
| 1 | `/` | Homepage with hero banner, rental pills, legal pages | — |
| 2 | `/pages/:slug` | Dynamic legal pages (terms, privacy, cookie, accessibility, agreements) | — |
| 3 | `/agreements` | Agreements listing with Read links | `GET /api/pages` |
| 4 | `/contracts/:ref` | Contract detail with full HTML content | `GET /api/contracts/[ref]` |
| 5 | `/profile` | My profile + contracts list | `GET /api/contracts?uid=` |
| 6 | `/portal/:username` | Portal profile (auth-gated) | — |
| 7 | `/secret-panel` | Control panel (admin/worker) | — |
| 8 | `/secret-panel/settings` | Company settings (placeholder replacement) | `GET/POST /api/admin/settings` |
| 9 | `/secret-panel/editor` | Site text editor (HTML) | `GET/POST /api/admin/pages` |
| 10 | Login modal | Email/password sign-in (wrong passwords fail) | `POST /api/auth/login` |
| 11 | Search (header) | Debounced search across pages/agreements/contracts | `GET /api/search?q=` |
| 12 | Footer | Cookie consent + language switcher | — |
| 13 | Sidebar | Role-based navigation (admin/worker see admin tools) | — |

## API Endpoints

The Hono API keeps the JSON shapes the Flutter client already used, and adds public reads:
- `GET /api/health`
- `POST /api/auth/login`, `GET /api/auth/me`, `DELETE /api/auth/session`
- `GET/POST /api/contracts`, `GET /api/contracts/:ref` (create is idempotent on `booking_ref`)
- `GET /api/pages`, `GET /api/pages/:slug`, `GET /api/site-settings`
- `GET /api/search?q=`
- `GET/POST /api/admin/pages`, `GET/POST /api/admin/settings` (staff bearer token)
- `POST /api/contact`, `POST /api/uploads`, `POST /api/ai/summarize`

## Design Fidelity

Design tokens extracted from the original Next.js app (`globals.css`, `header-styles.css`, `editor-styles.css`):
- Colors: `#2D3ED2` primary, `#2F214B` design text, `#8C8C91` muted, `#F9FAFB` card bg, `#8EB9FF` hero accent
- Typography: Inter font family
- Layout: 1050px max-width centered, 220px sidebar, 800px content wrapper
- Responsive: Sidebar becomes horizontal sticky on mobile (<768px)
- Components: Design message cards, rental pills, gradient buttons, cookie banner

## Build Instructions

### Prerequisites
- Flutter SDK (release web build verified with Flutter 3.50.0 / Dart 3.14.0)
- Node.js 22 for the API (`npm run build`, `npm start`)
- Chrome for web development

### Local Development

```bash
flutter pub get
flutter run -d chrome --web-port=3001
```

### Production Build

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://act.welrent.com
```

Output: `build/web/` — deploy to any static hosting provider.

### Analysis & Formatting

```bash
flutter analyze
dart format lib/
```

## API

```bash
cp .env.example .env   # then fill in DATABASE_URL and storage keys
npm install
npm run build
npm run seed
npm start              # http://127.0.0.1:8787
npm run test:api
```

`neon init` links project `royal-bread-75421306` on branch `production`. `neon deploy` needs `neon login`; until then the API runs locally against the supplied pooled `DATABASE_URL`. The AI Gateway returns 503 until `NEON_AI_GATEWAY_TOKEN` is present.

## Known Limitations

1. **Google sign-in and password reset** still need an identity provider. Email and password sign-in uses the API.

2. **HTML rendering** uses a tag-aware widget renderer. Nested tables and custom CSS from the original documents are simplified.

3. **AI Gateway** is declared in `neon.ts` but not provisioned until `neon login` and `neon deploy` succeed.

4. **Milkadmin secret-panel** PHP control panel is represented by the Flutter secret-panel screens, not the original PHP app.

## Backend Configuration

Copy `.env.example` to `.env`. Do not commit `.env`. The Flutter app only calls JSON API endpoints.
