# 🏥 STERIQORE — ADMINISTRATEUR DESIGN SYSTEM
## Clinical Authority Style Guide · Version 1.0

---

## 1. VISUAL IDENTITY

### Aesthetic Direction: "Clinical Authority"
A premium, data-dense administrative interface that conveys institutional trust and medical precision. The visual language is inspired by Bloomberg Terminal medical dashboards and Swiss editorial design — every pixel serves a function. No decoration. No playfulness. Pure operational clarity.

### Color Palette

| Token | HEX | RGBA | Usage |
|-------|-----|------|-------|
| **Primary** | `#0A1628` | `rgb(10, 22, 40)` | Top navigation, primary buttons, active states, headings, key data emphasis |
| **Primary Inverse** | `#FFFFFF` | `rgb(255, 255, 255)` | Text on dark backgrounds, button text on primary buttons |
| **Accent** | `#0D9488` | `rgb(13, 148, 136)` | Active links, selected states, interactive tints, toggle switches, scan reticle, status indicators |
| **Accent Light** | `#14B8A6` | `rgb(20, 184, 166)` | Hover states, focus rings, secondary highlights |
| **Accent Subtle** | `#CCFBF1` | `rgb(204, 251, 241)` | Badge backgrounds, alert tint backgrounds, chip selected bg |
| **Secondary** | `#334155` | `rgb(51, 65, 85)` | Secondary text, section headings, card titles, table headers |
| **Background Default** | `#F8FAFC` | `rgb(248, 250, 252)` | Main app background, web admin canvas |
| **Background Elevated** | `#FFFFFF` | `rgb(255, 255, 255)` | Cards, modals, input fields, dropdowns, tables |
| **Background Dark** | `#0F172A` | `rgb(15, 23, 42)` | Dark mode surfaces, bottom nav, splash screen |
| **Surface Muted** | `#F1F5F9` | `rgb(241, 245, 249)` | Table row hover, chip default bg, secondary card bg |
| **Text Primary** | `#0F172A` | `rgb(15, 23, 42)` | Main headings, screen titles, primary body text |
| **Text Secondary** | `#475569` | `rgb(71, 85, 105)` | Descriptions, metadata, placeholders, secondary labels |
| **Text Tertiary** | `#94A3B8` | `rgb(148, 163, 184)` | Disabled text, timestamps, captions, inactive nav |
| **Text Inverse** | `#FFFFFF` | `rgb(255, 255, 255)` | Text overlaid on dark backgrounds or images |
| **Border Subtle** | `#E2E8F0` | `rgb(226, 232, 240)` | Card dividers, table borders, input borders, separators |
| **Border Strong** | `#CBD5E1` | `rgb(203, 213, 225)` | Focused input borders, active filter borders, drag handles |
| **Success** | `#059669` | `rgb(5, 150, 105)` | Success toasts, online indicators, validated states, sync OK |
| **Warning** | `#D97706` | `rgb(217, 119, 6)` | Pending states, near-expiration alerts, moderate severity |
| **Error** | `#DC2626` | `rgb(220, 38, 38)` | Failed cycles, validation errors, critical alerts, deletion |
| **Info** | `#0D9488` | `rgb(13, 148, 136)` | Informational badges, tips, audit hints, help tooltips |

### Gradients
- **Hero Overlay**: `linear-gradient(180deg, rgba(10,22,40,0) 0%, rgba(10,22,40,0.75) 100%)` — Bottom-heavy fade for any image-based headers.
- **Status Bar**: `linear-gradient(90deg, rgba(13,148,136,0.08) 0%, rgba(13,148,136,0) 100%)` — Subtle left-edge tint for sticky admin headers.
- **Card Hover**: `linear-gradient(180deg, rgba(255,255,255,0) 0%, rgba(241,245,249,0.5) 100%)` — Micro-interaction on data cards.

