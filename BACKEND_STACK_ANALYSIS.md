# MFS UNIFIED — Phase A — Backend Stack Analysis

**Purpose.** Evaluate and select the backend stack for the MFS Unified MVP.

**Decision (updated).** The selected stack is **Node.js + TypeScript +
Express.js + PostgreSQL + Prisma ORM + Redis**.

This supersedes the earlier FastAPI + PostgreSQL recommendation. The
override is driven by the project's Phase B priority: **deployment
simplicity and free-tier hosting flexibility** over the
FastAPI-specific advantages documented in the previous revision.

---

## 1. Candidate Stacks

| Stack | Language | Runtime | Web framework | ORM / DB layer |
|---|---|---|---|---|
| ~~A (previous default)~~ | Python 3.12 | uvicorn + uvloop | FastAPI | SQLAlchemy 2.0 (async) + asyncpg + Alembic |
| **B (SELECTED)** | **Node.js 20 LTS** | **V8** | **Express.js (TypeScript)** | **Prisma + pg driver** |
| C | Node.js 20 LTS | V8 | NestJS | Prisma or TypeORM + pg |

---

## 2. Evaluation Criteria

| Criterion | Weight |
|---|---|
| Deployment simplicity on free tiers (Render, Railway, Fly, Vercel, Koyeb) | HIGH |
| Type safety at the API boundary | HIGH |
| Concurrency model (I/O bound provider calls) | HIGH |
| Development velocity for a 2-person MVP team | HIGH |
| Ecosystem maturity for fintech (auth, hashing, rate-limit, OTP, observability) | MEDIUM |
| Hiring pool in Bangladesh | MEDIUM |
| Raw throughput (RPS) | LOW |

---

## 3. Why Node.js + TypeScript + Express + Prisma

### 3.1 Deployment simplicity

* A single `Dockerfile` with a lightweight Alpine Node image (`node:20-alpine`,
  ~180 MB) produces a self-contained binary.
* Free and low-cost hosting platforms that run Node containers out of the
  box: Render, Railway, Fly.io, Koyeb, Cyclic, Vercel (serverless).
* No dependency on a separate ASGI/WSGI server process (contrast with
  `uvicorn` + `gunicorn` pairing).
* A single process serves HTTP and runs background tasks via `bullmq`
  when needed; no separate worker binary is required for MVP scale.

### 3.2 Type safety at the API boundary

* TypeScript in `strict` mode eliminates `any` at compile time.
* **Zod** provides runtime schema validation and can derive the
  TypeScript type from the schema, giving a single source of truth per
  request/response contract.
* Prisma's generated client is fully typed; queries that reference
  non-existent fields fail the build.
* Combined, Zod + Prisma + TypeScript strict mode give the same level
  of boundary safety that Pydantic v2 provides in FastAPI.

### 3.3 Concurrency

* Node's single-threaded event loop handles the I/O-bound workload of
  the MVP (bKash PGW calls, Postgres queries, Redis operations, OTP SMS
  sends) without thread exhaustion.
* `pg` supports async/await natively via promises; Prisma exposes the
  same pattern through its generated client.
* Long-running payment polling fits naturally with `async`/`await` and
  `Promise.all` across concurrent requests.

### 3.4 Development velocity

* The same language (TypeScript) is used on the Flutter web fallback
  and any admin dashboard, reducing context-switching.
* Prisma's schema-first approach generates migrations, the client, and
  seed utilities from a single `schema.prisma` file — no separate
  Alembic-equivalent step.
* Express middleware (`cors`, `helmet`, `morgan`, `express-rate-limit`,
  `zod-express-middleware`) covers common needs in a few lines.
* Auto-generated OpenAPI is available through `tsoa` or
  `express-openapi` when required, though the MVP does not mandate it
  on day one.

### 3.5 Ecosystem maturity for fintech

| Need | Node/TS package |
|---|---|
| Password / PIN hashing | `bcrypt` (via `bcryptjs` or native `bcrypt`) |
| Redis client | `ioredis` |
| Rate limiting | `express-rate-limit` + `rate-limit-redis` |
| JWT | `jsonwebtoken`, `jose` |
| Background jobs | `bullmq` |
| OTP SMS (SSL Wireless, MimSMS) | Plain `fetch` / `axios` |
| Observability | `pino` (structured logs), `prom-client`, OpenTelemetry JS |
| Validation | `zod` |
| Device / request fingerprinting | `express-request-id`, custom middleware |

