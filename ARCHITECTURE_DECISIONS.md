# MFS UNIFIED — Architecture Decisions

A running record of important technical directions, framework choices,
design compromises, and variances from the initial plan.

Each decision is logged in the format:

* **ID** — stable reference
* **Date** — when the decision was made
* **Decision** — the choice
* **Context** — the trade-offs considered
* **Consequences** — what this implies for Phase B and beyond

---

## AD-001 — Provider abstraction over three MFS providers

* **Date:** 2026-06-07
* **Decision.** The Flutter client never talks to bKash, Nagad, or Rocket
  directly. All three sit behind a single
  `ProviderIntegrationService` with a uniform adapter contract
  (`initiate`, `pollStatus`, `fetchReceipt`, `launchDialerPassThrough`).
* **Context.** Each provider has a different maturity of public API:
  bKash publishes a Tokenized Checkout REST API for merchant payments,
  Nagad's merchant flow is gated behind onboarding, and Rocket has no
  public API. Without an abstraction layer the UI would branch on every
  provider, producing untestable code.
* **Consequences.**
  - All three adapters implement the same Dart interface.
  - Swapping a mock adapter for a live one requires zero screen
    changes.
  - Screens and Riverpod providers depend only on the interface.
* **Ref:** `SYSTEM_ARCHITECTURE.md` §3, `FEASIBILITY_REVIEW.md` §5.

---

## AD-002 — No automated USSD orchestration in Phase B

* **Date:** 2026-06-07
* **Decision.** MFS Unified will **not** implement multi-step USSD
  automation via an `AccessibilityService`. The app uses dialer
  pass-through (`ACTION_DIAL` with the `#` URL-encoded in the `tel:`
  URI) and treats the provider's own USSD menu as the source of truth.
* **Context.** Accessibility-service automation is on Google Play's
  most-restrictive permission list and is routinely rejected for
  non-accessibility apps. It is also brittle across Symphony, Walton,
  Xiaomi, and Samsung OEM ROMs.
* **Consequences.**
  - The app never declares `BIND_ACCESSIBILITY_SERVICE`, `CALL_PHONE`,
    or `READ_SMS`.
  - `RECEIVE_SMS` is declared only for OTP autofill via the SMS
    Retriever API.
  - P2P and Cash Out record a `pending` local transaction and ask the
    user to confirm completion.
* **Ref:** `FEASIBILITY_REVIEW.md` §1.3, §4; `RISK_REGISTER.md` R-AND-01, R-MIG-03.

---

## AD-003 — Provider PINs are never ours

* **Date:** 2026-06-07
* **Decision.** No field, column, log statement, or DTO in the codebase
  may contain a provider PIN. The 4–6 digit PIN used to authorise a
  bKash/Nagad/Rocket transfer lives exclusively inside the provider's
  own checkout flow or USSD session.
* **Context.** Storing or transmitting a provider PIN would create a
  critical security liability and require a regulatory posture that the
  MVP is not authorised to carry.
* **Consequences.**
  - `PaymentRequest` contains only `recipientPhone`, `amount`,
    `providerId`, `idempotencyKey`, `deviceFingerprint`.
  - Merchant payments use bKash's own checkout surface; P2P uses the
    dialer pass-through.
  - A static-analysis rule rejects commits that introduce a `*pin*`
    field in `domain/` or `data/models/` without documented exemption.
* **Ref:** `SECURITY_REVIEW.md` §2.

---

## AD-004 — Backend stack: Node.js + TypeScript + Express + Prisma + PostgreSQL + Redis

* **Date:** 2026-06-07
* **Decision.** The backend runs on **Node.js 20 LTS + TypeScript in
  strict mode**, served by **Express.js**, with **Prisma** as the ORM,
  **PostgreSQL 16** for persistence, and **Redis 7** for caching and
  rate limiting.
* **Context.** The original Phase A default was **FastAPI + SQLAlchemy
  2.0 + asyncpg + Alembic + Redis**. That stack remains technically
  sound. The project sponsor issued an architecture change request on
  2026-06-07 citing **deployment simplicity and free-tier hosting
  flexibility** as the overriding MVP priority. Node.js containers are
  first-class citizens on Render, Railway, Fly.io, Koyeb, and Cyclic,
  while Python services face stricter sleep policies on several of
  those platforms. TypeScript also gives the small team a single
  language across the backend, any future admin dashboard, and shared
  types with the Flutter web fallback.
* **Consequences.**
  - `BACKEND_STACK_ANALYSIS.md`, `SYSTEM_ARCHITECTURE.md` (Section 7),
    and `SECURITY_REVIEW.md` (Sections 6, 8, 9.3, 13) were updated.
  - The same security posture (bcrypt, JWT, rate-limit, masked PII
    logs, TLS 1.3) is retained with Node/TS equivalents.
  - Strict TypeScript (`strict: true`), Zod runtime validation, and
    Prisma's typed client deliver the same API-boundary guarantees as
    FastAPI + Pydantic v2.
  - CPU-bound analytics (Phase 2 fraud scoring) will be offloaded to
    a worker container, since Node is weaker than Python for
    CPU-bound workloads.
