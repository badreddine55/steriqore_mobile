# Complete UI/UX Design System — DentisTrack

## Project Context
This design system is built for **DentisTrack**, a SaaS HealthTech mobile and web application for dental practices. The platform manages **inventory, batch traceability, and sterilization cycles** across cabinets. The visual language translates the premium, minimal aesthetic of the reference image into a **clinical, trustworthy, and highly efficient** interface — where every tap feels precise, every status is instantly readable, and compliance is visible at a glance.

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
- **Camera Overlay Gradient**: `linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.3) 40%, rgba(0,0,0,0) 100%)` — Applied to the bottom 50% of camera preview during scan mode to ensure scan result text readability.
- **Hero Card Gradient**: `linear-gradient(to top, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0) 50%)` — Applied to product/lot cards with embedded photos to ensure overlaid status badges and DLC text remain legible.
- **Status Bar Gradient**: `linear-gradient(to right, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0) 100%)` — Subtle fade for sticky section headers in long audit lists.

### Opacity & Transparency Usage
- **Disabled State**: `opacity: 0.4` applied to entire component (button, input, row)
- **Backdrop Overlay**: `rgba(0, 0, 0, 0.4)` behind modals, bottom sheets, and scan confirmation dialogs
- **Glassmorphism**: `backdrop-filter: blur(20px)` with `background: rgba(255, 255, 255, 0.15)` for floating scan status pills and camera-mode overlays
- **Skeleton Loading**: `opacity: 0.08` of primary color over `#F2F2F7` base
- **Pressed State**: `opacity: 0.8` or overlay `rgba(0,0,0,0.05)` on cards and list rows
- **Archived / Historical**: `opacity: 0.6` on past sterilization cycles and expired lots in read-only views

---

## 2. Typography

### Font Family
**Primary**: `-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Inter", "Segoe UI", Roboto, Helvetica, Arial, sans-serif`
- **SF Pro Display / Inter** for headings — tight, modern, geometric, conveying precision.
- **SF Pro Text / Inter** for body and data — optimized for readability of batch numbers, dates, and medical codes.

### Type Scale

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Hero Title** | 36px | 700 (Bold) | 42px | -0.5px | Onboarding headlines ("Traceability at your fingertips"), splash screen |
| **H1** | 28px | 700 (Bold) | 34px | -0.4px | Screen titles ("Sterilization", "Stock Overview"), major section headers |
| **H2** | 22px | 700 (Bold) | 28px | -0.3px | Card titles (product name, cycle ID), modal headers |
| **H3** | 18px | 600 (Semibold) | 24px | -0.2px | Subsection headings ("Pending Cycles", "Low Stock"), filter group titles |
| **H4** | 16px | 600 (Semibold) | 22px | -0.1px | List item titles (lot number, supplier name), form labels |
| **Body Large** | 17px | 400 (Regular) | 24px | -0.2px | Primary body text, product descriptions, operator notes |
| **Body** | 15px | 400 (Regular) | 22px | -0.1px | Standard readable content, audit trail entries, movement history |
| **Body Small** | 13px | 400 (Regular) | 18px | 0px | Metadata (DLC, batch code, timestamp), secondary details |
| **Caption** | 12px | 400 (Regular) | 16px | 0.1px | Timestamps, helper text, badge labels, unit abbreviations |
| **Button Large** | 17px | 600 (Semibold) | 22px | -0.2px | Primary CTA buttons ("Validate Cycle", "Scan Label") |
| **Button** | 15px | 600 (Semibold) | 20px | -0.1px | Standard buttons, action sheet options |
| **Nav Label** | 11px | 500 (Medium) | 14px | 0.2px | Bottom navigation labels |
| **Data Large** | 20px | 700 (Bold) | 26px | -0.3px | Stock quantity, cycle temperature, critical metric values |
| **Data** | 16px | 600 (Semibold) | 22px | -0.1px | Lot numbers, order references, device IDs |

### Typography Rules
- **Headings** always use negative letter-spacing for a tighter, more authoritative feel.
- **Body text** never goes below 13px on mobile to maintain readability of medical codes and dates.
- **Data values** (stock counts, temperatures, cycle durations) are bold/semibold and slightly larger than surrounding metadata to create instant visual hierarchy.
- **Monospace for codes**: Lot numbers, DataMatrix content, and audit IDs should use `font-variant-numeric: tabular-nums` to prevent width jitter during updates.
- **Text over camera previews / images** must always use inverse colors with sufficient contrast (WCAG AA minimum).

---

## 3. Buttons

### Button System Specifications

#### Primary Button
- **Height**: 54px
- **Border Radius**: 27px (fully pill-shaped)
- **Padding**: 0px 24px
- **Background**: `#000000`
- **Text Color**: `#FFFFFF`
- **Font**: Button Large (17px / 600)
- **Icon Size**: 20px (left or right of text, 8px gap)
- **Normal**: Solid black, white text, subtle shadow `0px 4px 12px rgba(0,0,0,0.15)`
- **Pressed**: Scale to `0.97`, background `#1C1C1E`, shadow `0px 2px 6px rgba(0,0,0,0.1)`
- **Disabled**: Background `#E5E5EA`, text `#AEAEB2`, no shadow, `opacity: 1` (use color change, not opacity)
- **Loading**: Spinner replaces text or icon, spinner color `#FFFFFF`, background unchanged
- **Usage**: "Validate Sterilization Cycle", "Confirm Reception", "Generate Label", "Save Movement"

#### Secondary Button
- **Height**: 48px
- **Border Radius**: 24px
- **Padding**: 0px 20px
- **Background**: `#F2F2F7`
- **Text Color**: `#000000`
- **Font**: Button (15px / 600)
- **Normal**: Light gray fill, black text
- **Pressed**: Background `#E5E5EA`, scale `0.97`
- **Disabled**: Background `#F2F2F7`, text `#C7C7CC`
- **Usage**: "Add Note", "Reprint Label", "View History", "Cancel"

#### Outline Button
- **Height**: 48px
- **Border Radius**: 24px
- **Padding**: 0px 20px
- **Background**: Transparent
- **Border**: 1.5px solid `#000000`
- **Text Color**: `#000000`
- **Font**: Button (15px / 600)
- **Normal**: Transparent with black border
- **Pressed**: Background `rgba(0,0,0,0.05)`, scale `0.97`
- **Disabled**: Border `#E5E5EA`, text `#C7C7CC`
- **Usage**: "Export CSV", "Filter", "Connect Device", "Manual Entry"

#### Ghost / Text Button
- **Height**: 44px
- **Border Radius**: 12px
- **Padding**: 0px 16px
- **Background**: Transparent
- **Text Color**: `#000000`
- **Font**: Button (15px / 600)
- **Normal**: No background
- **Pressed**: Background `rgba(0,0,0,0.05)`
- **Disabled**: Text `#AEAEB2`
- **Usage**: "Forgot Password?", "View Audit", "Change Operator", "Skip"