### Opacity & Transparency
- **Disabled**: `opacity: 0.4` on entire component
- **Backdrop**: `rgba(15, 23, 42, 0.5)` behind modals and bottom sheets
- **Glassmorphism**: `backdrop-filter: blur(16px)` + `background: rgba(255,255,255,0.85)` for floating admin toolbars
- **Skeleton**: Base `#F1F5F9`, shimmer `rgba(255,255,255,0.6)`
- **Pressed**: `opacity: 0.85` or overlay `rgba(10,22,40,0.04)`
- **Archived**: `opacity: 0.55` on inactive user rows or historical audit entries

---

## 2. TYPOGRAPHY

### Font Family
**Primary**: `Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`
- Inter is chosen for its exceptional legibility at small sizes, tabular numerals, and neutral clinical tone.
- Use **Inter Display** (or Inter at tighter tracking) for headings.
- Use **Inter** standard for body and data.

### Type Scale

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Display** | 40px | 700 | 48px | -0.8px | Splash screen, major admin dashboards |
| **H1** | 30px | 700 | 38px | -0.6px | Screen titles, admin panel headers |
| **H2** | 24px | 600 | 32px | -0.4px | Card titles, section headers, modal titles |
| **H3** | 18px | 600 | 26px | -0.2px | Subsection headings, table section titles |
| **H4** | 15px | 600 | 22px | -0.1px | List item titles, form labels, column headers |
| **Body Large** | 16px | 400 | 24px | -0.1px | Primary body text, descriptions |
| **Body** | 14px | 400 | 22px | 0px | Standard content, audit entries, table cells |
| **Body Small** | 13px | 400 | 18px | 0px | Metadata, secondary details, footer text |
| **Caption** | 12px | 500 | 16px | 0.1px | Timestamps, badge labels, helper text, data labels |
| **Mono** | 13px | 500 | 18px | 0px | Lot numbers, cycle IDs, IP addresses, audit IDs |
| **Button Large** | 16px | 600 | 22px | -0.1px | Primary CTA buttons |
| **Button** | 14px | 600 | 20px | 0px | Standard buttons, table actions |
| **Nav Label** | 11px | 500 | 14px | 0.2px | Bottom / side navigation labels |
| **Data Large** | 28px | 700 | 36px | -0.6px | KPI values, dashboard stats, critical metrics |
| **Data** | 18px | 600 | 26px | -0.2px | Secondary metrics, stock counts |

### Typography Rules
- **Headings**: Negative letter-spacing for tighter, more authoritative feel.
- **Data values**: Always use `font-variant-numeric: tabular-nums` to prevent width jitter in tables and counters.
- **Monospace contexts**: Lot numbers, DataMatrix codes, timestamps, IP addresses, user IDs.
- **Body text minimum**: 13px on mobile, 14px on web admin.
- **Text over images**: Inverse white with text-shadow `0px 1px 3px rgba(0,0,0,0.3)`.

---

## 3. BUTTONS

### Primary Button
- **Height**: 48px (web) / 52px (mobile)
- **Border Radius**: 8px (NOT pill — admin interfaces use sharp, authoritative corners)
- **Padding**: 0px 20px
- **Background**: `#0A1628`
- **Text**: `#FFFFFF`, Button (14px / 600)
- **Icon**: 18px, left of text, 8px gap
- **Normal**: Solid navy, subtle shadow `0px 1px 3px rgba(10,22,40,0.15)`
- **Hover** (web): Background `#1E293B`, shadow `0px 2px 6px rgba(10,22,40,0.12)`
- **Pressed**: Scale `0.98`, background `#0F172A`
- **Disabled**: Background `#CBD5E1`, text `#94A3B8`, no shadow
- **Loading**: Spinner replaces text, spinner `#FFFFFF`

### Secondary Button
- **Height**: 40px
- **Border Radius**: 8px
- **Padding**: 0px 16px
- **Background**: `#F1F5F9`
- **Text**: `#334155`, Button (14px / 600)
- **Normal**: Light slate fill
- **Hover**: Background `#E2E8F0`
- **Disabled**: Background `#F8FAFC`, text `#CBD5E1`