* **Ref:** `BACKEND_STACK_ANALYSIS.md` (supersedes earlier revision).

---

## AD-005 — State management: Riverpod only

* **Date:** 2026-06-07
* **Decision.** `flutter_riverpod` + `riverpod_annotation` is the sole
  state-management system. `setState` is banned in screens.
* **Context.** BLoC was considered for its discipline, but Riverpod's
  code-generated providers and native `AsyncValue` pattern are a
  closer fit for a two-person team and produce less boilerplate.
* **Consequences.**
  - A lint rule bans `setState` inside `presentation/screens/`.
  - Loading/error states flow through `AsyncValue.when(...)`.
* **Ref:** `SYSTEM_ARCHITECTURE.md` §5.

---

## AD-006 — Local storage: Isar

* **Date:** 2026-06-07
* **Decision.** Isar is the local database, with three collections:
  `CachedTransaction`, `CachedContact`, `AppSettings`.
* **Context.** Hive and Drift were considered. Isar won on type-safe
  code generation and query performance on low-end ARM devices
  (Symphony, Walton, Xiaomi).
* **Consequences.**
  - Schema migrations must be explicit via `schemaVersion` +
    `migrationTasks` at app start.
  - Provider PINs and plaintext auth tokens never enter Isar.
* **Ref:** `SYSTEM_ARCHITECTURE.md` §4.

---

## AD-007 — Android-only target

* **Date:** 2026-06-07
* **Decision.** The Flutter app targets Android only. No iOS, macOS,
  web, Windows, or Linux build targets are configured in Phase B.
* **Context.** Bangladesh market share is >95% Android; supporting iOS
  would double QA surface without proportional reach.
* **Consequences.**
  - `flutter create --platforms=android`.
  - No iOS-specific widgets, no Cupertino imports in screens.
  - If iOS is added later, Android-specific code (dialer intents,
    Keystore, biometric) is already behind interfaces and
    `Platform.isAndroid` guards.
* **Ref:** `PROJECT_BRIEF.md` §1.

---

## AD-008 — Dialer pass-through for P2P / Cash Out

* **Date:** 2026-06-07
* **Decision.** When a provider does not expose a public API for a
  transaction type (currently P2P Send Money and Cash Out across all
  three providers), the app launches the stock dialer with the USSD
  string pre-filled using `Intent.ACTION_DIAL` + `Uri.parse('tel:...')`
  with `#` encoded as `%23`.
* **Context.** This avoids every prohibited permission while remaining
  functional on low-end OEM ROMs.
* **Consequences.**
  - MFS Unified writes a `pending` `CachedTransaction` and prompts
    the user on return for the final status.
  - Completion reconciliation is a Phase 2 feature (SMS receipt
    parsing or user-confirmed).
* **Ref:** `FEASIBILITY_REVIEW.md` §5.

---

## AD-009 — Security posture carried unchanged across backend swap

* **Date:** 2026-06-07
* **Decision.** The backend technology change (AD-004) does **not**
  alter any security rule: provider-PIN absence, device binding,
  per-IP + per-user rate limiting, secure logging, bcrypt, JWT, TLS
  1.3.
* **Context.** The security controls are expressed as *behaviour*, not
  as technology-specific libraries. Each Python library in the
  original plan has a one-to-one Node/TS equivalent.
* **Consequences.** No re-review of `SECURITY_REVIEW.md` is required
  beyond the library-name substitutions already performed.
* **Ref:** `SECURITY_REVIEW.md` §6, §8, §9.3, §13.

---

## Variances from the Initial Plan

| Variance | Original plan | Adopted plan | Reason |
|---|---|---|---|
| Backend framework | FastAPI (Python) | Express.js (TypeScript) | Deployment simplicity + free-tier hosting. See AD-004. |
| ORM | SQLAlchemy 2.0 + Alembic | Prisma | Single schema source; typed client. See AD-004. |
| Validation | Pydantic v2 | Zod | Consistent with TS strict mode. |
| Rate-limit lib | `slowapi` + `redis-py` | `express-rate-limit` + `rate-limit-redis` + `ioredis` | See AD-009. |
| Logging | Python `logging` + filter | `pino` structured logs + `piiMask` middleware | See AD-009. |

---

## Future Revisits

These decisions are flagged for revisit after MVP:

1. **AD-002 (USSD automation).** Revisit only if a separate, non-Play-Store
   distribution channel is created for enterprise users who need full
   USSD orchestration.
2. **AD-004 (Backend stack).** If the team grows beyond 5 engineers
   or the product adds CPU-bound analytics, consider re-evaluating
   Python for those specific services.
3. **AD-007 (Android-only).** iOS revisit requires a market-share
   shift in Bangladesh or an explicit investor/partner mandate.