#### Destructive Button
- Same dimensions as Primary Button
- **Background**: `#FF3B30`
- **Text Color**: `#FFFFFF`
- **Pressed**: Background `#D70015`
- **Usage**: "Delete Product", "Invalidate Cycle", "Clear Scan", "Remove User"

#### Icon Button
- **Size**: 44px × 44px (minimum touch target)
- **Border Radius**: 50% (circular) or 14px (rounded square)
- **Background**: Transparent or `rgba(255,255,255,0.9)` with `backdrop-filter: blur(10px)`
- **Icon Size**: 24px
- **Icon Color**: `#000000` or `#FFFFFF` depending on context
- **Pressed**: Background `rgba(0,0,0,0.05)` or `rgba(255,255,255,0.7)`, scale `0.92`
- **Usage**: Close scan view, toggle torch, favorite product, share audit report, back navigation

#### Floating Action Button (FAB)
- **Size**: 56px × 56px
- **Border Radius**: 50% (circular)
- **Background**: `#000000`
- **Icon**: 24px, `#FFFFFF` (scan icon, plus icon, or quick-action icon)
- **Shadow**: `0px 8px 24px rgba(0,0,0,0.25)`
- **Position**: 24px from bottom-right edge (above bottom nav)
- **Pressed**: Scale `0.95`, shadow reduces
- **Usage**: Quick scan from any screen, add movement, create cycle

---

## 4. Components

### Cards

**Product Card**
- **Background**: `#FFFFFF`
- **Border Radius**: 20px
- **Shadow**: `0px 4px 20px rgba(0,0,0,0.08)`
- **Padding**: 0px (image bleeds to edges) or 16px (compact list variant)
- **Image Aspect Ratio**: 1:1 (product photo) or 16:9 (product hero)
- **Image Border Radius**: 20px (hero) or 12px (thumbnail in list)
- **Content Padding**: 16px when text is below image
- **Elements**: Product name (H4), stock quantity (Data Large, color-coded), family chip, DLC alert badge if applicable
- **Spacing Between Cards**: 16px vertical
- **Pressed State**: Scale `0.98`, shadow reduces to `0px 2px 8px rgba(0,0,0,0.06)`

**Lot / Batch Card**
- **Background**: `#FFFFFF`
- **Border Radius**: 16px
- **Shadow**: `0px 2px 12px rgba(0,0,0,0.06)`
- **Padding**: 16px
- **Elements**: Lot number (Data, monospace), DLC date (Body Small, red if <30 days), supplier, quantity received, status badge
- **Right Action**: Chevron or contextual menu icon

**Sterilization Cycle Card**
- **Background**: `#FFFFFF`
- **Border Radius**: 16px
- **Shadow**: `0px 2px 12px rgba(0,0,0,0.06)`
- **Padding**: 16px
- **Elements**: Cycle ID (H4), device name + program (Body Small), operator avatar + name, timestamp, status badge (Success/Warning/Error), attachment icon if report present
- **Color Coding**: Left border 4px solid matching status color (`#34C759`, `#FF9500`, `#FF3B30`)

**Alert Card**
- **Background**: `#FFFFFF`
- **Border Radius**: 16px
- **Shadow**: `0px 4px 16px rgba(0,0,0,0.08)`
- **Padding**: 16px
- **Left Accent**: 4px vertical bar in semantic color
- **Elements**: Alert type icon (24px), alert title (H4), description (Body Small), timestamp (Caption), action button (Ghost)

**Small Info Card (Dashboard Stat)**
- **Background**: `#FFFFFF`
- **Border Radius**: 16px
- **Shadow**: `0px 2px 12px rgba(0,0,0,0.06)`
- **Padding**: 20px
- **Elements**: Metric label (Caption, `#6C6C70`), metric value (Data Large), trend indicator (optional)

### Inputs

**Text Field**
- **Height**: 52px
- **Background**: `#F2F2F7`
- **Border Radius**: 14px
- **Padding**: 0px 16px
- **Font**: Body Large (17px / 400)
- **Text Color**: `#000000`
- **Placeholder Color**: `#AEAEB2`
- **Border**: 1.5px solid transparent (default), `#000000` (focused)
- **Icon**: 20px, `#8E8E93`, positioned 16px from left (e.g., search, product, user)
- **Clear Button**: 20px circle, `#C7C7CC`, appears when text entered
- **Usage**: Product name, supplier search, operator name, batch number entry

**Numeric Field**
- Same as Text Field but with `font-variant-numeric: tabular-nums`
- **Keyboard Type**: Numeric
- **Usage**: Quantity received, stock adjustment, cycle temperature, duration

**Date Field (DLC / DDM)**
- **Height**: 52px
- **Background**: `#F2F2F7`
- **Border Radius**: 14px
- **Padding**: 0px 16px
- **Right Icon**: Calendar icon, 20px, `#8E8E93`
- **Font**: Body Large (17px / 400)
- **Usage**: Expiration date input, cycle date, order date

**Text Area**
- **Min Height**: 100px
- **Background**: `#F2F2F7`
- **Border Radius**: 14px
- **Padding**: 16px
- **Font**: Body (15px / 400)
- **Usage**: Operator notes, cycle observation, reception comment, audit justification

**Search Bar**
- **Height**: 44px
- **Background**: `#F2F2F7`
- **Border Radius**: 22px (pill)
- **Padding**: 0px 16px
- **Font**: Body (15px / 400)
- **Placeholder**: "Search product, lot, or reference..."
- **Search Icon**: 18px, `#8E8E93`, left-aligned
- **Filter Icon**: 20px, `#000000`, right-aligned (opens filter bottom sheet)
- **Barcode Icon**: 20px, `#000000`, right-aligned (triggers camera scan)

### Dropdowns / Selects
- **Height**: 52px
- **Background**: `#F2F2F7`
- **Border Radius**: 14px
- **Padding**: 0px 16px
- **Chevron Icon**: 20px, `#8E8E93`, right side
- **Sheet Trigger**: Tapping opens a Bottom Sheet with selectable options
- **Selected State**: Background `#000000`, text `#FFFFFF`, pill shape
- **Usage**: Select sterilization device, choose program, assign operator, select supplier, pick product family

### Checkboxes
- **Size**: 24px × 24px
- **Border Radius**: 6px
- **Border**: 2px solid `#C7C7CC` (unchecked), `#000000` (checked)
- **Checked**: Background `#000000`, white checkmark icon (16px)
- **Pressed**: Scale `0.92`
- **Usage**: Select multiple lots for export, checklist in sterilization validation, select movements for batch action

### Radio Buttons
- **Size**: 24px × 24px
- **Border Radius**: 50%
- **Border**: 2px solid `#C7C7CC` (unchecked), `#000000` (selected)
- **Selected**: Inner dot 12px, `#000000`
- **Pressed**: Scale `0.92`
- **Usage**: Choose reception type (total/partial), select cycle result (pass/fail), pick user role

