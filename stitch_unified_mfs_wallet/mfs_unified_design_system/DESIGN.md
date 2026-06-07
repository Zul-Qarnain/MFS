---
name: MFS Unified Design System
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#434655'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#b21474'
  on-secondary: '#ffffff'
  secondary-container: '#fe5ab1'
  on-secondary-container: '#64003e'
  tertiary: '#903a00'
  on-tertiary: '#ffffff'
  tertiary-container: '#b74c00'
  on-tertiary-container: '#ffece5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#ffd8e6'
  secondary-fixed-dim: '#ffafd1'
  on-secondary-fixed: '#3d0024'
  on-secondary-fixed-variant: '#8b0059'
  tertiary-fixed: '#ffdbcb'
  tertiary-fixed-dim: '#ffb693'
  on-tertiary-fixed: '#341000'
  on-tertiary-fixed-variant: '#7a3000'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md-mobile:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  amount-display:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 20px
  gutter-mobile: 12px
---

## Brand & Style
The design system is engineered for a high-trust, premium fintech experience that bridges the gap between global neo-banking aesthetics and the local Bangladeshi mobile financial services landscape. The brand personality is **Professional, Efficient, and Harmonious**, aimed at users who require a unified, secure hub for managing multiple payment providers.

The visual style is **Corporate Modern with a Minimalist focus**. It utilizes heavy whitespace to reduce cognitive load in complex financial data environments. To ensure familiarity, the system incorporates high-fidelity visual cues—specifically tonal accents—that represent the diverse MFS providers (bKash, Nagad, Rocket) while maintaining a cohesive, "Global-Standard" container. The emotional goal is to evoke a sense of financial clarity and institutional reliability.

## Colors
The palette is led by **Primary Indigo (#2563EB)**, conveying stability and technological sophistication. This acts as the anchor for all "Unified" actions (Balance checks, Global transfers, Settings). 

To differentiate providers within the ecosystem, the system employs a "Contextual Accents" strategy:
- **bKash Context:** Magenta (#D2358D) is used for specific bKash-related statuses and icons.
- **Nagad Context:** Orange (#F37021) represents Nagad-specific touchpoints.
- **Rocket Context:** Purple (#6C2D91) identifies Rocket-specific flows.

**Light Mode (Default):** Uses a clean #FFFFFF base with subtle #F8FAFC surface tints for depth.
**Dark Mode:** Switches to a deep #0B0E14 charcoal black to maintain high contrast and reduce eye strain, ensuring that primary Indigo and provider accents remain vibrant and accessible.

## Typography
The system uses **Inter** for its exceptional legibility in digital interfaces and numerical clarity—critical for a fintech app. For specialized technical data and labels, **Geist** is introduced to provide a crisp, developer-grade aesthetic that reinforces the feeling of precision.

Numbers and currency (BDT) should always use the `amount-display` or `display-lg` styles with tighter letter spacing to create a distinctive "Neo-bank" look. Hierarchy is established through weight variation rather than excessive size changes to keep the mobile interface compact.

## Layout & Spacing
This is a **Mobile-First Fluid Grid** system. The standard layout uses a 4-column structure for mobile devices with a 20px outer margin. 

- **Vertical Rhythm:** Built on an 8px baseline grid. Components like cards and list items use `lg` (24px) or `xl` (32px) padding to ensure a premium, spacious feel.
- **Touch Targets:** All interactive elements (buttons, selectors) must maintain a minimum height of 48px.
- **Safe Areas:** Strictly observe bottom-notch safe areas for the fixed Navigation Bar to ensure accessibility on bezel-less devices.

## Elevation & Depth
The system uses **Tonal Layers** combined with **Ambient Shadows** to create a sense of hierarchy without clutter.

- **Level 0 (Background):** Primary surface color (#FFFFFF or #0B0E14).
- **Level 1 (Cards):** Raised using a very soft, diffused shadow: `0px 12px 32px rgba(0, 0, 0, 0.05)`. In dark mode, this is replaced by a subtle 1px border of `#1E293B`.
- **Level 2 (Modals/Popovers):** Higher elevation with a more pronounced shadow: `0px 20px 48px rgba(0, 0, 0, 0.12)`.

Glassmorphism is used exclusively for the **Bottom Navigation Bar** and **Top Header** (12px blur, 80% opacity) to maintain context of the content scrolling beneath it.

## Shapes
The shape language is **Decidedly Rounded**, reflecting the friendly and approachable nature of modern fintech. 

- **Primary Container/Cards:** Use a generous `24px` radius to create a "contained" and safe feeling for financial data.
- **Buttons:** Use a `16px` radius (Soft) rather than full pills to maintain a professional, structural look.
- **Selectors/Chips:** Smaller elements use a `12px` radius for consistency.

## Components
- **Action Buttons:** Primary buttons are 56px height, using the Primary Indigo background with white text. Use a slight inner glow in dark mode for depth.
- **Provider Selectors:** Horizontal scrolling list of rounded circles (64px) with provider logos. Active state indicated by a 2px Primary Indigo ring.
- **Transaction Cards:** 24px rounded corners. Left-side icon (Provider color-coded), center title (Merchant/Recipient), and right-side amount (Positive: Green, Negative: Neutral).
- **Bottom Navigation:** Glassmorphic background. Icons use a "Fill/Outline" logic to indicate active states, paired with the `label-md` typography.
- **Balance Card:** The hero component. Uses a gradient background (Primary Indigo to a darker shade) with the `amount-display` text in white.
- **Input Fields:** 1px border in Neutral-200. On focus, the border transitions to Primary Indigo with a 4px soft outer glow.