# MFS UNIFIED — Phase A — Feasibility Review

**Purpose.** Determine whether Android natively permits the deep-link / intent
workflows required to unify bKash, Nagad, and Rocket behind a single Flutter
front-end, and verify which integration paths are documented, which are
unverified, and which must fall back to a mock adapter.

**Rules applied during this review.**

1. Every claim about Android capabilities, provider APIs, deep links, or
   permissions cites a public source. Where a claim cannot be verified, it is
   labelled **UNKNOWN** with a mitigation plan.
2. No provider API, SDK, or deep-link scheme has been fabricated.
3. This document does not contain code. It only records verified capabilities
   and the architectural consequences that flow from them.

---

## 1. Android Deep-Link and Intent Capabilities

### 1.1 Verified capabilities

| Capability | Evidence |
|---|---|
| Apps may declare `<intent-filter>` blocks with `<action android:name="android.intent.action.VIEW" />`, `CATEGORY_DEFAULT`, `CATEGORY_BROWSABLE`, and a custom or web `android:scheme` to receive inbound links. | [Android — Create deep links](https://developer.android.com/training/app-links/create-deeplinks) |
| App Links (verified `http`/`https`) open directly in the owning app, bypassing the disambiguation dialog. Custom-scheme links may still trigger the chooser on Android 12+. | [Android — Create deep links](https://developer.android.com/training/app-links/create-deeplinks) |
| Separate `<intent-filter>` blocks must be used for distinct scheme/host combinations — merging `<data>` elements inside a single filter produces unintended hybrid matches. | [Android — Create deep links](https://developer.android.com/training/app-links/create-deeplinks) |
| `TelecomManager` (`android.telecom.TelecomManager`) exposes `placeCall(Uri, Bundle)` which is the supported programmatic entry-point into the system dialer. | [Android — TelecomManager](https://developer.android.com/reference/kotlin/android/telecom/TelecomManager) |
| The `tel:` URI scheme is recognised by the system dialer. USSD strings containing `#` must be URL-encoded (`#` → `%23`) or the trailing character is stripped by the dialer/Chrome. | [Stack Overflow — Uri.parse with trailing #](https://stackoverflow.com/questions/16570488/how-to-use-uri-parse-with-at-the-end), [Stack Overflow — # stripped from tel: links](https://stackoverflow.com/questions/25890866/hash-key-stripped-from-ussd-code-in-tel-links-on-html-pages) |
| `ACTION_DIAL` (`Intent.ACTION_DIAL`) opens the dialer with a number pre-filled but **does not** auto-execute the call. `ACTION_CALL` executes immediately but requires the dangerous permission `android.permission.CALL_PHONE`. | [Android — TelecomManager](https://developer.android.com/reference/kotlin/android/telecom/TelecomManager) |

### 1.2 What Android does NOT permit

| Limitation | Implication |
|---|---|
| `tel:` links and USSD strings are **not** mentioned in the official deep-link documentation as intercept-able routes. Third-party apps cannot register themselves as handlers for `tel:`. | MFS Unified cannot intercept inbound USSD responses or outbound `tel:` intents as a system dialer. |
| Automated end-to-end USSD sessions (dial → parse popup → tap menu → enter PIN → send) require an `AccessibilityService` with `BIND_ACCESSIBILITY_SERVICE`. This permission is on Google Play's most-restrictive list and is routinely rejected unless the app is itself an accessibility tool. | Automated USSD orchestration is **not** a viable Play Store path. See Section 4. |
| `CALL_PHONE` and `READ_SMS` are classified as **sensitive permissions**. Their presence in a fintech app without a declared core use-case raises the probability of Play Store rejection. See [Google Play — Permissions policy](https://support.google.com/googleplay/android-developer/answer/9888170) (referenced in [April 2025 policy update](https://support.google.com/googleplay/android-developer/answer/15899442)). | MFS Unified's AndroidManifest must exclude them. The brief already mandates this. |

### 1.3 USSD automation feasibility — verdict

**UNKNOWN / HIGH RISK for full automation.**
The accessibility-service automation path used by products such as Hover (see [USSD has an accessibility problem — Medium](https://medium.com/use-hover/ussd-has-an-accessibility-problem-4c1c5ce74e28)) has been demonstrably brittle across OEM skins (MIUI, OneUI, Symphony/Walton stock ROMs) and is a known Play Store rejection trigger for non-accessibility apps
([Reddit — Google Play rejecting apps for AccessibilityService](https://www.reddit.com/r/GooglePlayDeveloper/comments/1rtqb5r/google_play_keeps_rejecting_my_app_for/),
[Stack Overflow — AccessibilityService rejection](https://stackoverflow.com/questions/70611393)).

**MFS Unified will not attempt multi-step USSD automation in Phase B.** Instead
it will offer a **dialer pass-through**: pre-fill the correct USSD string using
`ACTION_DIAL` with the `#` properly encoded, hand control to the user's native
dialer, and treat the provider's own app (or SMS receipt) as the source of
truth for completion. See Section 5.

---

## 2. Provider-Specific Integration Paths

### 2.1 bKash

**Verified.** bKash publishes a REST-based **Tokenized Checkout** API.

* Base flow: `token/grant` → `token/refresh` → `create` → `execute` →
  (optional) `query`, `search`, `refund`. `id_token` is valid for 1 hour,
  `refresh_token` for 28 days. All API calls have a 30-second timeout.
  Source: [bKash PGW — Checkout and Refund (PDF)](https://bkash.devarif.me/doc.pdf),
  [bKash PGW Terms](https://www.bkash.com/en/page/tokenized_checkout).
* Community reference implementations exist: [GitHub — shariar99/Android-Bkash-Payment-Gateway](https://github.com/shariar99/Android-Bkash-Payment-Gateway),
  [GitHub — Irfan-Chowdhury/bkash-tokenized-checkout](https://github.com/Irfan-Chowdhury/bkash-tokenized-checkout).
* Integration is **server-to-server**: the backend exchanges credentials with
  bKash; the Flutter client only receives a redirect URL / callback token.

**UNKNOWN.** bKash does **not** publish a public Android SDK for
**P2P Send Money** or **Cash Out** initiated from a third-party app. The
documented Tokenized Checkout flow covers *merchant payments* only.

**Consequence.** For P2P and Cash Out the MVP will use the **dialer
pass-through fallback** (Section 5) and record a local intent record keyed
by the recipient phone number, amount, and timestamp. Completion is
reconciled when the user returns to the app or when the backend receives a
matching SMS receipt hash (Phase 2).

### 2.2 Nagad

**Verified.** Nagad publishes an **Online Payment API** (merchant checkout).
Public guides reference endpoints for `registration/initialize`,
`registration/confirm`, `payment/checkout`, `payment/verify`, and
`payment/query`. Source: [Nagad Online Payment API Integration Guide v3.3
(Scribd)](https://www.scribd.com/document/684746071/Nagad-Online-Payment-API-Integration-Guide-v3-3),
[nopStation — Nagad Payment Documentation](https://www.nop-station.com/nagad-payment-documentation),
[Corefy — Nagad Connector](https://corefy.com/docs/connectors/nagad/).

**UNKNOWN.** The detailed endpoint URLs, payload schemas, and signing
mechanism are gated behind Nagad's merchant onboarding portal. The publicly
available documentation is incomplete. No official Android SDK was located.

**Consequence.** The backend will expose a **Nagad adapter behind the same
provider abstraction interface** used for bKash. Until merchant credentials
are provisioned, the adapter returns mock responses conforming to the same
`PaymentInitiation`, `PaymentStatus`, `PaymentReceipt` DTOs defined in the
domain layer. The adapter is swappable to live endpoints without changes to
the Flutter client.

### 2.3 Rocket (DBBL)

**Verified.** Rocket is Dutch-Bangla Bank Limited's mobile banking product.
Public marketing page: [DBBL Rocket](https://www.dutchbanglabank.com/rocket/rocket.html).
Rocket offers its own Android app (`com.dbbl.mbs.apps.main`) and is used
alongside card/bank services. EasyCommerce lists a Rocket checkout add-on,
indicating that Rocket participates in merchant checkout flows.
[EasyCommerce — Rocket Payment Integration](https://easycommerce.dev/addons/easycommerce-rocket).

**UNKNOWN.** No public developer-facing API specification, sandbox, or
Android SDK for Rocket was found in official DBBL documentation. The
EasyCommerce integration relies on a third-party middleware layer rather
than a Rocket-published API.

**Consequence.** Rocket is treated identically to Nagad: an adapter behind
the provider abstraction interface, returning mock DTOs in Phase B, with
the documented contract to be populated once DBBL onboarding credentials
are available.

---

## 3. Summary Matrix

| Capability | bKash | Nagad | Rocket | Source status |
|---|---|---|---|---|
| Merchant Payment API (server-to-server) | VERIFIED | VERIFIED (flow) | UNKNOWN | See 2.1 – 2.3 |
| P2P Send Money API | UNKNOWN | UNKNOWN | UNKNOWN | No public docs |
| Cash Out API (third-party) | UNKNOWN | UNKNOWN | UNKNOWN | No public docs |
| Official Android SDK | NONE FOUND | NONE FOUND | NONE FOUND | Search + GitHub |
| USSD shortcode | `*247#` (verified public) | `*167#` (verified public) | `*322#` (verified public) | Provider marketing |

---

## 4. Google Play Compliance

| Policy area | Risk | Mitigation |
|---|---|---|
| Accessibility-service USSD automation | HIGH — routine rejection | Not used. See Section 1.3. |
| `CALL_PHONE` / `READ_SMS` permissions | HIGH — flagged under sensitive permissions | Omitted from AndroidManifest per brief. |
| `RECEIVE_SMS` alone | MEDIUM — permitted for OTP autofill only | Declared only; contents never leave device. |
| Financial-services declaration | LOW — required for fintech apps | Complete Google Play financial-services declaration form pre-submission. |
| Biometric use (`USE_BIOMETRIC`, `USE_FINGERPRINT`) | LOW — standard | Use AndroidX BiometricPrompt, never custom. |

Sources: [Google Play Developer Policies](https://developer.android.com/distribute/play-policies),
[April 2025 policy announcement](https://support.google.com/googleplay/android-developer/answer/15899442).

---

## 5. Fallback Adapter Strategy — Dialer Pass-Through

When a provider API is UNKNOWN or a transaction type is P2P/Cash Out:

1. Flutter builds the USSD string from the QR-parsed phone number + amount,
   URL-encoding `#` as `%23`.
2. `url_launcher` (or `android_intent_plus`) invokes
   `Intent(ACTION_DIAL, Uri.parse('tel:<encoded>'))`. The system dialer
   opens with the USSD string pre-filled; the user presses the call button.
3. The provider's own USSD menu drives the transaction to completion.
4. MFS Unified records a **pending** `CachedTransaction` entry with
   `status = awaitingUserConfirmation`. When the user returns, the app
   prompts for the final status (success / failed / cancelled) and writes
   it to the local Isar database.

This approach:

* Avoids every prohibited permission.
* Works on low-end OEM ROMs (Symphony, Walton, Xiaomi, Samsung) because it
  uses the stock dialer.
* Keeps the provider's PIN entirely inside the provider's own stack —
  MFS Unified never sees it.

---

## 6. Conclusion and Recommendation

The project is **feasible** provided the following scope constraints are
accepted for Phase B:

* Merchant payments use the verified bKash Tokenized Checkout REST API via
  the Express backend. Nagad and Rocket merchant flows are stubbed behind
  the same interface and swapped in once credentials are onboarded.
* P2P Send Money and Cash Out rely on the dialer pass-through fallback.
* Automated USSD orchestration is **deferred** to a future phase and is
  explicitly excluded from the Play Store submission.
* The provider abstraction interface is designed on day one so that mock
  adapters can be replaced with live adapters without UI changes.

Phase B may proceed under these constraints.