### Switches (Toggles)
- **Size**: 51px × 31px (iOS standard)
- **Border Radius**: 15.5px
- **Off State**: Background `#E5E5EA`, thumb `#FFFFFF`
- **On State**: Background `#34C759` (success green) for operational toggles; `#000000` for preference toggles
- **Thumb Shadow**: `0px 2px 4px rgba(0,0,0,0.15)`
- **Thumb Size**: 27px diameter
- **Pressed**: Thumb expands slightly to 31px
- **Usage**: Enable low-stock alerts, DLC reminders, notification push, offline mode

### Tabs

**Segmented Control**
- **Height**: 36px
- **Background**: `#F2F2F7`
- **Border Radius**: 10px
- **Active Segment**: Background `#FFFFFF`, shadow `0px 2px 6px rgba(0,0,0,0.08)`, text `#000000`
- **Inactive Segment**: Background transparent, text `#6C6C70`
- **Font**: Button (15px / 500)
- **Divider**: None
- **Usage**: "Stock / Movements / History", "All / Validated / Failed" cycles

**Underline Tabs**
- **Height**: 44px
- **Active**: Text `#000000`, 2px bottom border `#000000`
- **Inactive**: Text `#8E8E93`, no border
- **Font**: Button (15px / 500)
- **Usage**: Dashboard sections ("Overview", "Alerts", "Audit")

### Bottom Navigation
- **Background**: `#000000`
- **Height**: 64px + safe area
- **Border Radius**: 32px (floating pill style) OR full-width with 24px top radius
- **Position**: Floating 16px from bottom edges with 16px horizontal margin, OR full-width
- **Item Count**: 4–5 items max
- **Icon Size**: 24px
- **Items**:
  1. **Home** (house icon) — Dashboard / Overview
  2. **Scan** (barcode/scan icon) — Camera scan mode
  3. **Stock** (box/archive icon) — Products and lots
  4. **Cycles** (sterilization/autoclave icon) — Sterilization tracking
  5. **Profile** (user icon) — Account, settings, audit access
- **Active**: Icon `#FFFFFF`, label `#FFFFFF`
- **Inactive**: Icon `rgba(255,255,255,0.5)`, label `rgba(255,255,255,0.5)`
- **Active Indicator**: Optional dot 4px below icon, `#FFFFFF`
- **Font**: Nav Label (11px / 500)
- **Shadow** (if floating): `0px 8px 24px rgba(0,0,0,0.3)`

### Top Navigation / Header
- **Background**: `#FFFFFF` or transparent (over images / camera)
- **Height**: 56px + status bar
- **Left**: Back button (44px touch target) or hamburger menu
- **Center**: Screen title, H3 (18px / 600) — e.g., "Lot #48291", "New Cycle"
- **Right**: Action icons (share audit, filter list, add product) — 44px touch targets
- **Border Bottom**: 0.5px solid `#E5E5EA` (when on white background)
- **Blur Header** (over camera/scanner): `backdrop-filter: blur(20px)`, background `rgba(255,255,255,0.85)`

### Modals

**Center Modal**
- **Background**: `#FFFFFF`
- **Border Radius**: 20px
- **Padding**: 24px
- **Max Width**: 340px
- **Shadow**: `0px 20px 40px rgba(0,0,0,0.3)`
- **Backdrop**: `rgba(0,0,0,0.4)` with `backdrop-filter: blur(3px)`
- **Usage**: Confirm cycle validation, confirm user deletion, critical alert detail

**Scan Result Modal**
- **Background**: `#FFFFFF`
- **Border Radius**: 24px top-left, 24px top-right (bottom sheet style)
- **Padding**: 24px
- **Elements**: Scanned code (Data Large), product/lot info, action buttons ("Use this lot", "View history", "Cancel")
- **Backdrop**: Camera preview dimmed to `rgba(0,0,0,0.5)`

### Bottom Sheets

**Filter / Select Sheet**
- **Background**: `#FFFFFF`
- **Border Radius**: 24px top-left, 24px top-right
- **Handle**: 40px × 4px, `#E5E5EA`, centered at top, 8px from edge
- **Padding**: 24px horizontal, 20px top (below handle)
- **Max Height**: 90% of screen
- **Backdrop**: `rgba(0,0,0,0.4)`
- **Scroll**: Content scrolls internally if exceeding max height
- **Snap Points**: 25%, 50%, 85%
- **Usage**: Filter lots by status/DLC, select sterilization device, choose operator, pick product family, export options

**Action Sheet**
- Same structure as Filter Sheet
- **Elements**: List of actions with icon + text, destructive action in red, cancel button at bottom
- **Usage**: "Reprint label", "Edit lot", "View audit", "Delete" (destructive)

### Toasts / Alerts

**Success Toast**
- **Background**: `#34C759`
- **Text**: `#FFFFFF`, Body (15px / 500)
- **Border Radius**: 12px
- **Padding**: 14px 20px
- **Position**: Top of screen, 16px from top edge, 16px horizontal margin
- **Icon**: 20px checkmark, left of text
- **Duration**: 3 seconds
- **Shadow**: `0px 4px 12px rgba(52,199,89,0.3)`
- **Usage**: "Cycle validated", "Stock movement saved", "Label printed", "Reception confirmed"

**Error Toast**
- Same structure, background `#FF3B30`, shadow `0px 4px 12px rgba(255,59,48,0.3)`
- **Usage**: "Scan failed", "Invalid lot", "Sync error", "Cycle validation failed"

**Warning Toast**
- Background `#FF9500`, shadow `0px 4px 12px rgba(255,149,0,0.3)`
- **Usage**: "DLC expires in 7 days", "Stock below threshold", "Network weak — data queued"

**Info Snackbar**
- Background `#1C1C1E`, text `#FFFFFF`, optional action button in `#007AFF`
- **Usage**: "Audit trail updated", "New protocol available"

### Badges

- **Height**: 20px
- **Padding**: 0px 8px
- **Border Radius**: 10px
- **Font**: Caption (12px / 600)
- **Variants**:
  - **Primary**: `#000000` bg, `#FFFFFF` text — "New", "Updated"
  - **Success**: `#34C759` bg, `#FFFFFF` text — "Validated", "OK", "Pass"
  - **Warning**: `#FF9500` bg, `#FFFFFF` text — "Pending", "Near DLC", "Low Stock"
  - **Error**: `#FF3B30` bg, `#FFFFFF` text — "Failed", "Expired", "Outage"
  - **Info**: `#007AFF` bg, `#FFFFFF` text — "In Progress", "Draft"
  - **Outline**: Transparent bg, `#000000` border, `#000000` text — "Archived", "Read-only"

### Chips / Tags