### Outline Button
- **Height**: 40px
- **Border Radius**: 8px
- **Padding**: 0px 16px
- **Background**: Transparent
- **Border**: 1px solid `#CBD5E1`
- **Text**: `#334155`, Button (14px / 600)
- **Hover**: Background `#F8FAFC`, border `#94A3B8`
- **Disabled**: Border `#E2E8F0`, text `#CBD5E1`

### Ghost / Text Button
- **Height**: 36px
- **Border Radius**: 6px
- **Padding**: 0px 12px
- **Background**: Transparent
- **Text**: `#0D9488`, Button (14px / 600)
- **Hover**: Background `rgba(13,148,136,0.06)`
- **Disabled**: Text `#94A3B8`

### Destructive Button
- Same dimensions as Primary
- **Background**: `#DC2626`
- **Text**: `#FFFFFF`
- **Hover**: Background `#B91C1C`

### Icon Button (Table Actions)
- **Size**: 36px × 36px
- **Border Radius**: 6px
- **Background**: Transparent
- **Icon**: 18px, `#475569`
- **Hover**: Background `#F1F5F9`, icon `#0F172A`
- **Pressed**: Background `#E2E8F0`

### Floating Action Button (Mobile Only)
- **Size**: 56px × 56px
- **Border Radius**: 16px (NOT circle — squared authority)
- **Background**: `#0A1628`
- **Icon**: 24px, `#FFFFFF`
- **Shadow**: `0px 4px 16px rgba(10,22,40,0.25)`

---

## 4. COMPONENTS

### Cards (Admin Data Cards)
- **Background**: `#FFFFFF`
- **Border Radius**: 12px
- **Border**: 1px solid `#E2E8F0`
- **Shadow**: None (admin cards use borders, not shadows — cleaner data density)
- **Padding**: 20px
- **Hover** (web): Border color `#CBD5E1`, background `#FAFBFC`
- **Pressed**: Scale `0.995`

### KPI Stat Card
- Same as Admin Data Card
- **Top**: Caption label (12px, `#94A3B8`, uppercase, letter-spacing 0.5px)
- **Middle**: Data Large value (28px, `#0A1628`)
- **Bottom**: Trend indicator (Caption, green/red arrow + percentage)
- **Right accent**: 3px left border in accent color (optional)

### Tables (Primary Admin Component)
- **Header row**: Background `#F8FAFC`, text `#475569`, Caption (12px / 500 / uppercase)
- **Row height**: 52px
- **Row border**: 1px solid `#F1F5F9` (subtle separator)
- **Row hover**: Background `#F8FAFC`
- **Cell padding**: 16px horizontal
- **Selected row**: Background `#CCFBF1` (accent subtle), left border 3px `#0D9488`
- **Empty state**: Centered, Body Small gray, no cartoon illustration — use simple table icon (24px, `#CBD5E1`)
- **Pagination**: Outline buttons, 36px height, 8px radius

### Inputs
- **Height**: 44px (web) / 48px (mobile)
- **Background**: `#FFFFFF`
- **Border Radius**: 8px
- **Border**: 1px solid `#E2E8F0` (default), `#0D9488` (focused), `#DC2626` (error)
- **Padding**: 0px 14px
- **Font**: Body (14px / 400)
- **Placeholder**: `#94A3B8`
- **Focus ring**: `box-shadow: 0px 0px 0px 3px rgba(13,148,136,0.15)`

### Search Bar
- **Height**: 40px
- **Background**: `#F1F5F9`
- **Border Radius**: 8px
- **Border**: 1px solid transparent (default), `#CBD5E1` (focused)
- **Icon**: 18px search, `#94A3B8`
- **Font**: Body (14px)

### Dropdowns / Selects
- **Height**: 44px
- **Background**: `#FFFFFF`
- **Border Radius**: 8px
- **Border**: 1px solid `#E2E8F0`
- **Chevron**: 18px, `#94A3B8`
- **Menu**: White bg, 8px radius, border `#E2E8F0`, shadow `0px 4px 12px rgba(0,0,0,0.08)`
- **Selected item**: Background `#F0FDFA`, text `#0D9488`, font-weight 600

