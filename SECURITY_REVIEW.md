# MFS UNIFIED — Phase A — Security Review

**Purpose.** Document how MFS Unified enforces fintech-grade security
across the mobile client, the Express backend, and the provider
integration layer.

**Cardinal rule.** Provider PINs (the 4–6 digit PINs users type inside
bKash, Nagad, or Rocket to authorise a transfer) are **never** stored,
processed, or transmitted by MFS Unified. They live exclusively in the
provider's own app and on the provider's servers.

---

## 1. Threat Model (Summary)

| # | Threat | Layer | Severity |
|---|---|---|---|
| T1 | Device theft + unlocked session | Mobile | HIGH |
| T2 | Malicious app pretending to be MFS Unified | Mobile | HIGH |
| T3 | Backend compromise (SQLi, SSRF, auth bypass) | Backend | HIGH |
| T4 | Credential stuffing on `/auth/login` | Backend | HIGH |
| T5 | Replay of a payment initiation request | Backend | MEDIUM |
| T6 | Leakage of user PII (phone numbers) via logs | Both | HIGH |
| T7 | Compromise of the MFS provider PIN by our stack | Both | CRITICAL |
| T8 | Man-in-the-middle on provider API calls | Backend | HIGH |
| T9 | Jailbroken / rooted device running the app | Mobile | MEDIUM |
| T10 | Insider access to production database | Backend | HIGH |

Each section below maps controls to these threats.

---

## 2. Threat T7 — Provider PINs Are Never Ours

### 2.1 Architectural guarantee

| Transaction type | Who handles the provider PIN? |
|---|---|
| Merchant payment via bKash Tokenized Checkout | bKash's own checkout web-view / redirect. The user authenticates directly with bKash. Our backend never sees the PIN. |
| P2P / Cash Out via dialer pass-through (Section 5 of FEASIBILITY_REVIEW.md) | The user dials `*247#` (or `*167#`, `*322#`) and enters the PIN inside the provider's USSD session. Our app only launches the dialer. |
| Future: provider's own Android app launched via deep link | The provider's own app handles PIN entry. |

### 2.2 Code-level guarantees

* **No field, variable, database column, or log statement** in the
  codebase may contain the strings `provider_pin`, `providerPin`,
  `mfs_pin`, or `provider_otp`.
* The `PaymentRequest` DTO contains only:
  `recipientPhone`, `amount`, `providerId`, `idempotencyKey`, `deviceFingerprint`.
  No PIN field is defined.
* The Provider Integration Service's `initiate` and
  `launchDialerPassThrough` methods take no PIN parameter.
* Code-review checklist includes: **"Does this change introduce a
  provider-PIN path?"** — mandatory reviewer sign-off.

### 2.3 Audit hooks

* Static analysis rule (implemented via a custom linter in Phase B)
  rejects any commit that introduces a field named `*pin*` inside
  `domain/` or `data/models/` unless accompanied by a documented
  exemption (e.g., the user's own **app-unlock PIN**, which is a
  different concept — see Section 3).

---

## 3. App-Unlock PIN (Distinct from Provider PIN)

The user sets a **4–6 digit app-unlock PIN** as a fallback to
biometric authentication. This PIN unlocks the MFS Unified app itself
— it is **not** a provider PIN and never leaves the device.

### 3.1 Storage

| Step | Operation |
|---|---|
| 1 | User enters PIN on `AuthenticationScreen`. |
| 2 | Flutter generates a per-device salt (`device_info_plus` fingerprint + 16-byte random). |
| 3 | PIN is hashed: `bcrypt(PIN + salt, cost=12)` on-device. |
| 4 | Hash is written to `flutter_secure_storage` (Android Keystore-backed). |
| 5 | Salt is written alongside the hash. |
| 6 | On subsequent unlock: app reads hash + salt, re-runs bcrypt on user input, compares. |

