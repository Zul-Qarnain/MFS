# MFS UNIFIED — Phase A — System Architecture

**Purpose.** Define the separation of concerns in the Flutter client, the
local-storage strategy (Isar), the state-management strategy (Riverpod), and
the contract between the Flutter client and the Express backend.

This document is normative for Phase B. Every file created during Phase B
must be traceable to a layer described here.

---

## 1. Layered Architecture

The Flutter client follows a **clean architecture** with four top-level
folders under `lib/`. Dependencies flow inward: `presentation` → `domain`
→ `data` → `core`. Nothing in `domain` or `core` imports from
`presentation`.

```text
lib/
├── core/           # Cross-cutting, framework-adjacent utilities
├── domain/         # Pure Dart business rules and entities
├── data/           # I/O: network, local DB, secure storage, providers
└── presentation/   # Riverpod providers, widgets, screens
```

### 1.1 `core/` — cross-cutting utilities

`core/` has **zero business logic**. It exists so that domain and data
layers can share constants, error types, and low-level services without
depending on each other.

| Sub-path | Responsibility |
|---|---|
| `core/constants/` | `app_colors.dart`, `app_typography.dart`, `app_constants.dart`. Values sourced from `stitch_unified_mfs_wallet/mfs_unified_design_system/` during Phase B. |
| `core/errors/` | Base classes: `MfsException`, `NetworkException`, `ProviderException`, `SecurityException`. Every thrown error in the app must extend `MfsException`. |
| `core/network/` | A single `Dio` instance wrapped in an `ApiClient` with interceptors for logging, retry, and auth-token injection. |
| `core/security/` | PIN hashing (`bcrypt`), device binding (fingerprint of `device_info_plus` fields), biometric prompt wrapper around `local_auth`. |
| `core/providers/` | **Provider Integration Service** — the abstraction layer over bKash / Nagad / Rocket. See Section 3. |

### 1.2 `domain/` — pure Dart business rules

`domain/` contains entities, value objects, repository interfaces (abstract
contracts), and use-case classes. It imports only `dart:core` and `core/`.

| Sub-path | Responsibility |
|---|---|
| `domain/entities/` | Plain Dart classes annotated with `@freezed`: `Transaction`, `Contact`, `ProviderAccount`, `QrPayload`, `PaymentReceipt`. |
| `domain/repositories/` | Abstract classes: `TransactionRepository`, `ContactRepository`, `AuthRepository`, `ProviderRepository`. No implementations. |
| `domain/usecases/` | One class per use case: `InitiatePayment`, `PollPaymentStatus`, `ParseQrCode`, `AuthenticateWithBiometric`, `AuthenticateWithPin`. Each exposes a single `call(...)` method. |
| `domain/value_objects/` | `Money` (amount + currency `BDT`, formatted via `intl` as `৳1,500.00`), `PhoneNumber` (validated E.164 for Bangladesh `+880`), `ProviderId` (enum: `bkash`, `nagad`, `rocket`). |

### 1.3 `data/` — I/O implementations

`data/` implements the abstract repository interfaces from `domain/` using
Dio, Isar, `flutter_secure_storage`, and the Provider Integration Service.

| Sub-path | Responsibility |
|---|---|
| `data/datasources/remote/` | Retrofit-annotated API classes: `AuthApi`, `ContactApi`, `PaymentApi`. All endpoints map to the backend in `backend/`. |
| `data/datasources/local/` | Isar DAOs: `TransactionDao`, `ContactDao`, `SettingsDao`. |
| `data/datasources/secure/` | `SecureKeyValueStore` wrapping `flutter_secure_storage`. Stores: auth refresh token, hashed app-PIN, device-binding salt. |
| `data/models/` | `@JsonSerializable` DTOs: `TransactionDto`, `ContactDto`, `OtpSessionDto`. Mapped to/from domain entities. |
| `data/repositories/` | Concrete implementations of domain repositories. The **only** layer that touches Dio or Isar directly. |

### 1.4 `presentation/` — screens, widgets, Riverpod providers

`presentation/` is the only layer that imports Flutter widgets.