### 3.6 Hiring pool in Bangladesh

Node.js has a very strong hiring pool in Dhaka — stronger than Python
for junior-to-mid web-backend roles. TypeScript literacy is widespread
among front-end developers who can be cross-trained to backend work.

### 3.7 Weaknesses (acknowledged)

* Express middleware ordering is fragile; disciplined layering is
  required to avoid auth-bypass bugs (see `SECURITY_REVIEW.md`
  Section 8).
* NestJS would give the same architectural opinion as FastAPI, but its
  steeper learning curve and heavier boilerplate make it a poorer fit
  for a two-person MVP.
* CPU-bound work (future fraud scoring) is the one area where Node is
  weaker than Python; this is Phase 2 scope and will be offloaded to a
  worker container.

---

## 4. Why the previous default (FastAPI) is superseded

FastAPI's advantages — native async, Pydantic, auto-OpenAPI — remain
valid. However, for this MVP:

* Free-tier hosting for Python services is **less ubiquitous** than for
  Node containers (several platforms impose stricter sleep policies on
  Python dynamos).
* The `uvicorn` + `gunicorn` process model is one more moving part on
  small deployments.
* TypeScript's single-language story across client and backend reduces
  onboarding cost for the small team we have.

These trade-offs tilt the decision toward Node.js + TypeScript for
Phase B. FastAPI remains the recommended path if the project scales to
a team that wants tighter architectural guardrails or adds heavy
CPU-bound analytics.

---

## 5. Final Stack Manifest

```text
backend/
├── src/
│   ├── index.ts                    # Express app bootstrap
│   ├── app.ts                      # middleware + routes wiring
│   ├── config/
│   │   ├── env.ts                  # Zod-validated env schema
│   │   ├── redis.ts
│   │   └── prisma.ts
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.router.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.schema.ts      # Zod
│   │   │   └── auth.middleware.ts  # JWT verify
│   │   ├── contacts/
│   │   ├── payments/
│   │   │   ├── payments.router.ts
│   │   │   ├── payments.service.ts
│   │   │   ├── payments.schema.ts
│   │   │   └── providers/
│   │   │       ├── provider.interface.ts    # abstraction contract
│   │   │       ├── bkash.adapter.ts
│   │   │       ├── nagad.adapter.ts         # mock in Phase B
│   │   │       └── rocket.adapter.ts        # mock in Phase B
│   │   └── health/
│   ├── core/
│   │   ├── security/
│   │   │   ├── hash.ts             # bcrypt wrappers
│   │   │   ├── jwt.ts
│   │   │   └── deviceBinding.ts
│   │   ├── middleware/
│   │   │   ├── rateLimit.ts
│   │   │   ├── errorHandler.ts
│   │   │   ├── requestLogger.ts
│   │   │   └── piiMask.ts
│   │   └── errors/
│   │       └── AppError.ts
│   └── utils/
│       └── logger.ts               # pino
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── tests/
├── package.json
├── tsconfig.json
├── .eslintrc.cjs
├── Dockerfile
└── README.md
```

**Runtime:** Node.js 20 LTS, TypeScript 5.x, Express 4.x (or 5.x once
stable), Prisma 5.x.
**Persistence:** PostgreSQL 16.
**Cache/rate-limit:** Redis 7 via `ioredis`.

---

## 6. Non-Functional Guarantees (unchanged from previous revision)

| Guarantee | Mechanism |
|---|---|
| Strict type safety | TypeScript `strict: true`, Zod runtime validation, Prisma typed client. |
| Provider-PIN absence | No field named `*pin*` in the provider-integration DTOs. Enforced by lint + code review. |
| Rate limiting | `express-rate-limit` + `rate-limit-redis` per-IP and per-user. |
| Transport | HTTPS only in production; TLS 1.3 where provider supports it. |
| Logging | `pino` structured logs through a PII-mask middleware. |
| Secrets | Docker secrets / GitHub Actions secrets; `.env.example` committed, `.env` ignored. |

---

## 7. Conclusion

The selected backend stack is **Node.js + TypeScript + Express +
Prisma + PostgreSQL + Redis**. This satisfies the brief's deployment
and hiring constraints while preserving the security posture described
in `SECURITY_REVIEW.md` and the provider abstraction contract described
in `SYSTEM_ARCHITECTURE.md`.