- **Height**: 36px
- **Padding**: 0px 16px
- **Border Radius**: 18px (pill)
- **Font**: Button (15px / 500)
- **Default**: Background `#F2F2F7`, text `#000000`
- **Selected**: Background `#000000`, text `#FFFFFF`
- **Pressed**: Scale `0.95`
- **Icon**: 16px, 6px gap from text
- **Usage**: Product families (Implants, Instruments, Consumables), filter by status (All / Validated / Failed / Expired), alert types (Stock / DLC / Sterilization)

### Avatars

- **Sizes**:
  - Small: 32px (list items, operator in cycle card)
  - Medium: 44px (profile menu, settings)
  - Large: 64px (profile header)
  - XL: 96px (user profile, onboarding)
- **Border Radius**: 50% (circular)
- **Border**: 2px solid `#FFFFFF` (when overlapping or on dark backgrounds)
- **Placeholder**: Background `#E5E5EA`, initials in `#8E8E93`, font scaled to size (e.g., "JD" for John Doe)
- **Status Indicator**: 10px dot, positioned bottom-right, border 2px `#FFFFFF`
  - Online / Active: `#34C759`
  - Away / Busy: `#FF9500`
  - Offline: `#AEAEB2`

### Progress Indicators

**Circular Spinner**
- **Size**: 24px (standard), 48px (loading screen)
- **Color**: `#000000` (light bg), `#FFFFFF` (dark bg), `#007AFF` (accent)
- **Stroke Width**: 2.5px
- **Animation**: 360° rotation, 1s linear infinite
- **Usage**: Syncing data, loading lot history, validating cycle

**Linear Progress**
- **Height**: 4px
- **Background**: `#E5E5EA`
- **Fill**: `#000000`
- **Border Radius**: 2px
- **Usage**: Uploading attachment, batch import progress

**Sterilization Cycle Progress**
- **Height**: 8px
- **Background**: `#E5E5EA`
- **Fill**: `#34C759` (in progress), `#007AFF` (waiting)
- **Border Radius**: 4px
- **Usage**: Visual indicator of cycle phase (Pre-wash → Sterilization → Drying)

**Skeleton Loader**
- **Base**: `#F2F2F7`
- **Shimmer**: Linear gradient animation, `rgba(255,255,255,0.5)` to transparent
- **Border Radius**: Matches content shape (14px for text, 20px for cards, 50% for avatars)

### Empty States

- **Icon**: 80px, `#E5E5EA` (outlined style — box, scan, cycle, or alert icon)
- **Title**: H3 (18px / 600), `#000000`, centered
- **Message**: Body (15px / 400), `#6C6C70`, centered, max-width 280px
- **Action**: Primary or Ghost button below, 24px spacing
- **Examples**:
  - No lots: "No lots found" + "Create your first lot"
  - No cycles: "No sterilization cycles" + "Start a cycle"
  - No alerts: "All clear — no alerts"
  - No scan result: "No product found for this code"
- **Illustration**: `[BACKGROUND_IMAGE: soft minimalist medical illustration of a clean dental workspace, monochrome palette, subtle shading, friendly but professional tone]`

### Loading / Skeleton States

- **Dashboard**: Stat cards show as gray rectangles, chart area as rounded block
- **Product List**: 4–5 product cards with image placeholder (20px radius gray block), title lines, and price lines
- **Lot List**: Rows with circular avatar placeholder, 2–3 text lines each
- **Cycle List**: Cards with top gray block (device image), 3 text lines, badge placeholder
- **Audit Trail**: Rows with timestamp placeholder, user placeholder, action placeholder
- Maintain exact layout structure, replace content with skeleton shapes

### Error States

- **Icon**: 64px, `#FF3B30` (alert circle or warning triangle)
- **Title**: H3, `#000000`
- **Message**: Body, `#6C6C70`
- **Retry Button**: Primary button, "Try Again"
- **Secondary Action**: Ghost button, "Contact Support" (if applicable)
- **Full-screen errors**: Centered content with 48px spacing between elements
- **Examples**: "Failed to load stock", "Sync error", "Camera permission denied", "Invalid sterilization device connection"

---

## 5. Layout & Spacing

### Screen Margins & Padding
- **Horizontal Screen Padding**: 24px (standard), 16px (compact/dense screens like lists with many rows)
- **Top Safe Area**: Respect device notch/status bar (44px–59px on iOS)
- **Bottom Safe Area**: Respect home indicator (34px on modern iPhones)

### Vertical Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `space-4` | 4px | Tight icon gaps, inline spacing, badge internal padding |
| `space-8` | 8px | Tight component padding, icon-text gaps, checkbox-label gap |
| `space-12` | 12px | Small gaps between related elements (label + input) |
| `space-16` | 16px | Standard component padding, card internal padding, card gaps |
| `space-20` | 20px | Section internal padding, dashboard stat grid gap |
| `space-24` | 24px | Screen horizontal padding, section breaks, modal padding |
| `space-32` | 32px | Major section spacing (between dashboard sections) |
| `space-48` | 48px | Large section dividers, onboarding page gaps |
| `space-64` | 64px | Hero spacing, empty state vertical centering |

### Grid System
- **Columns**: Single-column layout for mobile (100% width minus 48px padding)
- **Two-column Grid**: Gap 16px, each item `(screenWidth - 56px) / 2` — used for dashboard stat cards, product family grid
- **Three-column Grid**: Gap 12px, each item `(screenWidth - 72px) / 3` — used for quick action buttons, status summary
- **Alignment**: All content left-aligned; centered only for empty states, auth screens, modals, and scan confirmation

### Component Spacing
- **Between Cards**: 16px
- **Between Sections**: 32px
- **Between Form Fields**: 16px
- **Between Buttons in a Row**: 12px
- **Button to Content**: 24px
- **Header to Content**: 24px
- **List Item Padding**: 16px vertical, 24px horizontal
- **Table Row Height**: 56px minimum

### Border Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 8px | Small buttons, tags, input fields, table row inner elements |
| `radius-md` | 12px | Standard buttons, small cards, toasts, thumbnail images |
| `radius-lg` | 16px | Medium cards (lot, cycle, alert), modals, images in cards |
| `radius-xl` | 20px | Large cards (product hero, dashboard panels), content containers |
| `radius-2xl` | 24px | Bottom sheets, camera preview overlays, auth forms |
| `radius-full` | 9999px | Pills, FABs, avatars, circular buttons, scan reticle |

### Icon Sizing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `icon-xs` | 16px | Inline text icons, chip icons, table action icons |
| `icon-sm` | 20px | Input icons, small buttons, badge icons |
| `icon-md` | 24px | Standard UI icons, nav icons, card action icons |
| `icon-lg` | 32px | Section icons, feature highlights, empty state icons |
| `icon-xl` | 48px | Empty state icons, scan mode icons, large actions |

### Touch Target Sizes
- **Minimum Touch Target**: 44px × 44px (Apple HIG standard)
- **Preferred Touch Target**: 48px × 48px (Material Design standard)
- **Button Minimum Height**: 44px
- **Primary CTA Minimum Height**: 54px
- **Spacing Between Touch Targets**: Minimum 8px
- **List Row Minimum Height**: 56px (to accommodate touch targets for swipe actions)