### Checkboxes
- **Size**: 18px × 18px
- **Border Radius**: 4px
- **Border**: 1.5px solid `#CBD5E1` (unchecked), `#0D9488` (checked)
- **Checked**: Background `#0D9488`, white checkmark (14px)
- **Indeterminate**: Background `#0D9488`, white horizontal line

### Radio Buttons
- **Size**: 18px × 18px
- **Border**: 1.5px solid `#CBD5E1` (unchecked), `#0D9488` (selected)
- **Selected**: Inner dot 8px, `#0D9488`

### Switches (Toggles)
- **Size**: 44px × 24px (web) / 48px × 28px (mobile)
- **Border Radius**: 12px / 14px
- **Off**: Background `#E2E8F0`, thumb `#FFFFFF`
- **On**: Background `#0D9488`, thumb `#FFFFFF`
- **Thumb shadow**: `0px 1px 3px rgba(0,0,0,0.15)`

### Tabs (Segmented)
- **Height**: 36px
- **Background**: `#F1F5F9`
- **Border Radius**: 8px
- **Padding**: 4px
- **Active**: Background `#FFFFFF`, shadow `0px 1px 3px rgba(0,0,0,0.08)`, text `#0A1628`, font-weight 600
- **Inactive**: Background transparent, text `#64748B`

### Badges
- **Height**: 20px
- **Padding**: 0px 10px
- **Border Radius**: 4px (sharp — admin badges are rectangular, not pills)
- **Font**: Caption (12px / 500)
- **Variants**:
  - Primary: `#0A1628` bg, `#FFFFFF` text
  - Success: `#ECFDF5` bg, `#059669` text
  - Warning: `#FFFBEB` bg, `#D97706` text
  - Error: `#FEF2F2` bg, `#DC2626` text
  - Info: `#F0FDFA` bg, `#0D9488` text
  - Outline: `#FFFFFF` bg, `#475569` border, `#475569` text

### Chips / Tags
- **Height**: 32px
- **Padding**: 0px 12px
- **Border Radius**: 6px
- **Font**: Body Small (13px / 500)
- **Default**: Background `#F1F5F9`, text `#475569`, border 1px `#E2E8F0`
- **Selected**: Background `#0A1628`, text `#FFFFFF`
- **Filter active**: Background `#F0FDFA`, text `#0D9488`, border 1px `#99F6E4`

### Avatars
- **Sizes**: XS 24px, SM 32px, MD 40px, LG 48px
- **Border Radius**: 50% (circular for users)
- **Placeholder**: Background `#E2E8F0`, initials `#64748B`, font Inter 500
- **Status dot**: 10px, bottom-right, border 2px `#FFFFFF`
  - Online: `#059669`
  - Away: `#D97706`
  - Offline: `#94A3B8`

### Modals / Dialogs
- **Background**: `#FFFFFF`
- **Border Radius**: 12px
- **Padding**: 24px
- **Max Width**: 480px (standard), 640px (wide forms)
- **Shadow**: `0px 8px 32px rgba(10,22,40,0.15)`
- **Backdrop**: `rgba(15,23,42,0.5)`
- **Header**: H3 (18px / 600), bottom border 1px `#E2E8F0`, padding-bottom 16px
- **Footer**: Top border 1px `#E2E8F0`, padding-top 16px, right-aligned actions

### Bottom Sheets (Mobile)
- **Background**: `#FFFFFF`
- **Border Radius**: 16px top-left, 16px top-right
- **Handle**: 40px × 4px, `#E2E8F0`, centered
- **Padding**: 24px horizontal, 20px top
- **Backdrop**: `rgba(15,23,42,0.5)`

### Toasts / Alerts
- **Border Radius**: 8px
- **Padding**: 14px 18px
- **Position**: Top-right (web), top (mobile)
- **Shadow**: `0px 4px 16px rgba(0,0,0,0.1)`
- **Success**: Left border 3px `#059669`, bg `#ECFDF5`, icon check-circle (18px, `#059669`)
- **Error**: Left border 3px `#DC2626`, bg `#FEF2F2`, icon alert-circle (18px, `#DC2626`)
- **Warning**: Left border 3px `#D97706`, bg `#FFFBEB`, icon alert-triangle (18px, `#D97706`)
- **Info**: Left border 3px `#0D9488`, bg `#F0FDFA`, icon info (18px, `#0D9488`)

