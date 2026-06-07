# MFS UNIFIED — Task Tracker

**Maintained throughout Phase B.** Each task is tagged with its section
in `PROJECT_BRIEF.md` and marked with its current status.

Statuses: `✅ DONE` · `🔧 IN PROGRESS` · `⏳ TODO` · `⏸️ DEFERRED`.

---

## Phase A — Architecture Review & Discovery

| # | Task | Status |
|---|---|---|
| A1 | Research Android deep links, provider integrations, Play Store policy | ✅ DONE |
| A2 | Write `FEASIBILITY_REVIEW.md` | ✅ DONE |
| A3 | Write `SYSTEM_ARCHITECTURE.md` | ✅ DONE |
| A4 | Write `BACKEND_STACK_ANALYSIS.md` | ✅ DONE |
| A5 | Write `SECURITY_REVIEW.md` | ✅ DONE |
| A6 | Write `RISK_REGISTER.md` | ✅ DONE |
| A7 | Architecture change: switch backend to Node.js + TypeScript + Express + Prisma | ✅ DONE |

---

## Phase B — MVP Code Generation

### B1 — Repository & infra

| # | Task | Status | Ref |
|---|---|---|---|
| B1.1 | `git init`, `git remote add origin git@github.com:Zul-Qarnain/MFS.git`, initial commit on `main` | ✅ DONE | BRIEF §7.1 |
| B1.2 | Root-level README with project overview | ✅ DONE | BRIEF §7.4 |
| B1.3 | `.gitignore`, `.env.example`, `.editorconfig` | ✅ DONE | — |
| B1.4 | `docker-compose.yml` (Postgres 16, Redis 7, backend, Flutter build sidecar) | ✅ DONE | BRIEF §9 |
| B1.5 | GitHub Actions: `android.yml` + `backend.yml` | ✅ DONE | BRIEF §5 |

### B2 — Design tokens

| # | Task | Status | Ref |
|---|---|---|---|
| B2.1 | Extract colors, typography, spacing from `stitch_unified_mfs_wallet/` | ✅ DONE | BRIEF §3.3 |
| B2.2 | Write `docs/design_tokens.md` | ✅ DONE | BRIEF §8.5 |
| B2.3 | Generate `mobile/lib/core/constants/app_colors.dart` | ✅ DONE | — |
| B2.4 | Generate `mobile/lib/core/constants/app_typography.dart` | ✅ DONE | — |
| B2.5 | Generate `mobile/lib/core/constants/app_constants.dart` | ✅ DONE | — |
| B2.6 | Generate `mobile/lib/core/theme/app_theme.dart` | ✅ DONE | — |

### B3 — Backend (Node.js + TypeScript + Express + Prisma)

| # | Task | Status | Ref |
|---|---|---|---|
| B3.1 | Scaffold `backend/` (tsconfig, eslint, prettier, vitest) | ✅ DONE | BACKEND_STACK §5 |
| B3.2 | `prisma/schema.prisma` with User, Device, Provider, UserProvider, Contact, Transaction, OtpSession | ✅ DONE | BRIEF §4.1 |
| B3.3 | Prisma seed script (`prisma/seed.ts`) | ✅ DONE | — |
| B3.4 | Core middleware: `helmet`, `cors`, `pino`, `express-rate-limit`, `errorHandler`, `piiMask`, `authMiddleware` | ✅ DONE | SECURITY_REVIEW §6, §9 |
| B3.5 | `config/env.ts` — Zod-validated environment schema | ✅ DONE | — |
| B3.6 | Auth module: `/register`, `/verify-otp`, `/set-pin`, `/login`, `/refresh` | ✅ DONE | BRIEF §4.2 |
| B3.7 | Contacts module: CRUD with Zod validation | ⏳ TODO (validation sprint follow-up) | BRIEF §4.2 |
| B3.8 | Payments module: `/initiate`, `/status`, `/receipt` | ✅ DONE | BRIEF §4.2 |
| B3.9 | Provider abstraction: `provider.interface.ts`, `bkash.adapter.ts`, `nagad.adapter.ts`, `rocket.adapter.ts` | ✅ DONE | FEASIBILITY §5 |
| B3.10 | JWT service + device-binding logic | ✅ DONE | SECURITY_REVIEW §5 |
| B3.11 | bcrypt PIN hashing (app-unlock PIN only — never provider PIN) | ✅ DONE | SECURITY_REVIEW §3 |
| B3.12 | Redis client + rate-limit config | ✅ DONE | SECURITY_REVIEW §6 |
| B3.13 | Dockerfile + build pipeline | ✅ DONE | BRIEF §9 |
| B3.14 | Tests (vitest) for piiMask, deviceBinding, auth schemas | ✅ DONE | — |

### B4 — Mobile (Flutter)

