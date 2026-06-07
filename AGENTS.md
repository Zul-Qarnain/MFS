# MFS UNIFIED — Agent Instructions

This file is loaded by Qoder CLI at session start. It captures the
project's durable context so a fresh session can resume work without
re-reading every architectural document.

**Read these documents before making any code change:**

1. `ARCHITECTURE_DECISIONS.md` — the source of truth for stack choices
   and variances.
2. `SYSTEM_ARCHITECTURE.md` — Flutter clean layers + Node/Express backend
   layout.
3. `SECURITY_REVIEW.md` — non-negotiable security rules.
4. `FEASIBILITY_REVIEW.md` — verified provider-integration facts.
5. `RISK_REGISTER.md` — tracked risks with mitigations.
6. `TASKS.md` — current Phase B task board.

---

## Stack (locked for Phase B)

| Layer | Technology |
|---|---|
| Mobile client | Flutter (Android only), Dart, Riverpod, Isar, go_router, freezed |
| Backend runtime | Node.js 20 LTS + TypeScript (strict mode) |
| Web framework | Express.js |
| ORM | Prisma |
| Database | PostgreSQL 16 |
| Cache / rate-limit | Redis 7 + `express-rate-limit` + `rate-limit-redis` + `ioredis` |
| Validation | Zod (`.strict()` on all schemas) |
| Auth | JWT (`jsonwebtoken`) + bcrypt + device binding |
| Logging | `pino` structured logs with PII-mask middleware |
| CI/CD | GitHub Actions (`android.yml`, `backend.yml`) |
| Containerisation | Docker Compose (backend + Postgres + Redis) |

## Hard rules — never violate

1. **Provider PINs are never stored, processed, or transmitted by MFS
   Unified.** No field, variable, log, column, or DTO may carry them.
   The 4–6 digit PIN users enter for bKash/Nagad/Rocket lives inside
   the provider's own checkout flow or USSD session.
2. **No USSD automation.** No `BIND_ACCESSIBILITY_SERVICE` in the
   AndroidManifest. Dialer pass-through only (`ACTION_DIAL` +
   `tel:...` with `#` URL-encoded).
3. **No `CALL_PHONE` or `READ_SMS` permissions.** Only `RECEIVE_SMS` is
   declared, for OTP autofill via the SMS Retriever API.
4. **Android-only.** No iOS, macOS, web, Windows, or Linux targets in
   Phase B.
5. **No `setState` in screens.** State flows through Riverpod.
6. **No `any` in TypeScript.** ESLint `@typescript-eslint/no-explicit-any`
   is enforced.
7. **Secure logging.** Phone numbers, OTP codes, auth tokens, and
   provider credentials are never logged in plaintext.

## Provider abstraction contract

All three providers sit behind one Dart interface on the client and one
TypeScript interface on the backend:

```text
initiate(req)        → PaymentInitiation
pollStatus(id)       → PaymentStatus
fetchReceipt(id)     → PaymentReceipt
launchDialerPassThrough(req)   # fallback
```

| Provider | Phase B adapter status |
|---|---|
| bKash | LIVE for Tokenized Checkout merchant payments; MOCK + dialer for P2P/Cash Out |
| Nagad | MOCK (swap to live once merchant credentials are onboarded) |
| Rocket | MOCK (swap to live once DBBL exposes API) |

Adapters are swapped without touching screens or repositories.

## Current state

- Phase A: complete (5 design docs written).
- Architecture change (2026-06-07): FastAPI → Node.js/TypeScript/Express/Prisma.
- Phase B: not yet started. Awaiting user approval to run `git init`,
  push to `git@github.com:Zul-Qarnain/MFS.git`, and begin the build
  order in `TASKS.md`.

## Repository

- Remote: `git@github.com:Zul-Qarnain/MFS.git`
- Primary branch: `main`
- Initial commit message pattern: `feat: initialize project files and pipelines`

## Workflow for this session

Before starting any Phase B task:

1. Open `TASKS.md` and mark the task `🔧 IN PROGRESS`.
2. Implement against the contract in `SYSTEM_ARCHITECTURE.md`.
3. Run the relevant checks (`flutter analyze`, `npm run lint`, `vitest`,
   `tsc --noEmit`).
4. Mark the task `✅ DONE` in `TASKS.md`.
5. Update `ARCHITECTURE_DECISIONS.md` only if a new variance from the
   plan is introduced.