**The plaintext PIN is never written to disk.** The hash never leaves
the device. The backend has no knowledge of this PIN.

### 3.2 Brute-force protection (on-device)

* 5 failed attempts → 30-second lockout.
* 10 failed attempts → exponential backoff up to 15 minutes.
* 15 failed attempts → optional "factory reset app data" prompt.
* All attempts logged with timestamp only — never the attempted PIN.

---

## 4. Biometric Authentication

* `local_auth` via AndroidX `BiometricPrompt`. Never a custom UI.
* Biometric templates stay on the device's secure enclave (TEE /
  StrongBox when available).
* Biometric success returns a boolean to Flutter; no biometric data
  crosses the Dart bridge.
* Fallback: app-unlock PIN.

---

## 5. Device Binding

Each authenticated session is bound to the device that created it.

### 5.1 Device fingerprint composition

```text
fingerprint = SHA-256(
    androidId                       // Settings.Secure.ANDROID_ID
  + packageName
  + device_model                    // Build.MODEL
  + device_manufacturer             // Build.MANUFACTURER
  + os_version                      // Build.VERSION.RELEASE
  + per_install_random_salt         // stored in flutter_secure_storage
)
```

The fingerprint is sent as `X-Device-Fingerprint` on every authenticated
request. The backend stores it on the `Device` record and rejects
requests where the fingerprint does not match the bound session.

### 5.2 Binding lifecycle

| Event | Behaviour |
|---|---|
| First login | `Device` record created, session bound. |
| Subsequent login from same device | Session refreshes; fingerprint matches. |
| Login from new device | Requires OTP re-verification. User may have up to 3 bound devices. |
| Device reported lost | User revokes from web or support; server invalidates all sessions for that `Device` row. |

---

## 6. Rate Limiting (Backend)

Implemented with `express-rate-limit` + `rate-limit-redis`
(backed by the Redis 7 instance defined in `backend/src/config/redis.ts`).

| Endpoint | Limit | Key |
|---|---|---|
| `POST /auth/register` | 3 / minute | IP |
| `POST /auth/verify-otp` | 5 / minute | IP + phone |
| `POST /auth/login` | 5 / minute | IP + phone |
| `POST /auth/set-pin` | 3 / hour | user_id |
| `POST /payments/initiate` | 10 / minute | user_id |
| `GET  /payments/{id}/status` | 30 / minute | user_id |
| Global | 200 / minute | IP |

On breach: HTTP `429` with body
`{ "code": "RATE_LIMIT", "message": "Too many requests", "retryAfterSeconds": N }`.

**Why per-user on payments?** An attacker with a stolen session token
cannot flood the system, and legitimate users on shared NAT (common in
Bangladesh cybercafés / office Wi-Fi) are not penalised for others'
traffic.

---

## 7. Transport Security

| Channel | Requirement |
|---|---|
| Client ↔ Backend | TLS 1.3 only. Certificate pinning on the Flutter client via `dio` interceptor. |
| Backend ↔ bKash PGW | HTTPS, mutual TLS where bKash supports it, otherwise TLS 1.3 + API-key auth. |
| Backend ↔ Nagad / Rocket | HTTPS; provider-specific signing mechanism implemented inside each adapter. |
| Backend ↔ Redis | AUTH password + TLS if crossing network boundary. |
| Backend ↔ PostgreSQL | `sslmode=verify-full` in production. |

---

## 8. Input Validation

* Every route uses a **Zod schema** validated by `zod-express-middleware`
  (or an equivalent wrapper) before the request reaches the handler.
* Phone numbers: E.164 format, Bangladesh country code `+880`, 11–14
  digits. Rejected otherwise.
* Amounts: integer minor units (paisa), validated against
  `min=100` (৳1.00) and provider-specific max.
* Idempotency keys: UUIDv4, required on all write endpoints.
* All other fields: `.strict()` on the Zod object — unknown keys cause
  `422`.

