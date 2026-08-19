# Complete UI/UX Design System — DentisTrack (Master File)

> **LOGIC:** When building or designing any screen or component for DentisTrack, strictly follow the rules below.
> Complete reference is also mirrored in [`design-system/DENTISTRACK_DESIGN_SYSTEM.md`](file:///home/ghizlan/Desktop/steriqore_mobile/design-system/DENTISTRACK_DESIGN_SYSTEM.md).

---

## Project Context
This design system is built for **DentisTrack**, a SaaS HealthTech mobile and web application for dental practices. The platform manages **inventory, batch traceability, and sterilization cycles** across cabinets. The visual language translates the premium, minimal aesthetic into a **clinical, trustworthy, and highly efficient** interface — where every tap feels precise, every status is instantly readable, and compliance is visible at a glance.

The system serves three user profiles: **Administrator** (structure settings, users, rights), **Stock Manager / Assistant** (products, orders, lots, inventory), and **Practitioner** (consultation, scan-to-use, history). Every screen must support strict cabinet isolation, full audit trails, and medical-grade readability.

---

## 1. Visual Identity

### Overall Mood & Aesthetic
**"Clinical Confidence"** — A premium, hygienic aesthetic that conveys medical precision and trust. The interface feels as clean as a sterilized surface: generous whitespace, sharp hierarchy, and status colors that communicate safety instantly. The design recedes; the data — lots, DLCs, sterilization statuses — shines.

### Color Palette

| Token | HEX | Usage |
|-------|-----|-------|
| **Primary** | `#000000` | Primary buttons, active navigation, scan triggers, key UI chrome, sterilization histograms, primary text emphasis |
| **Primary Inverse** | `#FFFFFF` | Text on dark backgrounds, icons on dark surfaces, button text on primary buttons, text over sterilization status badges |
| **Secondary** | `#1C1C1E` | Secondary text, section headings, card titles, product names |
| **Accent** | `#007AFF` | Active links, selected tabs, interactive tints, pull-to-refresh, scan viewfinder reticle, operator assignment highlights |
| **Background Default** | `#F2F2F7` | Main app background behind scrollable content, web admin canvas |
| **Background Elevated** | `#FFFFFF` | Cards, bottom sheets, modals, input fields, top navigation, sterilization cycle forms |
| **Background Dark** | `#000000` | Bottom navigation bar, splash screen, dark modal overlays, scan camera overlay |
| **Surface Overlay** | `rgba(255, 255, 255, 0.15)` | Glassmorphism pills over camera preview (scan mode), floating status chips over images |
| **Text Primary** | `#000000` | Screen titles, product names, lot numbers, headings |
| **Text Secondary** | `#6C6C70` | Descriptions, supplier names, metadata, placeholder text |
| **Text Tertiary** | `#AEAEB2` | Disabled inputs, archived lots, old timestamps, expired DLC warnings (secondary) |
| **Text Inverse** | `#FFFFFF` | Text overlaid on camera preview, dark headers, sterilization status badges |
| **Border Subtle** | `#E5E5EA` | Card dividers, table row separators, input borders, list separators |
| **Border Strong** | `#C7C7CC` | Focused input borders, active filter borders |
| **Success** | `#34C759` | Validated sterilization cycle, stock OK, online sync, confirmation toasts |
| **Warning** | `#FF9500` | DLC approaching expiration, low stock alert, pending reception, cycle in progress |
| **Error** | `#FF3B30` | Failed sterilization cycle, expired DLC, stock outage, validation error, scan failure |
| **Info** | `#007AFF` | Informational badges, help tooltips, audit trail hints, operator notes |

### Gradients
- **Camera Overlay Gradient**: `linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.3) 40%, rgba(0,0,0,0) 100%)`
- **Hero Card Gradient**: `linear-gradient(to top, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0) 50%)`
- **Status Bar Gradient**: `linear-gradient(to right, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0) 100%)`

### Opacity & Transparency Usage
- **Disabled State**: `opacity: 0.4` applied to entire component
- **Backdrop Overlay**: `rgba(0, 0, 0, 0.4)` behind modals, bottom sheets, and scan confirmation dialogs
- **Glassmorphism**: `backdrop-filter: blur(20px)` with `background: rgba(255, 255, 255, 0.15)`
- **Skeleton Loading**: `opacity: 0.08` of primary color over `#F2F2F7` base
- **Pressed State**: `opacity: 0.8` or overlay `rgba(0,0,0,0.05)`
- **Archived / Historical**: `opacity: 0.6` on past sterilization cycles and expired lots

---

## 2. Typography

### Font Family
**Primary**: `-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Inter", "Segoe UI", Roboto, Helvetica, Arial, sans-serif`

### Type Scale

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Hero Title** | 36px | 700 (Bold) | 42px | -0.5px | Onboarding headlines, splash screen |
| **H1** | 28px | 700 (Bold) | 34px | -0.4px | Screen titles ("Sterilization", "Stock Overview") |
| **H2** | 22px | 700 (Bold) | 28px | -0.3px | Card titles (product name, cycle ID), modal headers |
| **H3** | 18px | 600 (Semibold) | 24px | -0.2px | Subsection headings ("Pending Cycles", "Low Stock") |
| **H4** | 16px | 600 (Semibold) | 22px | -0.1px | List item titles, form labels |
| **Body Large** | 17px | 400 (Regular) | 24px | -0.2px | Primary body text, descriptions, operator notes |
| **Body** | 15px | 400 (Regular) | 22px | -0.1px | Standard readable content, audit trail entries |
| **Body Small** | 13px | 400 (Regular) | 18px | 0px | Metadata (DLC, batch code, timestamp) |
| **Caption** | 12px | 400 (Regular) | 16px | 0.1px | Timestamps, helper text, badge labels |
| **Button Large** | 17px | 600 (Semibold) | 22px | -0.2px | Primary CTA buttons |
| **Button** | 15px | 600 (Semibold) | 20px | -0.1px | Standard buttons, action sheet options |
| **Nav Label** | 11px | 500 (Medium) | 14px | 0.2px | Bottom navigation labels |
| **Data Large** | 20px | 700 (Bold) | 26px | -0.3px | Stock quantity, cycle temperature |
| **Data** | 16px | 600 (Semibold) | 22px | -0.1px | Lot numbers, order references, device IDs |

---

## 3. Buttons

### Specifications
- **Primary Button**: Height 54px, Radius 27px (pill), Background `#000000`, Text `#FFFFFF`, Font 17px/600.
- **Secondary Button**: Height 48px, Radius 24px, Background `#F2F2F7`, Text `#000000`, Font 15px/600.
- **Outline Button**: Height 48px, Radius 24px, 1.5px solid `#000000`, Font 15px/600.
- **Ghost Button**: Height 44px, Radius 12px, Transparent, Text `#000000`, Font 15px/600.
- **Destructive Button**: Height 54px, Radius 27px, Background `#FF3B30`, Text `#FFFFFF`.
- **Icon Button**: 44px × 44px touch target, 50% circular or 14px radius.
- **Floating Action Button (FAB)**: 56px × 56px, Background `#000000`, Icon `#FFFFFF`, 24px from bottom-right.

---

## 4. Components

### Cards
- **Product Card**: Background `#FFFFFF`, Radius 20px, Shadow `0px 4px 20px rgba(0,0,0,0.08)`, 1:1 / 16:9 image aspect ratio.
- **Lot / Batch Card**: Background `#FFFFFF`, Radius 16px, monospace Lot #, DLC date with color coding (<30 days red).
- **Sterilization Cycle Card**: Background `#FFFFFF`, Radius 16px, 4px left semantic border (`#34C759`, `#FF9500`, `#FF3B30`).
- **Alert Card**: Background `#FFFFFF`, Radius 16px, 4px semantic accent bar.
- **Dashboard Stat Card**: Background `#FFFFFF`, Radius 16px, Padding 20px, large metric value (20px bold).

### Inputs
- **Text Field**: Height 52px, Radius 14px, Background `#F2F2F7`, Border 1.5px (transparent default, `#000000` focused).
- **Numeric Field**: Height 52px, `font-variant-numeric: tabular-nums`.
- **Date Field**: Height 52px, right calendar icon.
- **Text Area**: Min height 100px, Radius 14px, Padding 16px.
- **Search Bar**: Height 44px, Radius 22px (pill), search icon left, filter/barcode icon right.

### Navigation & Sheets
- **Bottom Navigation**: Background `#000000`, Height 64px + safe area, 32px pill or full-width, 5 tabs: *Home, Scan, Stock, Cycles, Profile*.
- **Top Navigation**: Height 56px + status bar, 44px touch targets.
- **Bottom Sheet**: Background `#FFFFFF`, Radius 24px top, 40px × 4px drag handle, snap points 25%/50%/85%.
- **Toasts**: Height ~48px, Radius 12px, Top-anchored, Success (`#34C759`), Error (`#FF3B30`), Warning (`#FF9500`).

---

## 5. Spacing, Radius & Tokens

| Token | Value | Token | Value | Token | Value |
|---|---|---|---|---|---|
| `space-4` | 4px | `radius-sm` | 8px | `icon-xs` | 16px |
| `space-8` | 8px | `radius-md` | 12px | `icon-sm` | 20px |
| `space-12` | 12px | `radius-lg` | 16px | `icon-md` | 24px |
| `space-16` | 16px | `radius-xl` | 20px | `icon-lg` | 32px |
| `space-20` | 20px | `radius-2xl` | 24px | `icon-xl` | 48px |
| `space-24` | 24px | `radius-full` | 9999px | `touchTarget` | 44px min / 48px |
| `space-32` | 32px | | | | |
| `space-48` | 48px | | | | |
| `space-64` | 64px | | | | |

---

## 6. Developer-Ready JSON Tokens

```json
{
  "color": {
    "primary": "#000000",
    "primaryInverse": "#FFFFFF",
    "secondary": "#1C1C1E",
    "accent": "#007AFF",
    "background": {
      "default": "#F2F2F7",
      "elevated": "#FFFFFF",
      "dark": "#000000"
    },
    "surfaceOverlay": "rgba(255, 255, 255, 0.15)",
    "text": {
      "primary": "#000000",
      "secondary": "#6C6C70",
      "tertiary": "#AEAEB2",
      "inverse": "#FFFFFF"
    },
    "border": {
      "subtle": "#E5E5EA",
      "strong": "#C7C7CC"
    },
    "semantic": {
      "success": "#34C759",
      "warning": "#FF9500",
      "error": "#FF3B30",
      "info": "#007AFF"
    }
  }
}
```