---

## 6. Background Images

### Where Background Images Appear

**1. Onboarding / Welcome Screen**
- **Placement**: Full-bleed background covering entire screen
- **Aspect Ratio**: 9:19.5 (iPhone full screen) or 9:16 (standard)
- **Overlay Treatment**:
  - Bottom gradient: `linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.3) 40%, transparent 100%)`
  - Top gradient (optional): `linear-gradient(to bottom, rgba(0,0,0,0.3) 0%, transparent 30%)`
- **Text Placement**: Bottom third of screen, left-aligned with 24px padding
- **Text Color**: `#FFFFFF` with text shadow `0px 2px 8px rgba(0,0,0,0.5)` for extra safety
- **Placeholder**: `[BACKGROUND_IMAGE: modern dental clinic interior with sterilization equipment and organized instrument trays, soft natural lighting, shallow depth of field, clean white and steel tones, cinematic composition, space for text overlay at bottom]`

**2. Authentication Screens**
- **Placement**: Full-bleed background
- **Overlay**: `rgba(0,0,0,0.5)` solid + bottom gradient
- **Form Placement**: Bottom sheet style overlay, white background, 24px top radius
- **Placeholder**: `[BACKGROUND_IMAGE: close-up of professional dental instruments neatly arranged on a sterilization tray, dark moody lighting, blurred background, clinical and trustworthy atmosphere suitable for login form overlay]`

**3. Dashboard / Home Hero**
- **Placement**: Top of dashboard, full width
- **Aspect Ratio**: 16:9 or 3:1 (banner style)
- **Overlay**: Bottom gradient `linear-gradient(to top, rgba(0,0,0,0.5) 0%, transparent 60%)`
- **Text**: Cabinet name, today's date, quick summary stats overlaid bottom-left
- **Placeholder**: `[BACKGROUND_IMAGE: wide-angle view of a modern dental practice workspace, bright and hygienic, soft bokeh, space for dashboard text overlay at bottom]`

**4. Profile / Account Header**
- **Placement**: Top 25% of screen
- **Aspect Ratio**: 3:1
- **Overlay**: Subtle dark gradient if avatar/text overlaid
- **Placeholder**: `[BACKGROUND_IMAGE: abstract soft gradient or textured medical surface in muted gray and white tones, suitable for profile header with avatar overlay]`

**5. Empty States / Onboarding Illustrations**
- **Placement**: Center of screen, 200px–280px height
- **Overlay**: None
- **Placeholder**: `[BACKGROUND_IMAGE: friendly minimalist vector-style illustration of a dental professional scanning a barcode on an instrument package, monochrome palette with subtle blue accent, clean lines, transparent background feel]`

**6. Scan Mode Camera Overlay**
- **Placement**: Full-screen camera preview
- **Overlay**: Darkened edges with central clear rectangle for code alignment
- **Placeholder**: `[BACKGROUND_IMAGE: not applicable — live camera feed, but UI overlay includes darkened vignette with central transparent scan window]`

### Background Image Rules
- All photographs must be high-resolution (minimum 2× for retina).
- Always apply gradient overlays when text appears over images.
- Never place primary text directly on a busy/uniform mid-tone area of an image without an overlay.
- Use `object-fit: cover` and `object-position: center` as defaults.
- For slow networks, show a `#E5E5EA` placeholder with skeleton shimmer until loaded.
- Medical context requires **clean, professional, non-graphic** imagery — no clinical procedure photos, only equipment, workspaces, and abstract textures.

---

## 7. Icons & Illustrations

### Icon Style
- **Style**: Outlined (stroke-based) icons with rounded caps and joins.
- **Stroke Width**: 1.5px–2px depending on size.
- **Corner Radius**: 1.5px–2px on line joins.
- **Design Language**: Minimal, geometric, consistent 2px gap between parallel lines.
- **Source**: SF Symbols (Apple) or Phosphor Icons (Regular weight) for cross-platform consistency. Medical-specific icons (tooth, autoclave, cross, barcode) should be custom or sourced from a medical icon set with matching stroke weight.

### Icon Size System
See Section 5 (Icon Sizing Scale).

### Icon Colors
- **Default**: `#000000` on light backgrounds
- **Inverse**: `#FFFFFF` on dark backgrounds, camera overlays, or scan mode
- **Inactive**: `#8E8E93` or `rgba(255,255,255,0.5)`
- **Accent**: `#007AFF` for interactive/action icons (edit, assign, link)
- **Semantic**: `#34C759` (success), `#FF9500` (warning), `#FF3B30` (error) for status indicators

### Filled vs. Outlined Icons
- **Outlined**: Default state for all navigation, UI actions, list icons, and scan mode controls.
- **Filled**: Active/selected state in bottom navigation, selected checkboxes, toggled favorites/bookmarks, and when emphasis is needed (e.g., "starred" alert).
- **Rule**: Never mix filled and outlined icons in the same row or group. Choose one style per context.

### Medical / Dental Iconography Set
| Icon | Context | Style |
|------|---------|-------|
| Tooth | App logo, product family, dental context | Outlined / Custom |
| Barcode / QR | Scan mode, label printing, lot tracking | Outlined |
| Box / Package | Stock, inventory, reception | Outlined |
| Autoclave / Sterilizer | Sterilization cycles, devices | Outlined |
| Check Shield | Validated cycle, compliance | Outlined / Filled active |
| Alert Triangle | Warnings, failed cycles, expired DLC | Outlined |
| Calendar | DLC, DDM, cycle dates | Outlined |
| User / Stethoscope | Operator, practitioner, profile | Outlined |
| Trending Up | Dashboard stats, stock trends | Outlined |
| File Text | Audit trail, reports, attachments | Outlined |
| Camera | Photo justification, document scan | Outlined |
| Arrow Left-Right | Stock movements, transfers | Outlined |
| Printer | Label printing | Outlined |
| Trash | Delete (destructive) | Outlined |
| Plus | Add product, add cycle, add user | Outlined |

### Illustration Style
- **Style**: Flat, minimal vector illustrations with subtle gradients.
- **Color Palette**: Monochrome using brand grays, or limited accent color (`#007AFF`) for highlights.
- **Line Weight**: 2px strokes, rounded caps.
- **Usage**: Onboarding tutorials (how to scan a label), empty states, success confirmations (cycle validated).
- **Characters**: Faceless, abstract human forms in medical scrubs if needed; focus on equipment, instruments, and clean environments.

### Empty-State Illustration Style
- Simple, friendly, not overly playful — medical professionalism is key.
- Monochrome or near-monochrome (`#E5E5EA` to `#8E8E93` range).
- Size: 120px–160px.
- No complex backgrounds; isolated subject on transparent/white background.

---

## 8. Navigation

