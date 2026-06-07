# MFS UNIFIED — Phase A — Risk Register

**Purpose.** Document project-delivery and security risks before Phase B
begins. Each risk is rated on **Likelihood** (1 rare – 5 almost certain),
**Impact** (1 trivial – 5 catastrophic), and given an **Owner**, a
**Mitigation**, and a **Contingency**.

Risks are grouped into the five categories required by the brief:

1. Android platform restrictions and OS-level limitations
2. Provider integration uncertainty (verified vs. unverified mechanics)
3. Google Play Store compliance and rejection risks
4. Technical debt accumulation and architectural vulnerabilities
5. Future migration paths (mock layer → live automation)

---

## Legend

| Rating | Likelihood | Impact |
|---|---|---|
| 1 | Rare | Negligible |
| 2 | Unlikely | Minor |
| 3 | Possible | Moderate |
| 4 | Likely | Major |
| 5 | Almost certain | Catastrophic |

**Risk Score** = Likelihood × Impact. Scores 15–25 are **HIGH**, 8–14 are
**MEDIUM**, 1–7 are **LOW**.

---

## 1. Android Platform Restrictions & OS-Level Limitations

| ID | Risk | L | I | Score | Mitigation | Contingency | Owner |
|---|---|---|---|---|---|---|---|
| R-AND-01 | Low-end OEM ROMs (Symphony, Walton, Xiaomi) customise the default dialer, breaking `tel:` / USSD pre-fill behaviour. | 4 | 3 | 12 (MEDIUM) | Test Phase B builds on physical devices for each OEM. Keep dialer pass-through as the only USSD path — no deeper automation. | If a ROM blocks the intent, fall back to copying the USSD string to the clipboard with a one-tap "copy & open dialer" action. | Mobile lead |
| R-AND-02 | Android 12+ intent resolution changes cause disambiguation dialogs on `tel:` launches. | 3 | 2 | 6 (LOW) | Use `Intent.ACTION_DIAL` with explicit `packageName` of the stock dialer when detectable. | Document the extra tap in onboarding copy. | Mobile lead |
| R-AND-03 | `RECEIVE_SMS` permission triggers additional Play scrutiny on Android 13+ even when not reading SMS content. | 3 | 3 | 9 (MEDIUM) | Declare only `RECEIVE_SMS`; never call `READ_SMS`. Use Android's SMS Retriever API scoped to our OTP hash. | Remove SMS receive entirely and rely on manual OTP entry. | Mobile lead |
| R-AND-04 | Biometric hardware on low-end devices is unreliable or missing. | 3 | 2 | 6 (LOW) | Make biometric optional; app-unlock PIN is the always-available fallback. | None required. | Mobile lead |
| R-AND-05 | Background execution limits on MIUI / One UI kill polling for long-running provider handoffs. | 4 | 3 | 12 (MEDIUM) | Use a foreground service with a non-dismissible notification during the processing step. Limit polling to ≤ 60 seconds. | Fall back to manual "tap to check status" with a deep-link back into the app. | Mobile lead |

---

## 2. Provider Integration Uncertainty

| ID | Risk | L | I | Score | Mitigation | Contingency | Owner |
|---|---|---|---|---|---|---|---|
| R-PRV-01 | Nagad merchant API documentation is gated; public specs are incomplete. | 5 | 3 | 15 (HIGH) | Build the Nagad adapter behind the Provider Integration Service interface so it can start as mock and become live with no UI change. Seek merchant onboarding in parallel with Phase B. | Ship MVP with Nagad as "coming soon" tile; enable bKash-only for launch. | Backend lead + Product |
| R-PRV-02 | Rocket (DBBL) has no published public developer API. | 5 | 3 | 15 (HIGH) | Same adapter isolation as Nagad. | Launch with Rocket stubbed. Re-engage DBBL post-MVP. | Backend lead + Product |
| R-PRV-03 | bKash Tokenized Checkout does not cover P2P Send Money / Cash Out. | 5 | 4 | 20 (HIGH) | Dialer pass-through fallback (Section 5 of FEASIBILITY_REVIEW). Treat P2P/Cash Out as out-of-scope for live API automation in Phase B. | Manual reconciliation: user taps "I completed this in bKash" and we trust the input for the local history. | Product + Mobile lead |
| R-PRV-04 | Provider APIs change versioning or endpoints without notice. | 3 | 3 | 9 (MEDIUM) | Version adapters explicitly. Run a nightly smoke test against each provider sandbox. | Pin to the last-known-good version behind a feature flag; alert on-call. | Backend lead |
| R-PRV-05 | Provider sandbox limits are too restrictive for load testing. | 3 | 2 | 6 (LOW) | Use recorded response fixtures for load tests; only hit sandbox for integration tests. | None required. | QA |
| R-PRV-06 | Provider rejects our integration after Play Store launch (contractual, not technical). | 2 | 5 | 10 (MEDIUM) | Engage provider partnership teams pre-launch; obtain written approval of the integration pattern. | Pull the provider tile from the UI within 24 hours; remaining providers still functional. | Product + Legal |