| Sub-path | Responsibility |
|---|---|
| `presentation/router/` | `go_router` configuration. Routes: `/`, `/scan`, `/pay`, `/auth`, `/processing`, `/success`. |
| `presentation/providers/` | `@riverpod` annotated providers. Each provider is a `Notifier` or `AsyncNotifier` that depends on a use-case, never on a repository directly. |
| `presentation/screens/` | `HomeScreen`, `QrScannerScreen`, `PaymentDetailsScreen`, `AuthenticationScreen`, `ProcessingScreen`, `SuccessScreen`. |
| `presentation/widgets/` | Shared widgets: `BalanceCard`, `ProviderChip`, `QuickSendAvatar`, `TransactionTile`, `AmountKeypad`, `ProviderRoutingSheet`. |
| `presentation/theme/` | `ThemeData` factory built from `core/constants/app_colors.dart` and `core/constants/app_typography.dart`. |

---

## 2. Cross-Layer Rules

1. **No `setState()` in any screen.** All UI state is managed through
   `ref.watch(...)` against a Riverpod provider.
2. **No `dynamic` or untyped maps cross boundaries.** Every value crossing
   a layer boundary is a strongly-typed entity, value object, or DTO.
3. **Repositories are singletons per app lifetime.** Registered once in
   the root `ProviderContainer` via `ProviderScope`.
4. **Errors propagate as `AsyncValue<T>.error`.** Screens render loading,
   data, and error states via `AsyncValue.when(...)`.
5. **Formatting.** All monetary amounts pass through
   `Money.format()` (`intl`-based, `৳1,500.00`). All phone numbers pass
   through `PhoneNumber.display()` (`+880 1XXX-XXXXXX`).

---

## 3. Provider Integration Service (`core/providers/`)

A single abstraction over all three MFS providers.

```text
core/providers/
├── provider_integration_service.dart   # abstract ProviderIntegrationService
├── bkash_adapter.dart                  # BkashAdapter implements ProviderAdapter
├── nagad_adapter.dart                  # NagadAdapter implements ProviderAdapter
└── rocket_adapter.dart                 # RocketAdapter implements ProviderAdapter
```

### 3.1 Abstract contract

```text
abstract class ProviderAdapter {
  ProviderId get id;
  Future<PaymentInitiation> initiate(PaymentRequest req);
  Future<PaymentStatus> pollStatus(String transactionId);
  Future<PaymentReceipt> fetchReceipt(String transactionId);
  Future<void> launchDialerPassThrough(PaymentRequest req); // fallback
}
```

The `ProviderIntegrationService` resolves the correct adapter from a
`ProviderId` and exposes the same four methods. Screen code never imports
a concrete adapter.

### 3.2 Adapter implementation tiers

| Provider | Adapter status (Phase B) | Mechanism |
|---|---|---|
| bKash merchant payments | LIVE | Backend REST (Tokenized Checkout). |
| bKash P2P / Cash Out | MOCK + DIALER | Dialer pass-through + local Isar record. |
| Nagad (all) | MOCK | Adapter returns mock DTOs. Swapped to live when merchant credentials are onboarded. |
| Rocket (all) | MOCK | Same as Nagad. |

The interface is identical for all three, so swapping a mock adapter to
a live one requires **zero changes** to screens or repositories.

---

## 4. Local Storage Strategy — Isar

Isar is chosen for its type-safe code generation, fast reads, and
built-in query engine on low-end ARM devices.

### 4.1 Collections

| Collection | Fields (non-exhaustive) | Indexed |
|---|---|---|
| `CachedTransaction` | `id`, `providerId`, `recipientPhone`, `amountMinorUnits`, `status`, `createdAt`, `updatedAt`, `providerTxnId?` | `id`, `providerTxnId`, `createdAt` |
| `CachedContact` | `id`, `name`, `phoneNumber`, `providerId?`, `lastUsedAt`, `isFavorite` | `phoneNumber`, `isFavorite` |
| `AppSettings` | `id`, `key`, `value`, `updatedAt` | `key` |

All collections are annotated with `@collection` and generated via
`isar_generator`.

### 4.2 Sync policy

* **Write-through.** When a screen commits a transaction, the repository
  writes to Isar immediately and to the backend asynchronously.
