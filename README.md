# Welrent Act — Flutter Web Migration

## Overview

This is a genuine Flutter Web application that migrates the frontend of the Welrent Act PHP/Next.js system (https://github.com/welrent/Act).

The Flutter app preserves the original design, user experience, features, and business workflows, and connects to the existing PHP backend API.

## Architecture

- **Frontend**: Flutter Web (Dart), compiled to static HTML/JS/CSS
- **Routing**: `go_router` — mirrors original Next.js/PHP routes
- **State Management**: `provider` (ChangeNotifier) — `AppState` holds `AuthService` + `ApiClient`
- **API Client**: `http` package — calls PHP JSON endpoints (no direct DB access)
- **Theme**: Custom `ThemeData` matching original design tokens (Inter font, color palette, spacing)
- **Auth**: `AuthService` with demo mode (no Firebase required) + Firebase-ready hook

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
    auth_service.dart    # Auth state (demo + Firebase ready)
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
| 3 | `/agreements` | Agreements listing with Read links | `GET /api/admin/pages` |
| 4 | `/contracts/:ref` | Contract detail with full HTML content | `GET /api/contracts/[ref]` |
| 5 | `/profile` | My profile + contracts list | `GET /api/contracts?uid=` |
| 6 | `/portal/:username` | Portal profile (auth-gated) | — |
| 7 | `/secret-panel` | Control panel (admin/worker) | — |
| 8 | `/secret-panel/settings` | Company settings (placeholder replacement) | `GET/POST /api/admin/settings` |
| 9 | `/secret-panel/editor` | Site text editor (HTML) | `GET/POST /api/admin/pages` |
| 10 | Login modal | Email/password sign-in (demo mode) | `POST /api/auth/session` |
| 11 | Search (header) | Debounced search across pages/agreements/contracts | `GET /api/search?q=` |
| 12 | Footer | Cookie consent + language switcher | — |
| 13 | Sidebar | Role-based navigation (admin/worker see admin tools) | — |

## PHP Endpoints Reused

All existing PHP API contracts are preserved:
- `POST /api/sso/verify`, `POST /api/sso/logout`
- `GET/POST /api/contracts`, `GET /api/contracts/[ref]`
- `POST/DELETE /api/auth/session`
- `GET /api/search?q=`
- `GET/POST /api/admin/pages`, `GET/POST /api/admin/settings`

## Design Fidelity

Design tokens extracted from the original Next.js app (`globals.css`, `header-styles.css`, `editor-styles.css`):
- Colors: `#2D3ED2` primary, `#2F214B` design text, `#8C8C91` muted, `#F9FAFB` card bg, `#8EB9FF` hero accent
- Typography: Inter font family
- Layout: 1050px max-width centered, 220px sidebar, 800px content wrapper
- Responsive: Sidebar becomes horizontal sticky on mobile (<768px)
- Components: Design message cards, rental pills, gradient buttons, cookie banner

## Build Instructions

### Prerequisites
- Flutter SDK (tested with Flutter 3.24.5 on macOS 13.7)
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

## Known Limitations

1. **Firebase Auth not configured**: The app runs in demo mode. Firebase credentials are not in the repository. Configure `firebase_auth` for production email/password + Google SSO.

2. **PHP backend not running locally**: API integration can't be end-to-end tested without a PHP server + MySQL database. The API client is wired to real endpoints but unverified against a live backend.

3. **CORS required**: PHP backend must emit CORS headers for the Flutter origin.

4. **HTML rendering**: The contract/page HTML content uses a simple tag stripper (not a full HTML renderer). Complex HTML may not render perfectly.

5. **Neon Postgres**: The task references a Neon project, but the existing PHP app uses MySQL/MariaDB. No database migration was performed.

6. **Milkadmin secret-panel**: The separate `/secret-panel/` (Milkadmin PHP control panel) is not part of the Flutter migration.

## Backend Configuration

The existing PHP `config.vault.ini` holds database credentials. Do not expose these in Flutter code. The Flutter app only calls JSON API endpoints.