---

## 3. Google Play Store Compliance & Rejection Risks

| ID | Risk | L | I | Score | Mitigation | Contingency | Owner |
|---|---|---|---|---|---|---|---|
| R-PLY-01 | App rejected for declaring `RECEIVE_SMS` without being the default SMS handler. | 3 | 4 | 12 (MEDIUM) | Use SMS Retriever API (Google's recommended path for OTP autofill). Document core functionality in the Play Console declaration form. | Remove SMS autofill; require manual OTP entry. | Mobile lead |
| R-PLY-02 | App rejected under the financial-services policy for not being registered as a licensed financial entity. | 3 | 5 | 15 (HIGH) | Prepare the Play Store financial-services declaration, attach the provider partnership letters, and submit for pre-review before the first production track. | Distribute via direct APK for a closed beta while paperwork is finalised. | Product + Legal |
| R-PLY-03 | App flagged for accessibility-service misuse if any future USSD automation feature leaks into the build. | 2 | 5 | 10 (MEDIUM) | No `BIND_ACCESSIBILITY_SERVICE` permission in the manifest at any point in Phase B. Lint rule rejects commits that add it. | None required; the rule is a hard ban. | Mobile lead |
| R-PLY-04 | Data-safety form incomplete or inaccurate, leading to removal. | 3 | 3 | 9 (MEDIUM) | Draft data-safety form during Phase B, cross-checked against `SECURITY_REVIEW.md` and the actual manifest. Review with legal pre-submission. | None. | Product |
| R-PLY-05 | Policy change mid-development (e.g., new fintech rules announced by Google). | 2 | 4 | 8 (MEDIUM) | Monitor the [Google Play Developer Policy Center](https://play.google/developer-content-policy/) weekly. | Adjust scope within one sprint. | Product |

---

## 4. Technical Debt & Architectural Vulnerabilities

| ID | Risk | L | I | Score | Mitigation | Contingency | Owner |
|---|---|---|---|---|---|---|---|
| R-TEC-01 | `setState` leaks into screens under deadline pressure, defeating the Riverpod model. | 4 | 3 | 12 (MEDIUM) | Lint rule banning `setState` in `presentation/screens/`. Code-review checklist. | Refactor in the next sprint; do not block MVP. | Mobile lead |
| R-TEC-02 | `dynamic` or untyped JSON leaks across layer boundaries. | 3 | 3 | 9 (MEDIUM) | `flutter analyze --fatal-warnings`, TypeScript `strict: true` + Zod `.strict()` + Prisma typed client, `freezed` for all entities. | Refactor within the same sprint; treat as blocking. | Both leads |
| R-TEC-03 | Isar schema migrations handled ad-hoc, corrupting user data on upgrade. | 3 | 4 | 12 (MEDIUM) | Define a `schemaVersion` and an explicit `migrationTasks` map at app start. | Ship a one-time "rebuild local cache" path that re-fetches from backend. | Mobile lead |
| R-TEC-04 | Express route handlers grow into "fat controllers", mixing business logic with I/O. | 3 | 3 | 9 (MEDIUM) | Enforce the repository/service/handler split from day one. Code review. | Refactor before feature freeze. | Backend lead |
| R-TEC-05 | Missing API contract between mobile and backend leads to desync. | 3 | 4 | 12 (MEDIUM) | Auto-generate OpenAPI via `tsoa` or `express-openapi`. Generate Dart client stubs via a build step (openapi-generator). | Freeze endpoint signatures for the last two sprints. | Backend lead |
| R-TEC-06 | Secrets accidentally committed to git. | 3 | 5 | 15 (HIGH) | Pre-commit hooks (`gitleaks`, `trufflehog`) in CI and local. | Rotate secret immediately, rotate all dependents, write incident report. | DevOps |
| R-TEC-07 | Test coverage falls below safe threshold as MVP pressure mounts. | 4 | 3 | 12 (MEDIUM) | Enforce ≥ 70% backend coverage and ≥ 50% critical-path mobile coverage in CI. | Skip non-critical features until coverage is restored. | QA |

---

## 5. Future Migration Paths (Mock → Live Automation)

| ID | Risk | L | I | Score | Mitigation | Contingency | Owner |
|---|---|---|---|---|---|---|---|
| R-MIG-01 | Mock adapters become the de-facto product; stakeholders lose urgency to onboard live providers. | 4 | 4 | 16 (HIGH) | Each mock adapter carries a `STATUS: MOCK` badge in the UI and a visible "provider onboarding tracker" in the admin panel. | Escalate to investors/board if a provider is not live by MVP+6 months. | Product |
| R-MIG-02 | Live-adapter swap reveals incompatible DTO shape with the mock. | 3 | 4 | 12 (MEDIUM) | DTOs (`PaymentInitiation`, `PaymentStatus`, `PaymentReceipt`) are the contract; mocks must produce byte-identical shapes to live fixtures, verified by contract tests. | Ship a schema adapter per provider to translate live responses into the canonical DTO. | Backend lead |
| R-MIG-03 | Future decision to add USSD automation (Phase 2+) re-introduces the Google Play accessibility risk. | 3 | 5 | 15 (HIGH) | If USSD automation is pursued in Phase 2, ship it as a **separate** internal/enterprise APK, not the Play Store listing. | None. | Product + Mobile lead |
| R-MIG-04 | Adding AI fraud analytics pipeline later destabilises the core payment flow. | 2 | 3 | 6 (LOW) | Fraud pipeline lives in an isolated service (separate Docker container, own DB schema). Reads from an event stream; never on the payment hot path. | Defer fraud scoring to async post-transaction analysis. | Backend lead |
| R-MIG-05 | iOS support requested later, requiring a re-write of Android-specific layers. | 3 | 3 | 9 (MEDIUM) | Keep Android-only code (dialer intents, Android Keystore, biometric) behind `Platform.isAndroid` checks and abstract interfaces. iOS adapters can be added without touching `domain/` or `presentation/`. | None. | Mobile lead |

---

## 6. Risk Heatmap

```text
           Impact →
          1   2   3   4   5
L  5  |       |       |PRV01,02|PRV03|MIG01|
i  4  |       |       |TEC01,07|MIG01|     |
k  3  |       |       |TEC02,04|TEC03,05|PRV02,TEC06,PLY02,MIG03|
e  2  |       |       |       |PLY03|     |
l  1  |       |       |       |       |     |
```

Top five risks by score:

1. **R-PRV-03** — bKash P2P/Cash Out not covered by Tokenized Checkout (20, HIGH)
2. **R-MIG-01** — Mock adapters become the product (16, HIGH)
3. **R-PRV-01 / R-PRV-02** — Nagad / Rocket APIs gated or unpublished (15, HIGH)
4. **R-TEC-06** — Secrets committed to git (15, HIGH)
5. **R-PLY-02 / R-MIG-03** — Play Store financial-services rejection; future USSD automation re-introduces risk (15, HIGH)

---

## 7. Review Cadence

* Weekly: leads review open risks during the Phase B stand-up.
* Per sprint: risk register updated in `TASKS.md` alongside feature
  progress.
* Pre-Play-Store submission: full register audit with Product, Legal,
  and an external security reviewer.

---

## 8. Conclusion

No risk on this register is a blocker to starting Phase B. The highest
risks (provider API availability and the mock-adapter inertia) are
managed by the **provider abstraction interface** and by **explicit
product-level onboarding milestones**. The security risks are managed
by the controls in `SECURITY_REVIEW.md`. The Play Store risks are
managed by a pre-submission review and by excluding the most dangerous
permissions (Accessibility, `CALL_PHONE`, `READ_SMS`) from the manifest
entirely.

The project may proceed to Phase B with these risks actively tracked.