* **Read-through.** Repositories serve from Isar first; a background
  refresh reconciles with the backend every N minutes (configurable via
  `AppSettings`).
* **Conflict resolution.** Server wins. Local `updatedAt` is only used
  to decide staleness.

### 4.3 What Isar does NOT store

* Provider PINs (any MFS provider). These are never known to the app.
* Plaintext auth tokens — only a hashed session identifier; the refresh
  token is in `flutter_secure_storage`.
* Raw USSD session logs — only the structured `CachedTransaction` record.

---

## 5. State Management Strategy — Riverpod

### 5.1 Choice rationale

* `flutter_riverpod` + `riverpod_annotation` give code-generated providers
  (`@riverpod`) with compile-time safety and no manual `Provider`
  registration.
* `AsyncNotifier` / `Notifier` replace every use case where `setState`
  would otherwise appear.
* `AsyncValue<T>` gives the three-state (loading / data / error) pattern
  natively, matching the UX requirements for the Processing and Home
  screens.

### 5.2 Provider taxonomy

| Type | Example | Role |
|---|---|---|
| Plain provider | `dioProvider`, `isarProvider` | Infrastructure singletons. |
| Repository provider | `transactionRepositoryProvider` | Binds a concrete repo to its abstract interface. |
| Use-case provider | `initiatePaymentProvider` | Wraps a single use-case class. |
| Notifier / AsyncNotifier | `homeScreenNotifier`, `paymentFlowNotifier` | Screen-scoped state. |
| Stream provider | `transactionHistoryStream` | Exposes an Isar query as a `Stream<List<CachedTransaction>>`. |

### 5.3 Screen lifecycle

1. Screen builds with `ref.watch(paymentFlowNotifierProvider)`.
2. User action calls `ref.read(paymentFlowNotifierProvider.notifier).initiate(req)`.
3. The notifier emits `AsyncLoading`, then `AsyncData` or `AsyncError`.
4. Screen re-renders through `AsyncValue.when(...)`.

No imperative `setState`, no callback pyramid.

---

## 6. Client ↔ Backend Contract

| Concern | Rule |
|---|---|
| Transport | HTTPS only in production. HTTP permitted for `localhost` during dev. |
| Serialization | JSON, strict Zod schemas validated in middleware. Every field is typed; `any` is banned by ESLint (`@typescript-eslint/no-explicit-any`). |
| Authentication | Short-lived JWT access token in `Authorization: Bearer` header; refresh token in HTTP-only secure cookie or `flutter_secure_storage`. |
| Pagination | Cursor-based. Response envelope: `{ data: T[], cursor: string?, hasNext: boolean }`. |
| Errors | `{ code: string, message: string, details?: object }`. Codes are stable strings (`AUTH_INVALID_OTP`, `PAYMENT_INSUFFICIENT_BALANCE`). |
| Idempotency | All write endpoints require `X-Idempotency-Key` header; backend de-duplicates within a 24-hour window using a Redis-backed store. |

---

## 7. Directory Map (Phase B)

```text
mfs_unified/
├── mobile/lib/
│   ├── core/
│   ├── domain/
│   ├── data/
│   └── presentation/
├── backend/
│   ├── src/
│   │   ├── index.ts
│   │   ├── app.ts
│   │   ├── config/              # env, redis, prisma
│   │   ├── core/                # security, middleware, errors
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   ├── contacts/
│   │   │   ├── payments/
│   │   │   │   └── providers/   # bkash / nagad / rocket adapters
│   │   │   └── health/
│   │   └── utils/               # pino logger, helpers
│   ├── prisma/
│   │   ├── schema.prisma
│   │   ├── migrations/
│   │   └── seed.ts
│   ├── tests/
│   ├── Dockerfile
│   ├── package.json
│   └── tsconfig.json
├── docs/
│   └── design_tokens.md
├── .github/workflows/
├── docker-compose.yml
└── README.md
```

This structure is fixed for Phase B. If a new concern emerges (for
example, AI fraud analysis), it is added under `backend/src/modules/`
as an isolated module — never mixed into the provider abstraction
layer.