### Progress Indicators
- **Linear**: Height 4px, bg `#E2E8F0`, fill `#0D9488`, radius 2px
- **Circular**: 20px, stroke 2.5px, color `#0D9488`
- **Skeleton**: Base `#F1F5F9`, shimmer `rgba(255,255,255,0.5)`, radius 6px

---

## 5. LAYOUT & SPACING

### Screen Margins
- **Web admin**: 32px horizontal padding, 24px vertical
- **Mobile**: 20px horizontal, respect safe areas

### Spacing Scale
| Token | Value | Usage |
|-------|-------|-------|
| `space-2` | 2px | Tight icon gaps |
| `space-4` | 4px | Inline spacing |
| `space-8` | 8px | Tight component padding |
| `space-12` | 12px | Small gaps |
| `space-16` | 16px | Standard padding, card gaps |
| `space-20` | 20px | Card internal padding |
| `space-24` | 24px | Section breaks, modal padding |
| `space-32` | 32px | Major section spacing |
| `space-48` | 48px | Page section dividers |

### Border Radius Scale
| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 6px | Small buttons, tags, badges |
| `radius-md` | 8px | Buttons, inputs, chips, toasts |
| `radius-lg` | 12px | Cards, modals, tables |
| `radius-xl` | 16px | Bottom sheets, large containers |

### Touch Targets
- **Minimum**: 44px × 44px
- **Table row height**: 52px minimum
- **Button height**: 40px (secondary), 48px (primary)
- **Icon button**: 36px × 36px

---

## 6. ICONOGRAPHY — PROFESSIONAL ONLY

### CRITICAL RULE: NO CHILDISH OR AI-GENERATED ICONS

**Forbidden:**
- ❌ Cartoon characters, mascots, or illustrated figures
- ❌ Playful 3D icons, bubbly shapes, or emoji-style graphics
- ❌ Gradient-filled decorative icons
- ❌ Hand-drawn or sketch-style icons
- ❌ Overly colorful or multi-color icon illustrations

**Required:**
- ✅ Geometric line icons (1.5px–2px stroke)
- ✅ Consistent 24px default size, 18px for dense tables
- ✅ Monochrome: `#475569` default, `#0A1628` active, `#0D9488` accent
- ✅ Rounded caps and joins (1.5px radius)
- ✅ Source: Phosphor Icons (Regular weight), Lucide, or Tabler Icons

### Admin Icon Set

| Icon | Context | Style |
|------|---------|-------|
| `Users` / `UserPlus` / `UserMinus` | User management | Line, 1.5px |
| `ShieldCheck` / `ShieldAlert` | Permissions, security | Line, 1.5px |
| `Lock` / `Key` | Authentication, secrets | Line, 1.5px |
| `Activity` / `BarChart3` | Dashboard stats, KPIs | Line, 1.5px |
| `FileText` / `ClipboardList` | Audit trail, reports | Line, 1.5px |
| `Search` / `Filter` / `SlidersHorizontal` | Table filtering | Line, 1.5px |
| `Pencil` / `Trash2` / `Eye` | CRUD actions | Line, 1.5px |
| `CheckCircle2` / `XCircle` / `AlertCircle` | Status indicators | Line, 1.5px |
| `ChevronRight` / `ChevronDown` | Navigation, expand | Line, 1.5px |
| `MoreHorizontal` / `MoreVertical` | Context menus | Line, 1.5px |
| `Download` / `Upload` | Export/import | Line, 1.5px |
| `Settings` / `Cog` | Configuration | Line, 1.5px |
| `LogOut` | Sign out | Line, 1.5px |
| `Building2` | Organization/cabinet | Line, 1.5px |
| `Bell` / `BellDot` | Notifications, alerts | Line, 1.5px |
| `Calendar` / `Clock` | Date/time filters | Line, 1.5px |
| `Mail` | Email, invitations | Line, 1.5px |
| `Phone` | Contact | Line, 1.5px |
| `MapPin` | Location, site | Line, 1.5px |
| `Globe` | Tenant, multi-site | Line, 1.5px |