### Splash Screen
- **Background**: `#000000`
- **Content**: Centered app logo (tooth + track icon) and wordmark "DentisTrack" in `#FFFFFF`
- **Animation**: Fade in 0.5s, hold 1.5s, fade out 0.3s
- **Bottom**: Optional loading indicator (white spinner) or tagline "Sterilization & Stock Tracking" in `#8E8E93`
- **Placeholder**: `[BACKGROUND_IMAGE: pure black or subtle dark textured background with faint medical cross pattern for splash screen]`

### Onboarding
- **Structure**: 3–4 swipeable full-screen pages
- **Background**: `[BACKGROUND_IMAGE: cinematic full-bleed photograph of modern dental equipment and clean workspace]` per page
- **Overlay**: Bottom-heavy dark gradient
- **Content**: Bottom-aligned, 24px padding
  - Title: Hero Title (36px / 700), `#FFFFFF` — e.g., "Trace every instrument", "Never miss a DLC", "Validate every cycle"
  - Description: Body Large (17px / 400), `rgba(255,255,255,0.85)` — e.g., "Scan, track, and audit your dental stock with complete traceability."
  - Pagination Dots: 8px circles, `#FFFFFF` (active), `rgba(255,255,255,0.4)` (inactive)
- **Final Screen**: Primary Button "Get Started" + Ghost Button "I already have an account"
- **Skip**: Top-right corner, Ghost Button "Skip"

### Authentication Screens

**Login / Sign Up**
- **Layout**: Full-bleed background image with bottom sheet form
- **Form Sheet**: White, 24px top radius, padding 24px
- **Title**: H1 (28px / 700), `#000000` — "Welcome back" / "Join your cabinet"
- **Fields**: Email, Password (with visibility toggle icon), Cabinet ID (for multi-tenant login)
- **Primary Action**: "Continue" — Primary Button, full width
- **Secondary Actions**: "Forgot Password?" — Ghost Button; "No account? Contact admin" — text link `#007AFF`
- **Biometric**: Face ID / Touch ID prompt after first successful login (icon button below primary)

**Role Selection** (if applicable)
- **Layout**: White background, centered content
- **Title**: H1, "Select your role"
- **Options**: Large touch cards (72px height) with icon + label — Administrator, Stock Manager, Practitioner
- **Selection**: Selected card gets `#000000` border, 2px

### Main Application Navigation

**Bottom Navigation (Primary)**
- Floating pill style or full-width bar.
- Items:
  1. **Home** (house icon) — Dashboard with alerts, stats, quick actions
  2. **Scan** (barcode icon) — Camera scan mode for labels and codes
  3. **Stock** (box icon) — Products, lots, movements, inventory
  4. **Cycles** (autoclave/sterilizer icon) — Sterilization tracking and validation
  5. **Profile** (user icon) — Account, settings, audit access, cabinet management
- Icons: Outlined default, filled active.
- Active indicator: Filled icon + optional white dot below.

**Top Navigation**
- Transparent over camera/dashboard hero, white/blur over content lists.
- Left: Back chevron or hamburger menu.
- Center: Screen title — e.g., "Lot #48291", "New Sterilization Cycle", "Stock Overview".
- Right: Contextual actions (share audit, filter list, add product, print label).

### Back Navigation
- **Icon**: Chevron left, 24px, `#000000` (or `#FFFFFF` on dark/camera).
- **Touch Target**: 44px × 44px.
- **Gesture**: iOS swipe-from-left-edge to go back.
- **Label**: Never show "Back" text; icon only.
- **Context**: From Lot Detail → Stock List; from Cycle Detail → Cycle List; from Audit Entry → Audit List.

### Modal Navigation
- **Entry**: Slide up from bottom (bottom sheets for filters/selects) or fade in (center modals for confirmations).
- **Exit**: Swipe down to dismiss (bottom sheets) or tap backdrop (center modals).
- **Stacking**: Modals can stack 2 deep maximum. Show previous modal dimmed behind.
- **Usage**: Confirming a sterilization cycle result, selecting an operator from a list, filtering lots by DLC range.

### Deep Navigation

**Product Flow**
`Stock Tab → Product List → Product Detail → Lot List → Lot Detail → Lot History / Audit`

**Sterilization Flow**
`Cycles Tab → Cycle List → Cycle Detail → Validate Cycle → Attach Report → Confirmation`
OR
`Cycles Tab → New Cycle → Select Device → Select Program → Add Instruments → Run Cycle → Enter Results → Validate`

**Scan Flow**
`Scan Tab → Camera Preview → Scan Code → Scan Result Bottom Sheet → Action (Use Lot / View History / Record Movement) → Confirmation`

**Audit / Compliance Flow**
`Profile → Audit Trail → Filter by Date/User/Action → Entry Detail → Export`

**Order / Reception Flow**
`Stock Tab → Orders → Order Detail → Receive Order → Enter Lots & DLC → Confirm Reception → Print Labels`

---

## 9. Screen Structure

### Reusable Screen Template

```
┌─────────────────────────────┐
│  Status Bar (system)        │  44–59px (safe area top)
├─────────────────────────────┤
│  Top Navigation / Header    │  56px
│  (Title + Actions)          │
├─────────────────────────────┤
│                             │
│                             │
│      Scrollable Content     │  Full height minus
│      (24px horizontal       │  header + bottom nav
│       padding default)      │
│                             │
│                             │
├─────────────────────────────┤
│  Bottom Action Area         │  80px + safe area
│  (Optional CTA button)      │
├─────────────────────────────┤
│  Bottom Navigation          │  64px + safe area bottom
│  (If applicable)            │
└─────────────────────────────┘
```

### Safe Areas
- **Top**: Respect status bar + notch (minimum 44px padding).
- **Bottom**: Respect home indicator (minimum 34px padding).
- **Horizontal**: 24px on standard phones; 16px on devices <375px width.

### Header Placement
- **Fixed**: Top navigation remains fixed while content scrolls beneath.
- **Blur on Scroll**: When content scrolls under header, apply `backdrop-filter: blur(20px)` and `background: rgba(255,255,255,0.85)`.
- **Border**: 0.5px bottom border `#E5E5EA` appears after scrolling 16px.
- **Contextual Title**: Header title updates dynamically when drilling into lot/cycle detail.

### Content Width
- **Max Content Width**: 100% minus 48px (24px each side).
- **Readable Width**: Text blocks should not exceed 100% of content area.
- **Cards**: Full width of content area or side-scroll carousel with 24px left padding and 16px card gap.
- **Tables**: Full width with horizontal scroll if needed (avoid on mobile; use cards instead).

### Scroll Behavior
- **Bounce**: Enable rubber-band bounce on iOS; edge glow on Android.
- **Scroll Indicator**: Default system scroll indicator.
- **Pull to Refresh**: Standard iOS spinner, accent color `#007AFF`. Refreshes stock list, cycle list, alert list.
- **Infinite Scroll**: Show skeleton loader at bottom while loading next page of audit trail or product list.

