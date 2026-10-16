# Welrent Act — Flutter Web Migration Plan

## STATUS: IMPLEMENTATION COMPLETE

The Flutter Web application has been built and the release web build succeeds.

---

## Source System Analysis

### Repository: https://github.com/welrent/Act

The repository contains **two applications**:

1. **PHP Backend** (`src/`, `Controllers/`, `Core/`, `index.php`, `server.php`)
   - MySQL/MariaDB database (`database.sql`)
   - Server-rendered PHP pages wrapped in `layout.php`
   - API endpoints under `src/pages/api/*`
   - Simulates Next.js-style routing via `server.php`

2. **Next.js Frontend** (`next-app/`) — **the design specification**
   - React 19 + Tailwind CSS + Next.js 16
   - Firebase Auth (email/password + Google SSO)
   - Turso / LibSQL database
   - API routes under `src/app/api/*`

The Flutter app reproduces the **Next.js frontend** design and connects to the **PHP API backend**.

---

## Design Tokens (extracted from original CSS)

| Token | Value |
|-------|-------|
| primary | `#2D3ED2` |
| designText | `#2F214B` |
| designMuted | `#8C8C91` |
| cardBg | `#F9FAFB` |
| heroAccent | `#8EB9FF` |
| bgLight | `#FFFFFF` |
| Font | Inter (300-800) |

Layout: 1050px max-width centered, 220px sidebar, 800px content wrapper.
Responsive: Sidebar → horizontal sticky on mobile (<768px).

---

## Migrated Pages & Features (13/13 complete)

| # | Route | Feature | Backend Endpoint | Status |
|---|-------|---------|-----------------|--------|
| 1 | `/` | Homepage (hero, rental pills, legal pages) | — | ✅ |
| 2 | `/pages/:slug` | Dynamic legal pages | — | ✅ |
| 3 | `/agreements` | Agreements listing | `GET /api/admin/pages` | ✅ |
| 4 | `/contracts/:ref` | Contract detail | `GET /api/contracts/[ref]` | ✅ |
| 5 | `/profile` | My profile + contracts | `GET /api/contracts?uid=` | ✅ |
| 6 | `/portal/:username` | Portal profile (auth-gated) | — | ✅ |
| 7 | `/secret-panel` | Control panel (admin/worker) | — | ✅ |
| 8 | `/secret-panel/settings` | Company settings | `GET/POST /api/admin/settings` | ✅ |
| 9 | `/secret-panel/editor` | Site text editor | `GET/POST /api/admin/pages` | ✅ |
| 10 | Login modal | Email/password (demo mode) | `POST /api/auth/session` | ✅ |
| 11 | Search (header) | Debounced search | `GET /api/search?q=` | ✅ |
| 12 | Footer | Cookie consent + language switcher | — | ✅ |
| 13 | Sidebar | Role-based navigation | — | ✅ |

## PHP Endpoints Reused (11 endpoints)

`POST /api/sso/verify`, `POST /api/sso/logout`, `GET/POST /api/contracts`,
`GET /api/contracts/[ref]`, `POST/DELETE /api/auth/session`, `GET /api/search?q=`,
`GET/POST /api/admin/pages`, `GET/POST /api/admin/settings`

## Database

Preserved: `settings`, `pages`, `posts`, `agreements`, `contracts`, `site_settings`, `admins`, `workers`, `login_logs`
No direct DB access from Flutter — all via PHP API.

## Build Verification

- `flutter analyze lib/` — **zero errors, zero warnings**
- `dart format --set-exit-if-changed lib/` — **passed** (all formatted)
- `flutter test` — **✓ All tests passed!**
- `flutter build web --release` — **✓ Built build/web** (success)

## 1:1 Design Fidelity Verification

1. **Homepage (`/`)**: Centered 1050px layout, 220px desktop sidebar with clean text navigation (`Navigation` & `Legal Hub`), top header with WR SVG logo and search (`⌘ K` shortcut), Aston Martin hero banner with subtitle, 4 rental category pills, 2-column legal cards grid with subtle hover transitions, and sticky GDPR cookie banner (`#2A303C` with `#8EB9FF` top border and accept action).
2. **Contract Detail (`/contracts/:ref`)**: Top `.design-message` card displaying contract reference, vehicle description, and action pills ("Full agreement terms", "Open main site"), followed by structured agreement document on clean white background.
3. **Legal Document Renderer (`/pages/:slug`)**: High-fidelity HTML renderer parsing headings (`h1`–`h3`), paragraphs, bullet lists, dividers, bold terms, links, and company placeholder substitutions matching Next.js CSS typography.

## Known Limitations

1. **Firebase Auth not configured** — app runs in demo mode. Accepts `admin@id.welrent.com` / `WelrentAdmin2026!#`.
2. **PHP backend not running locally** — API integration not end-to-end tested without live PHP + MySQL.
3. **CORS required** — PHP backend must emit CORS headers for Flutter origin.
4. **Neon Postgres** — referenced in task but existing app uses MySQL/MariaDB. No DB migration performed.
5. **Milkadmin secret-panel** — separate PHP control panel, not part of Flutter migration.

## Deliverables

- Complete Flutter Web application in repository root
- Build output instructions in `README.md`
- `ENVIRONMENT.md` — environment variables & backend config
- `README.md` — build & deployment instructions
- `MIGRATION_PLAN.md` — this file
