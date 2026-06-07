# MFS Unified — Design Tokens

Extracted from `stitch_unified_mfs_wallet/mfs_unified_design_system/DESIGN.md`
and the per-screen HTML exports. Source of truth for the Flutter theme
in `mobile/lib/core/constants/`.

---

## Colors (Material 3 tonal palette)

| Token | Hex | Role |
|---|---|---|
| `primary` | `#004AC6` | Anchor for unified actions (balance, transfers, settings) |
| `onPrimary` | `#FFFFFF` | Text/icons on primary |
| `primaryContainer` | `#2563EB` | Brand Indigo — hero surfaces |
| `onPrimaryContainer` | `#EEEFFF` | Text/icons on primaryContainer |
| `inversePrimary` | `#B4C5FF` | Primary in inverse contexts |
| `secondary` | `#B21474` | Secondary accent |
| `onSecondary` | `#FFFFFF` | |
| `secondaryContainer` | `#FE5AB1` | |
| `onSecondaryContainer` | `#64003E` | |
| `tertiary` | `#903A00` | |
| `onTertiary` | `#FFFFFF` | |
| `tertiaryContainer` | `#B74C00` | |
| `onTertiaryContainer` | `#FFECE5` | |
| `error` | `#BA1A1A` | Error states |
| `onError` | `#FFFFFF` | |
| `errorContainer` | `#FFDAD6` | |
| `onErrorContainer` | `#93000A` | |
| `surface` | `#FAF8FF` | Light background |
| `surfaceDim` | `#D2D9F4` | |
| `surfaceBright` | `#FAF8FF` | |
| `surfaceContainerLowest` | `#FFFFFF` | Cards |
| `surfaceContainerLow` | `#F2F3FF` | |
| `surfaceContainer` | `#EAEDFF` | |
| `surfaceContainerHigh` | `#E2E7FF` | |
| `surfaceContainerHighest` | `#DAE2FD` | |
| `onSurface` | `#131B2E` | Default text |
| `onSurfaceVariant` | `#434655` | Secondary text |
| `inverseSurface` | `#283044` | |
| `inverseOnSurface` | `#EEF0FF` | |
| `outline` | `#737686` | Borders, dividers |
| `outlineVariant` | `#C3C6D7` | Subtle borders |
| `surfaceTint` | `#0053DB` | Elevation tint |
| `background` | `#FAF8FF` | Page background |
| `onBackground` | `#131B2E` | |

### Provider brand accents (contextual)

| Provider | Primary | Usage |
|---|---|---|
| bKash | `#E2136E` | Magenta — provider chip, transaction icon bg, active selector ring |
| Nagad | `#F57B20` | Orange — provider chip, transaction icon bg |
| Rocket | `#8C3494` | Purple — provider chip, transaction icon bg |

### Semantic / functional colors

| Token | Hex | Role |
|---|---|---|
| `success` | `#008544` | Completed transactions, positive amounts |
| `pending` | same as `onSurfaceVariant` (`#434655`) | Pending transaction labels |
| Balance gradient start | `#004AC6` (`primary`) | Hero card gradient |
| Balance gradient end | `#002D7A` | Hero card gradient |

### Dark mode (documented, not yet generated as Flutter theme)

| Token | Hex |
|---|---|
| background | `#0B0E14` |
| card border | `#1E293B` |

---

## Typography

All roles use `Inter` except `label-md` which uses `Geist`.

| Role | Family | Weight | Size | Line height | Letter spacing |
|---|---|---|---|---|---|
| `displayLg` | Inter | 700 | 32 | 40 | -0.02em |
| `headlineMd` | Inter | 600 | 24 | 32 | -0.01em |
| `headlineMdMobile` | Inter | 600 | 20 | 28 | 0 |
| `titleLg` | Inter | 600 | 18 | 24 | 0 |
| `bodyLg` | Inter | 400 | 16 | 24 | 0 |
| `bodySm` | Inter | 400 | 14 | 20 | 0 |
| `labelMd` | Geist | 500 | 12 | 16 | +0.05em |
| `amountDisplay` | Inter | 700 | 28 | 34 | -0.03em |

---

## Spacing

Baseline grid: **8 px**. All spacing values below are multiples of 4 px.

| Token | px | rem |
|---|---|---|
| `base` / `xs` | 4 | 0.25 |
| `sm` | 8 | 0.5 |
| `md` | 16 | 1.0 |
| `lg` | 24 | 1.5 |
| `xl` | 32 | 2.0 |
| `marginMobile` | 20 | — |
| `gutterMobile` | 12 | — |

---

## Radii

| Token | px | Used for |
|---|---|---|
| `sm` | 4 | chips, small tags |
| `md` | 8 | input fields |
| `lg` | 12 | selectors, chips |
| `xl` | 16 | buttons |
| `card` | 24 | cards, transaction tiles |
| `full` | 9999 | provider avatars (circles) |

---

## Elevation

| Level | Style | Usage |
|---|---|---|
| 0 | `surface` color | Page background |
| 1 | `0px 12px 32px rgba(0,0,0,0.05)` | Cards (TransactionTile, BalanceCard) |
| 2 | `0px 20px 48px rgba(0,0,0,0.12)` | Modals, bottom sheets |
| glass | `backdrop-filter: blur(12px); bg-opacity 80%` | Bottom nav, top app bar |

---

## Sizing

| Component | Size |
|---|---|
| Primary action button height | 56 |
| Secondary action button height | 48 (min) |
| Provider avatar | 64 × 64 |
| Quick-send avatar | 56 × 56 |
| Transaction icon tile | 48 × 48, radius 16 |
| Touch target (min) | 48 × 48 |

---

## Components (Flutter mapping)

| Stitch component | Flutter widget | Notes |
|---|---|---|
| Top App Bar | `AppBar` with glassmorphic background | Blur 12, bg 80% opacity |
| Balance Card | `BalanceCard` widget | Gradient `primary` → `#002D7A`, radius 24, `amountDisplay` text |
| Provider Selector | `ProviderChip` | 64-circle, active ring `primary` 2px, inactive `outlineVariant` 1px |
| Scan QR button | `ElevatedButton` | `primaryContainer` bg, height 56, radius 12 |
| Transaction tile | `TransactionTile` | Radius 24, level-1 shadow, provider-tinted icon |
| Bottom navigation | `BottomNavigationBar` | Glassmorphic, `labelMd` under icons |
| Quick-send avatar | `QuickSendAvatar` | 56-circle, 2px white border + `primary/10` ring |

---

## Icon font

`Material Symbols Outlined` (weight/FILL axes). In Flutter this maps to
the `material_symbols_icons` package or the built-in `Icons` class with
equivalent names.

---

## Source files

- `stitch_unified_mfs_wallet/mfs_unified_design_system/DESIGN.md`
- `stitch_unified_mfs_wallet/home_dashboard/code.html`
- `stitch_unified_mfs_wallet/payment_details/code.html`
- `stitch_unified_mfs_wallet/qr_scanner/code.html`
- `stitch_unified_mfs_wallet/secure_authentication/code.html`
- `stitch_unified_mfs_wallet/processing_payment/code.html`
- `stitch_unified_mfs_wallet/success_summary/code.html`