### Fixed Elements
- Top navigation (optional, can hide on scroll down in immersive screens like scan mode).
- Bottom navigation (always fixed except in scan camera mode and onboarding).
- Floating Action Button (fixed above bottom nav for quick scan or add action).
- Sticky section headers (e.g., "Today", "Yesterday" in audit trail; "Pending", "Validated" in cycle lists).

### Bottom Actions
- **Single CTA**: Full-width Primary Button, 24px horizontal padding, 16px above bottom safe area.
  - Examples: "Validate Cycle", "Confirm Reception", "Print Label", "Save Movement"
- **Dual Actions**: Primary left, Ghost right; OR Primary full-width + text link above.
  - Examples: "Save" + "Cancel"; "Confirm" + "Edit"
- **Sheet Actions**: Fixed to bottom of bottom sheet, white background, top border `#E5E5EA`.
  - Examples: "Apply Filters", "Select Operator", "Export Selected"

### Floating Elements
- **FAB**: 56px circle, 24px from right, 24px above bottom nav. Icon: scan or plus.
- **Toast**: 16px from top, 16px horizontal margin, centered. Announces save, validation, or error.
- **Badges**: Top-right of notification icon, offset -4px, -4px. Shows unread alert count.
- **Quick Action Pill**: Floating glassmorphism pill on dashboard for "Start Cycle" or "Scan Now".

### Keyboard Behavior
- **Push Content**: Screen content slides up when keyboard appears.
- **Done Button**: Show "Done" toolbar above keyboard for numeric inputs (quantities, temperatures).
- **Return Key**: Changes to "Next", "Search", or "Go" contextually.
- **Focus**: First field focused automatically on auth screens and new cycle forms.

### Loading Behavior
- **Initial Load**: Full-screen skeleton matching content structure (dashboard stats, product cards, cycle rows).
- **Pagination Load**: Skeleton rows at bottom of list.
- **Pull to Refresh**: Spinner at top, content remains visible.
- **Image Loading**: `#E5E5EA` placeholder → fade in product image over 0.3s when loaded.
- **Scan Delay**: Show scanning animation for 0.5s–1s before result to give user feedback.

---

## 10. Design Rules

### What Must Always Be Consistent
1. **Border Radius**: Use only the defined scale (8, 12, 16, 20, 24, full). Never use arbitrary values.
2. **Spacing**: Use only the spacing scale (4, 8, 12, 16, 20, 24, 32, 48, 64). Never eyeball margins.
3. **Typography**: Use only the defined type styles. Never introduce new font sizes or weights.
4. **Colors**: Use only design tokens. Never use raw hex codes not in the system.
5. **Iconography**: Use only the defined icon set and sizes. Never mix icon styles.
6. **Shadows**: Use only defined shadow values. Avoid custom drop shadows.
7. **Button Heights**: Primary 54px, Secondary 48px, Icon 44px minimum.
8. **Audit Trail Format**: Every sensitive action must show: actor, timestamp, action type, old value → new value. Always use the same row structure.

### What Can Change Per Screen
1. **Background**: White, light gray, or full-bleed image depending on screen purpose.
2. **Navigation Visibility**: Bottom nav hidden in scan camera mode, onboarding, and dedicated wizards.
3. **Header Style**: Transparent over camera/dashboard hero, solid/blur over content lists.
4. **Card Density**: 16px gaps standard; can reduce to 12px for dense audit lists or inventory tables.
5. **Content Layout**: Single column default; two-column for dashboard stats; horizontal scroll for product families.

### How to Use Colors
- **60-30-10 Rule**: 60% neutral background, 30% white surfaces, 10% black for emphasis.
- **One Accent**: Use `#007AFF` sparingly — only for active states, links, scan reticle, and key actions.
- **Semantic Colors**: Reserve green, orange, and red exclusively for sterilization status, stock alerts, and DLC warnings. Never use them for branding or decoration.
- **Dark Text on Light**: Default. Light text on dark only for camera overlays, dark mode elements, or image overlays.

### How to Use Images
- **Hero First**: Lead dashboard with large imagery when possible; it creates emotional connection to the workspace.
- **Consistent Aspect Ratios**: All product cards share identical aspect ratios. All lot photos share identical aspect ratios.
- **Text Safety**: Always ensure text over images has a gradient overlay or solid scrim.
- **Quality Gate**: Never display pixelated or low-resolution images. Use placeholders instead.
- **Medical Appropriateness**: No graphic clinical imagery. Use equipment, workspaces, and abstract textures only.

### How to Use Spacing
- **Proximity**: Related elements are closer together (8px–12px). Unrelated sections are farther apart (32px–48px).
- **Breathing Room**: When in doubt, add more space. This design system favors generosity over density — critical for medical clarity.
- **Alignment**: Left-align text and UI elements. Center only auth screens, empty states, modals, and scan confirmations.

### Avoiding Visual Clutter
- **Maximum 1 CTA**: One primary action per screen. Secondary actions must be visually subordinate.
- **Limit Borders**: Use whitespace to separate, not lines. Borders are a last resort.
- **No Heavy Shadows**: Shadows should be subtle (`rgba(0,0,0,0.08)` range). Never use black shadows at high opacity.
- **No Decorative Elements**: No gradients on buttons, no patterns, no decorative shapes. Content (lots, cycles, alerts) is the decoration.
- **Alert Discipline**: Show only actionable alerts. Hide resolved/cleared alerts from main views unless user navigates to history.

### Accessibility & Readability
- **Contrast**: All text must meet WCAG AA (4.5:1 for normal text, 3:1 for large text).
- **Dynamic Type**: Support iOS Dynamic Type scaling up to 200%.
- **Reduce Motion**: Respect system preference; disable parallax and heavy animations.
- **Focus States**: All interactive elements must have visible focus states for accessibility navigation.
- **Color Blind Safety**: Never rely on color alone for status. Always pair semantic colors with icons and text labels (e.g., red badge + "Expired" text + alert icon).

---

## 11. Responsive & Accessibility Rules

### Screen Size Adaptations

| Size | Device Example | Adjustments |
|------|---------------|-------------|
| **Small** | iPhone SE, <375px | Horizontal padding 16px, card radius 16px, reduce hero title to 28px, bottom nav full-width (no floating), compact list rows (52px) |
| **Standard** | iPhone 14, 375–430px | Default system values as defined |
| **Large** | iPhone 16 Pro Max, >430px | Horizontal padding 28px, max content width 430px centered, larger touch targets (48px min), two-column dashboard stats |

### Light / Dark Backgrounds
- **Default Theme**: Light mode (white/light gray backgrounds, black text).
- **Dark Elements**: Bottom navigation, camera overlay, splash screen, and select modals use dark backgrounds.
- **Dark Mode Support** (Future):
  - Background: `#000000`
  - Surface: `#1C1C1E`
  - Text: `#FFFFFF`
  - Secondary Text: `#8E8E93`
  - Borders: `#38383A`