| # | Task | Status | Ref |
|---|---|---|---|
| B4.1 | Flutter project manifest (`pubspec.yaml`) with Android-only platforms | ✅ DONE | BRIEF §1 |
| B4.2 | `pubspec.yaml` — exact package list from BRIEF §3.1 | ✅ DONE | BRIEF §3.1 |
| B4.3 | `AndroidManifest.xml` permissions — CAMERA, BIOMETRIC, INTERNET, VIBRATE, NETWORK_STATE, RECEIVE_SMS. **NO** `CALL_PHONE`, `READ_SMS`, `BIND_ACCESSIBILITY_SERVICE`. | ✅ DONE | BRIEF §3.2 |
| B4.4 | `core/constants/` — `app_colors.dart`, `app_typography.dart`, `app_constants.dart` | ✅ DONE (B2) | BRIEF §3.3 |
| B4.5 | `core/security/` — `pin_hasher.dart`, `biometric_service.dart`, `device_fingerprint.dart` | ✅ DONE | SECURITY_REVIEW §3, §5 |
| B4.6 | `core/providers/` — provider integration service + 3 adapters | ✅ DONE | SYSTEM_ARCH §3 |
| B4.7 | `data/datasources/` — remote (Retrofit), local (Isar), secure (SecureKeyValueStore) | ✅ DONE | SYSTEM_ARCH §1.3 |
| B4.8 | `domain/` — entities (`Transaction`, `Contact`), repositories (abstract), value objects (`Money`, `PhoneNumber`, `ProviderId`) | ✅ DONE | SYSTEM_ARCH §1.2 |
| B4.9 | `presentation/router/` — `go_router` setup | ✅ DONE | SYSTEM_ARCH §1.4 |
| B4.10 | `presentation/providers/` — Riverpod providers (`@riverpod`) | ✅ DONE | SYSTEM_ARCH §5 |
| B4.11 | Screens: Home, QrScanner, PaymentDetails, Authentication, Processing, Success — **placeholders only** | ✅ DONE (scaffold) | BRIEF §3.4 |
| B4.12 | Amount formatting via `intl` (`৳1,500.00`) — `Money.format()` | ✅ DONE | BRIEF §3.6 |
| B4.13 | `flutter analyze` zero errors gate (CI) | ✅ DONE (wired) | BRIEF §9 |

---

## Validation Sprint (post-scaffold)

These items build real behaviour into the placeholder scaffolding.

| # | Task | Status |
|---|---|---|
| V1 | QR Scanner Screen — camera preview via `mobile_scanner`, overlay UI | ✅ DONE |
| V2 | QR Parsing Logic — extract provider, phone, amount, merchant from QR payload | ✅ DONE |
| V3 | Provider Selection Screen — Riverpod state, tappable chip list | ✅ DONE |
| V4 | Authentication Screen UI — PIN keypad + biometric button + error states | ✅ DONE |
| V5 | Local Transaction Storage — full Isar read/write + stream to Recent Transactions | ✅ DONE |
| V6 | Provider Abstraction Layer — integration tests against mock adapters | ✅ DONE |
| V7 | Mock bKash Adapter — deterministic success/failed scenarios | ✅ DONE |
| V8 | Mock Nagad Adapter — same | ✅ DONE |
| V9 | Mock Rocket Adapter — same | ✅ DONE |

**Excluded from sprint:** AI agents, fraud detection, analytics, monitoring, USSD automation, accessibility services.

### B5 — Documentation & handover

| # | Task | Status | Ref |
|---|---|---|---|
| B5.1 | `README.md` setup steps | ⏳ TODO | BRIEF §8.14 |
| B5.2 | `ARCHITECTURE_DECISIONS.md` populated | ✅ DONE | BRIEF §7.4 |
| B5.3 | `TASKS.md` finalized | ✅ DONE | BRIEF §7.3 |

---

## Deferred (Phase 2+)

| Task | Reason |
|---|---|
| AI fraud-analytics pipeline | Out of MVP scope (BRIEF §Phase B deferrals) |
| Automated multi-step USSD orchestration | Play Store + OEM risk too high (FEASIBILITY §1.3, RISK_REGISTER R-MIG-03) |
| iOS build targets | Out of scope (BRIEF §1) |
| Rocket / Nagad live adapter integration | Pending merchant onboarding (RISK_REGISTER R-PRV-01, R-PRV-02) |

---

## Change Log

| Date | Entry |
|---|---|
| 2026-06-07 | Phase A completed; 5 docs written. |
| 2026-06-07 | Architecture change request: backend switched from FastAPI + SQLAlchemy to Node.js + TypeScript + Express + Prisma. `BACKEND_STACK_ANALYSIS.md`, `SYSTEM_ARCHITECTURE.md`, `SECURITY_REVIEW.md` updated. `TASKS.md` + `ARCHITECTURE_DECISIONS.md` created. |
| 2026-06-07 | B1 (repo + infra) + B2 (design tokens) + B3 (backend scaffold) committed as `f2a09ed`. |
| 2026-06-07 | B4 (Flutter scaffold) complete: `pubspec.yaml`, AndroidManifest, core/{network,security,errors,providers}, domain/{entities,value_objects,repositories}, data/{datasources,repositories}, presentation/{router,providers,screens}, main.dart, two unit tests. Placeholder screens await validation sprint. |
| 2026-06-07 | Validation sprint (V1–V9) complete: QR scanner with camera preview + overlay, QR parser (EMVCo TLV + provider URLs + plain phone), provider selection strip with Riverpod state, authentication screen (PIN keypad + biometric + confirm-PIN flow), Isar-backed transaction stream on home screen, payment details screen wired to provider strip, mock adapter tests for bKash/Nagad/Rocket (merchant + P2P + pollStatus). |