### Empty State Icons
- Use **simple geometric line icons only** (NO illustrations)
- Size: 48px for page-level empty states, 32px for table-level
- Color: `#CBD5E1` (muted, non-distracting)
- Examples:
  - No users: `Users` icon (48px, `#CBD5E1`) + "No users found" text
  - No audit: `FileText` icon (48px, `#CBD5E1`) + "No audit entries"
  - No results: `SearchX` icon (48px, `#CBD5E1`) + "No matching results"

---

## 7. ADMIN-SPECIFIC SCREEN PATTERNS

### User Management Table
```
┌──────────────────────────────────────────────────────────────────────────────┐
│ Users                                                    [+ Add User]        │
├──────────────────────────────────────────────────────────────────────────────┤
│ [Search...]  [Role: All ▼]  [Status: All ▼]  [Filter]                       │
├──────────────────────────────────────────────────────────────────────────────┤
│ NAME          │ ROLE        │ STATUS   │ LAST LOGIN      │ ACTIONS          │
├───────────────┼─────────────┼──────────┼─────────────────┼──────────────────┤
│ 👤 Dr. John   │ Admin       │ ● Active │ 2 min ago       │ 👁️ ✏️ 🗑️        │
│ 👤 pedro      │ Assistant   │ ● Active │ 1 hour ago      │ 👁️ ✏️ 🗑️        │
│ 👤 prac1      │ Practitioner│ ○ Inact. │ 3 days ago      │ 👁️ ✏️ 🗑️        │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Audit Trail
```
┌──────────────────────────────────────────────────────────────────────────────┐
│ Audit Trail                                              [Export CSV]        │
├──────────────────────────────────────────────────────────────────────────────┤
│ [Today] [This Week] [This Month] [Custom Range]                              │
├──────────────────────────────────────────────────────────────────────────────┤
│ 14:32:05  👤 Dr. John    Scanned label LBL-2026-001234     ✅ Success        │
│ 14:28:12  👤 prac1       Recorded usage on PAT-001         ✅ Success        │
│ 14:15:00  👤 pedro       Created purchase order PO-0891    ✅ Success        │
│ 13:45:22  👤 Dr. John    Disabled user prac1               ⚠️ Warning        │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Create User Modal
```
┌────────────────────────────────────────┐
│ Create New User              [×]       │
├────────────────────────────────────────┤
│ Full Name *                            │
│ [________________________]             │
│                                        │
│ Email *                                │
│ [________________________]             │
│                                        │
│ Role *                                 │
│ [Administrator    ▼]                   │
│                                        │
│ [✓] Send invitation email              │
│                                        │
│          [Cancel]  [Create User]       │
└────────────────────────────────────────┘
```

---

## 8. BACKGROUND IMAGES (ADMIN)

### Admin Dashboard Hero
```
[BACKGROUND_IMAGE: abstract dark navy geometric mesh pattern with subtle teal accent nodes, data visualization aesthetic, no text, no people, clean vector style, 16:9 aspect ratio, suitable for admin dashboard header background]
```

### Login Background
```
[BACKGROUND_IMAGE: dark moody photograph of modern medical equipment in soft focus, deep navy and teal tones, blurred background suitable for login form overlay, no people, clinical atmosphere, 9:19.5 aspect ratio]
```

### Empty State Backgrounds
```
[BACKGROUND_IMAGE: NOT APPLICABLE — admin empty states use simple line icons on white background, no illustrations, no background images]
```

---

## 9. DEVELOPER DESIGN TOKENS

