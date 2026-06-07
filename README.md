# MFS Unified

A single Android wallet that unifies Bangladesh's three mobile financial
services — **bKash**, **Nagad**, and **Rocket** — behind one clean UI,
one contact list, and one transaction history.

> **Phase:** B (MVP build)
> **Stack:** Flutter (Android-only) · Node.js · TypeScript · Express · Prisma · PostgreSQL 16 · Redis 7
> **Status:** see [`TASKS.md`](./TASKS.md)

---

## Why this project exists

Bangladeshi users routinely juggle three separate MFS apps with
different UIs, QR formats, and transaction histories. MFS Unified gives
them:

- One QR scanner that recognises any of the three providers' codes.
- One contact list with provider tags.
- One transaction history persisted locally and synced to the cloud.
- One auth flow (biometric + app-unlock PIN).

## What this project is NOT

- **Not** a bank, e-wallet, or licensed financial institution.
- **Not** storing or transmitting any provider's PIN.
- **Not** automating USSD sessions.
- **Not** available on iOS, web, or desktop in Phase B.

---

## Architecture at a glance

```text
┌──────────────────────────────────┐
│  Flutter client (Android only)   │  Riverpod · Isar · go_router · freezed
│  core / domain / data / pres.    │  ProviderIntegrationService (Dart)
└──────────────┬───────────────────┘
               │ HTTPS · JWT · Zod schemas
┌──────────────▼───────────────────┐
│  Express backend (Node/TS)       │  Prisma ORM · Zod · JWT · bcrypt
│  modules: auth · contacts · pay  │  Provider adapters (TS interface)
│  Redis · PostgreSQL              │  pino logs · PII mask
└──────────────────────────────────┘
```

Full details:

- [`ARCHITECTURE_DECISIONS.md`](./ARCHITECTURE_DECISIONS.md) — stack choices + variances.
- [`SYSTEM_ARCHITECTURE.md`](./SYSTEM_ARCHITECTURE.md) — clean-layer breakdown + backend layout.
- [`BACKEND_STACK_ANALYSIS.md`](./BACKEND_STACK_ANALYSIS.md) — why Node/TS over FastAPI.
- [`FEASIBILITY_REVIEW.md`](./FEASIBILITY_REVIEW.md) — verified Android + provider capabilities.
- [`SECURITY_REVIEW.md`](./SECURITY_REVIEW.md) — threat model and controls.
- [`RISK_REGISTER.md`](./RISK_REGISTER.md) — delivery + security risks.
- [`TASKS.md`](./TASKS.md) — Phase B task board.

## Quick start (Docker)

```bash
cp .env.example .env          # edit as needed
docker compose up --build     # starts backend + postgres + redis
```

Backend is exposed on `http://localhost:4000` (see `.env.example`).

### Run Flutter in CI

No local SDK is required for the MVP workflow — GitHub Actions builds
the release APK via `.github/workflows/android.yml`.

To build locally (optional):

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

## Repository layout

```text
.
├── mobile/                # Flutter Android client
├── backend/               # Node.js + TypeScript + Express + Prisma
├── docs/                  # design tokens, ADRs
├── stitch_unified_mfs_wallet/   # source Stitch designs (Phase A input)
├── .github/workflows/     # android.yml, backend.yml
├── docker-compose.yml
└── AGENTS.md              # Qoder CLI session-start instructions
```

## Hard rules

These are non-negotiable. See [`AGENTS.md`](./AGENTS.md) for the full list.

1. Provider PINs are **never** stored, processed, or transmitted by MFS Unified.
2. No USSD automation (`BIND_ACCESSIBILITY_SERVICE` is forbidden).
3. No `CALL_PHONE` or `READ_SMS` permissions.
4. Android-only in Phase B.
5. No `setState` in screens — Riverpod only.
6. No `any` in TypeScript — ESLint strict.
7. Phone numbers, OTPs, tokens are never logged in plaintext.

## License

Private — © 2026 MFS Unified. All rights reserved.