---

## 9. Secure Logging

### 9.1 What is NEVER logged

* Plaintext phone numbers. Logged as `+880 ***XX1234` (last 4 digits only).
* Auth tokens, refresh tokens, session IDs.
* OTP codes — even when generated by our backend.
* Hashes of PINs (no diagnostic value, aids attackers if leaked).
* Provider credentials.
* HTTP bodies on `/auth/*` and `/payments/*/execute` routes — only the
  status code and correlation ID are logged.

### 9.2 What IS logged

* Request correlation ID (`X-Correlation-ID`).
* Route path, HTTP method, status code, latency.
* User ID (numeric), never phone or name.
* Device fingerprint (hashed).
* Error codes and stack traces (with PII already masked by a dedicated
  logging filter).

### 9.3 Implementation

An Express middleware in `backend/src/core/middleware/requestLogger.ts`
pipes structured logs through `pino` and applies a `piiMask` filter
that inspects log-record attributes. The same filter is reused by
`bullmq` workers.

---

## 10. Cryptographic Standards

| Use | Algorithm | Parameters |
|---|---|---|
| App-PIN hash | bcrypt | cost = 12 |
| Backend password hash (future admin portal) | Argon2id | m=64MB, t=3, p=4 |
| JWT signing | ES256 (ECDSA P-256) | Rotate keys every 90 days |
| Symmetric encryption (cached secrets at rest) | AES-256-GCM | Per-record nonce |
| Transport | TLS 1.3 | — |
| Device fingerprint | SHA-256 | — |

Weak algorithms explicitly banned: MD5, SHA-1 (for signatures), DES,
RC4, ECB mode.

---

## 11. OTP Handling

| Rule | Enforcement |
|---|---|
| OTP is 6 digits, valid for 5 minutes | Backend enforces. |
| Maximum 5 attempts per OTP | Counter in Redis; invalidates on breach. |
| OTP never returned in API response | Generated, stored in `OtpSession`, sent only via SMS gateway. |
| OTP not logged | See Section 9.1. |
| OTP hash stored server-side | SHA-256 hash stored; plaintext discarded after transmission. |

---

## 12. Secrets Management

| Secret | Storage |
|---|---|
| bKash / Nagad / Rocket API keys | Backend env vars injected at deploy time via Docker secrets; never in repo. |
| JWT private key | Backend env var, rotated every 90 days. |
| Postgres password | Docker secret. |
| Redis password | Docker secret. |
| Android signing key | CI secrets (GitHub Actions). |
| User refresh tokens | `flutter_secure_storage` (client), HTTP-only secure cookie (backend optional). |

`.env.example` is committed; `.env` is in `.gitignore`.

---

## 13. Compliance Checklist (Pre-Launch)

| Item | Owner |
|---|---|
| Static analysis rule for provider-PIN absence | Mobile lead |
| Penetration test on auth + payment flows | External (pre-Play-Store) |
| Dependency vulnerability scan (`npm audit`, `snyk`) | CI pipeline |
| TLS certificate pinning verified on low-end devices | QA |
| Rate-limit thresholds reviewed against prod traffic | Backend lead |
| Play Store financial-services declaration | Product |
| Privacy policy covering device fingerprint, phone hashing | Legal |

---

## 14. Summary

* Provider PINs: never ours. Architecturally excluded.
* App-unlock PIN: hashed on-device with bcrypt, stored in Keystore.
* Sessions: bound to device fingerprint.
* Backend: rate-limited per-IP and per-user, strict schemas, no-typed-JSON
  leaks, masked logs.
* Transport: TLS 1.3 everywhere.
* Secrets: Docker secrets / GitHub Actions secrets / Android Keystore —
  never in repo.

With these controls, MFS Unified meets the baseline security posture
expected for a Bangladesh-market fintech MVP and keeps the attack
surface small enough for a future pen-test to validate before Play
Store submission.