```json
{
  "color": {
    "primary": "#0A1628",
    "primaryInverse": "#FFFFFF",
    "accent": "#0D9488",
    "accentLight": "#14B8A6",
    "accentSubtle": "#CCFBF1",
    "secondary": "#334155",
    "background": { "default": "#F8FAFC", "elevated": "#FFFFFF", "dark": "#0F172A" },
    "surfaceMuted": "#F1F5F9",
    "text": { "primary": "#0F172A", "secondary": "#475569", "tertiary": "#94A3B8", "inverse": "#FFFFFF" },
    "border": { "subtle": "#E2E8F0", "strong": "#CBD5E1" },
    "semantic": { "success": "#059669", "warning": "#D97706", "error": "#DC2626", "info": "#0D9488" }
  },
  "typography": {
    "family": "Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif",
    "display": { "size": "40px", "weight": "700", "lineHeight": "48px", "letterSpacing": "-0.8px" },
    "h1": { "size": "30px", "weight": "700", "lineHeight": "38px", "letterSpacing": "-0.6px" },
    "h2": { "size": "24px", "weight": "600", "lineHeight": "32px", "letterSpacing": "-0.4px" },
    "h3": { "size": "18px", "weight": "600", "lineHeight": "26px", "letterSpacing": "-0.2px" },
    "h4": { "size": "15px", "weight": "600", "lineHeight": "22px", "letterSpacing": "-0.1px" },
    "body": { "size": "14px", "weight": "400", "lineHeight": "22px", "letterSpacing": "0px" },
    "bodySmall": { "size": "13px", "weight": "400", "lineHeight": "18px", "letterSpacing": "0px" },
    "caption": { "size": "12px", "weight": "500", "lineHeight": "16px", "letterSpacing": "0.1px" },
    "mono": { "size": "13px", "weight": "500", "lineHeight": "18px", "letterSpacing": "0px" },
    "button": { "size": "14px", "weight": "600", "lineHeight": "20px", "letterSpacing": "0px" },
    "dataLarge": { "size": "28px", "weight": "700", "lineHeight": "36px", "letterSpacing": "-0.6px" },
    "data": { "size": "18px", "weight": "600", "lineHeight": "26px", "letterSpacing": "-0.2px" }
  },
  "spacing": { "2": "2px", "4": "4px", "8": "8px", "12": "12px", "16": "16px", "20": "20px", "24": "24px", "32": "32px", "48": "48px" },
  "radius": { "sm": "6px", "md": "8px", "lg": "12px", "xl": "16px" },
  "shadow": {
    "sm": "0px 1px 3px rgba(10,22,40,0.08)",
    "md": "0px 4px 12px rgba(10,22,40,0.08)",
    "lg": "0px 8px 32px rgba(10,22,40,0.12)",
    "modal": "0px 8px 32px rgba(10,22,40,0.15)"
  }
}
```

---

## 10. CRITICAL RULES

1. **NO shadows on cards** — Admin cards use 1px borders (`#E2E8F0`), never drop shadows. Shadows are reserved for modals, toasts, and FABs only.
2. **NO pill-shaped buttons** — Admin buttons use 8px radius (rectangular). Pill shapes are for consumer apps, not medical admin panels.
3. **NO cartoon illustrations** — Empty states use simple 48px line icons (`#CBD5E1`) + text. Never use illustrated characters or playful graphics.
4. **Color is signal, not decoration** — Green = success/OK, Red = error/critical, Amber = warning/pending, Teal = info/active. Never use these colors for branding or decoration.
5. **Tabular numerals everywhere** — All numbers (counts, IDs, timestamps, percentages) must use `font-variant-numeric: tabular-nums` to prevent column jitter.
6. **Tables over cards for data density** — Admin views prioritize tables for lists (users, audit, orders). Cards are for KPIs and dashboards only.
7. **Progressive disclosure** — Show critical data first. Hide secondary details behind expand/chevron or detail modals.
8. **Role-based navigation** — Admin sees full sidebar nav. Other roles see reduced nav. Never show disabled/inaccessible nav items.
9. **All admin actions are audited** — Every create, edit, disable action shows a toast and is logged. Users must know their actions are recorded.
10. **Contrast first** — All text meets WCAG AA (4.5:1 minimum). Admin interfaces are read for hours; eye strain is a design failure.