### Minimum Touch Targets
- **Absolute Minimum**: 44px × 44px
- **Recommended**: 48px × 48px
- **Button Minimum Height**: 44px (48px preferred)
- **Spacing**: Minimum 8px between adjacent touch targets

### Text Readability
- **Minimum Body Size**: 13px
- **Preferred Body Size**: 15–17px
- **Line Height**: Minimum 1.4× font size
- **Paragraph Width**: 25–40 characters per line optimal for mobile
- **Text Over Images**: Always use gradient overlay + text shadow; never rely on image contrast alone
- **Monospace for Codes**: Lot numbers, DataMatrix content, and audit IDs must use tabular numerals to prevent misreading.

### Contrast Considerations
- **Normal Text** (<18px): Minimum 4.5:1 contrast ratio
- **Large Text** (≥18px bold or ≥24px regular): Minimum 3:1 contrast ratio
- **UI Components**: Borders, icons, and form elements minimum 3:1 against adjacent colors
- **Disabled States**: Not required to meet contrast ratios, but should still be discernible (avoid 10% opacity)

---

## 12. Developer-Ready Design Tokens

### Colors
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

### Typography
```json
{
  "typography": {
    "family": "-apple-system, BlinkMacSystemFont, SF Pro Display, SF Pro Text, Inter, sans-serif",
    "heroTitle": { "size": "36px", "weight": "700", "lineHeight": "42px", "letterSpacing": "-0.5px" },
    "h1": { "size": "28px", "weight": "700", "lineHeight": "34px", "letterSpacing": "-0.4px" },
    "h2": { "size": "22px", "weight": "700", "lineHeight": "28px", "letterSpacing": "-0.3px" },
    "h3": { "size": "18px", "weight": "600", "lineHeight": "24px", "letterSpacing": "-0.2px" },
    "h4": { "size": "16px", "weight": "600", "lineHeight": "22px", "letterSpacing": "-0.1px" },
    "bodyLarge": { "size": "17px", "weight": "400", "lineHeight": "24px", "letterSpacing": "-0.2px" },
    "body": { "size": "15px", "weight": "400", "lineHeight": "22px", "letterSpacing": "-0.1px" },
    "bodySmall": { "size": "13px", "weight": "400", "lineHeight": "18px", "letterSpacing": "0px" },
    "caption": { "size": "12px", "weight": "400", "lineHeight": "16px", "letterSpacing": "0.1px" },
    "buttonLarge": { "size": "17px", "weight": "600", "lineHeight": "22px", "letterSpacing": "-0.2px" },
    "button": { "size": "15px", "weight": "600", "lineHeight": "20px", "letterSpacing": "-0.1px" },
    "navLabel": { "size": "11px", "weight": "500", "lineHeight": "14px", "letterSpacing": "0.2px" },
    "dataLarge": { "size": "20px", "weight": "700", "lineHeight": "26px", "letterSpacing": "-0.3px" },
    "data": { "size": "16px", "weight": "600", "lineHeight": "22px", "letterSpacing": "-0.1px" }
  }
}
```

### Spacing
```json
{
  "spacing": {
    "4": "4px",
    "8": "8px",
    "12": "12px",
    "16": "16px",
    "20": "20px",
    "24": "24px",
    "32": "32px",
    "48": "48px",
    "64": "64px"
  }
}
```

### Border Radius
```json
{
  "borderRadius": {
    "sm": "8px",
    "md": "12px",
    "lg": "16px",
    "xl": "20px",
    "2xl": "24px",
    "full": "9999px"
  }
}
```

### Shadows
```json
{
  "shadow": {
    "sm": "0px 2px 8px rgba(0, 0, 0, 0.06)",
    "md": "0px 4px 12px rgba(0, 0, 0, 0.08)",
    "lg": "0px 4px 20px rgba(0, 0, 0, 0.08)",
    "xl": "0px 8px 24px rgba(0, 0, 0, 0.12)",
    "fab": "0px 8px 24px rgba(0, 0, 0, 0.25)",
    "modal": "0px 20px 40px rgba(0, 0, 0, 0.3)"
  }
}
```

### Component Sizes
```json
{
  "size": {
    "buttonPrimary": { "height": "54px", "radius": "27px", "padding": "0px 24px" },
    "buttonSecondary": { "height": "48px", "radius": "24px", "padding": "0px 20px" },
    "buttonIcon": { "size": "44px", "radius": "14px" },
    "fab": { "size": "56px", "radius": "28px" },
    "input": { "height": "52px", "radius": "14px", "padding": "0px 16px" },
    "inputTextArea": { "minHeight": "100px", "radius": "14px", "padding": "16px" },
    "searchBar": { "height": "44px", "radius": "22px", "padding": "0px 16px" },
    "card": { "radius": "20px", "padding": "16px" },
    "cardCompact": { "radius": "16px", "padding": "16px" },
    "chip": { "height": "36px", "radius": "18px", "padding": "0px 16px" },
    "badge": { "height": "20px", "radius": "10px", "padding": "0px 8px" },
    "avatar": { "sm": "32px", "md": "44px", "lg": "64px", "xl": "96px" },
    "icon": { "xs": "16px", "sm": "20px", "md": "24px", "lg": "32px", "xl": "48px" },
    "touchTarget": { "min": "44px", "preferred": "48px" },
    "bottomNav": { "height": "64px", "radius": "32px" },
    "listRow": { "height": "56px" }
  }
}
```

### Animation Durations
```json
{
  "animation": {
    "instant": "0ms",
    "fast": "150ms",
    "normal": "250ms",
    "slow": "400ms",
    "easing": {
      "default": "cubic-bezier(0.4, 0.0, 0.2, 1)",
      "enter": "cubic-bezier(0.0, 0.0, 0.2, 1)",
      "exit": "cubic-bezier(0.4, 0.0, 1, 1)",
      "bounce": "cubic-bezier(0.34, 1.56, 0.64, 1)"
    }
  }
}
```

---

## Summary

This design system captures the **confident, editorial, and minimal** aesthetic of the reference image while providing a complete, production-ready specification tailored to a **SaaS HealthTech dental platform**. The system is built on:

- **A restrained monochrome palette** with a single blue accent, conveying clinical precision
- **Generous spacing and large touch targets** for premium mobile feel — essential for busy dental professionals wearing gloves
- **Pill-shaped buttons and rounded cards** for a friendly yet authoritative UI
- **Semantic color coding** for instant recognition of sterilization status, stock levels, and DLC proximity
- **Immersive photography with gradient overlays** for emotional connection to the professional workspace
- **Clear hierarchy through bold typography** and careful scale, ensuring batch numbers and medical codes are instantly scannable
- **Consistent tokens** that translate directly to Flutter, React/Next.js, and Laravel/NestJS codebases

All background visuals are defined as `[BACKGROUND_IMAGE: ...]` placeholders for your image generation pipeline. The system is ready for handoff to the development binôme and supports the full MVP scope: stock management, lot traceability, sterilization cycle validation, label scanning, and audit compliance.
