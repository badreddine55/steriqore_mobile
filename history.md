# STERIQORE Mobile — Development & RBAC Implementation History

## 📋 Executive Summary
This document provides a comprehensive summary of all architectural changes, security enhancements, Role-Based Access Control (RBAC) implementations, and live API integrations performed on the **STERIQORE Mobile** application.

---

## 🔐 1. Role-Based Access Control (RBAC) & Router Guards

### Core Rules & Constraints
- **Server as Single Source of Truth**: User roles and permissions are always validated server-side via `GET /api/v1/auth/me`. Local storage is never trusted as the authority.
- **Account Provisioning**: Registration on mobile is disabled (`Rule 7`). User accounts and clinical role assignments are provisioned exclusively by the Clinic Administrator.
- **Strict Route Gating**: Router guards (`app_router.dart`) protect every guarded route against direct deep linking and unauthorized navigation.

### Role Permission Matrix
| Page / Route | Route Path | Admin | Assistant | Practitioner | Guard Behavior |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Home Dashboard** | `/home` | ✅ | ✅ | ✅ | Dynamic role-aware dashboard |
| **Scanner & Labels** | `/scanner`, `/label/:code` | ✅ | ✅ | ✅ | `user.canAccessScanner` |
| **Usage Recording** | `/usage/patient-select`, `/usage/confirm`, `/usage/success` | ✅ | ✅ | ✅ | `user.canAccessUsage` |
| **Traceability History** | `/history` | ✅ | ✅ | ✅ | `user.canAccessHistory` |
| **Profile & Rights** | `/profile` | ✅ | ✅ | ✅ | `user.canAccessProfile` |
| **Stock & Inventory** | `/stock` | ✅ | ✅ | ❌ | `user.canAccessStock` (Practitioner &rarr; `/home`) |
| **Sterilization Cycles** | `/cycles` | ✅ | ✅ | ❌ | `user.canAccessCycles` (Practitioner &rarr; `/home`) |
| **User Management** | `/admin/users`, `/admin/users/create`, `/admin/users/:id` | ✅ | ❌ | ❌ | `user.canAccessAdmin` (Blocked &rarr; `/home`) |
| **Audit Trail** | `/admin/audit` | ✅ | ❌ | ❌ | `user.canAccessAdmin` (Blocked &rarr; `/home`) |
| **Safety Settings** | `/admin/settings` | ✅ | ❌ | ❌ | `user.canAccessAdmin` (Blocked &rarr; `/home`) |

---

## 🧭 2. Dynamic Role-Based Bottom Navigation (`RoleBasedBottomNav`)

The bottom navigation bar automatically adapts its tabs and routes depending on the authenticated user's role:

```
👨‍⚕️ Practitioner (4 Tabs):
[ ⊞ Home (/home) ]  [ ⚲ Scan (/scanner) ]  [ ◷ History (/history) ]  [ 👤 Profile (/profile) ]

👩‍💼 Assistant (4 Tabs):
[ ⊞ Dashboard (/home) ]  [ 📦 Stock (/stock) ]  [ ⚕ Cycles (/cycles) ]  [ ⚲ Scan (/scanner) ]

👑 Administrator (5 Tabs):
[ ⊞ Dashboard (/home) ]  [ 📦 Stock (/stock) ]  [ ⚕ Cycles (/cycles) ]  [ 👥 Users (/admin/users) ]  [ ⚙ Settings (/admin/settings) ]
```

---

## 🏠 3. Role-Aware Home Dashboard (`HomePage`)

The `/home` route renders a tailored experience matching clinical responsibilities:

1. **Administrator**:
   - **Header**: `"Practice Administration"` — `"Cabinet governance, user rights, and regulatory audit trail"`
   - **Live KPI Grid**: Staff Accounts, Audit Events, Stock Catalog count, Autoclave Cycles count.
   - **Modules**: User Management & Roles (`/admin/users`), Audit & Compliance Trail (`/admin/audit`), Practice & Safety Settings (`/admin/settings`).

2. **Assistant**:
   - **Header**: `"Sterilization & Stock Overview"` — `"Autoclave batches, lot validation, and supply levels"`
   - **Live KPI Grid**: Low Stock Alert Items count, Active Autoclave Batch reference.
   - **Operations**: Start Sterilization Cycle (`/cycles`), Inventory & Reorders (`/stock`), Scan & Verify Label (`/scanner`).

3. **Practitioner**:
   - **Header**: `"Good morning, Dr. [Name]"` — `"Scan instrument pouches to attach traceability records to patient files"`
   - **Hero Action**: Large `"Scan Instrument Package"` button (`/scanner`).
   - **Traceability Widgets**: Today's Scans, Pending Sync count, Manual Code entry modal, Compliance Alerts, and Recent Traceability Logs list.

---

## 🔄 4. Zero-Flicker Role Bootstrapping on Refresh

- **Problem Identified**: On page refresh, `AuthBloc` started with `AuthInitial` with a null user. The dashboard momentarily defaulted to `practitioner` for a few frames before `AuthCheckRequested` finished and updated to `admin`.
- **Solution Applied**:
  - `AuthLocalDataSourceImpl` caches the active session in memory and `SharedPreferences`.
  - `AuthBloc` initializes its initial state directly from the cached user record (`state = Authenticated(cachedUser)` from frame 0).
  - `HomePage` displays a branded clinical loading indicator if auth is still validating without any cached session, completely eliminating role flicker.

---

## 🌐 5. Live Laravel API Integration & Token Persistence

### Token Persistence Architecture
- **Bearer Token Extraction**: `LoginResponseModel.fromJson` extracts tokens from standard Sanctum / Passport structures (`token`, `access_token`, `plainTextToken`, `data.token`, `data.access_token`).
- **Multi-Tier Storage**: Tokens and user profiles are stored in:
  1. Synchronous In-Memory Cache (0ms latency for Dio requests).
  2. `FlutterSecureStorage` (encrypted keychain/keystore).
  3. `SharedPreferences` (reliable multi-platform storage).
- **Network Interceptor (`ApiInterceptor`)**: Automatically injects `Authorization: Bearer <token>` and `Accept: application/json` into every outgoing HTTP request.

### Removal of Mock / Fake Data
All fake data fallbacks were removed across all remote data sources:
- `AuthRemoteDataSource`: No mock tokens or mock users. Real errors are propagated.
- `HomeRemoteDataSource`: Pulls live alerts (`/alerts`) and computes today's scan counts from live usages (`/usages`).
- `UsageRemoteDataSource`: Pulls live patient records from `GET /api/v1/patients`.
- `LabelDetailRemoteDataSource`: Pulls cycle parameters from `GET /api/v1/cycles/:id`.
- `AdminRemoteDataSource`: Pulls staff from `GET /api/v1/users` and audit from `GET /api/v1/usages`.
- `StockPage`: Fetches live inventory from `GET /api/v1/stock-levels`.
- `CyclesPage`: Fetches autoclave cycles from `GET /api/v1/cycles`.

---

## 📁 6. Key Files Modified & Created

| File Path | Description |
| :--- | :--- |
| [`lib/features/auth/domain/entities/user.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/auth/domain/entities/user.dart) | User entity with RBAC getters (`isAdmin`, `isAssistant`, `isPractitioner`, permission flags). |
| [`lib/features/auth/data/models/user_model.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/auth/data/models/user_model.dart) | Robust JSON parsing for server-returned user data and role aliases. |
| [`lib/features/auth/data/models/login_response_model.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/auth/data/models/login_response_model.dart) | Multi-format Sanctum token parser. |
| [`lib/features/auth/data/datasources/auth_local_datasource.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/auth/data/datasources/auth_local_datasource.dart) | Multi-tier session and token caching. |
| [`lib/features/auth/data/datasources/auth_remote_datasource.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/auth/data/datasources/auth_remote_datasource.dart) | Live endpoints for `POST /auth/login`, `GET /auth/me`, `POST /auth/logout`. |
| [`lib/core/network/api_interceptor.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/core/network/api_interceptor.dart) | Authorization header injection and error handler. |
| [`lib/core/routes/app_router.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/core/routes/app_router.dart) | Top-level RBAC router guards for all protected endpoints. |
| [`lib/shared/widgets/role_based_bottom_nav.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/shared/widgets/role_based_bottom_nav.dart) | Dynamic bottom navigation component based on user role. |
| [`lib/features/home/presentation/pages/home_page.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/home/presentation/pages/home_page.dart) | Role-aware dashboard with live stats and no flicker on refresh. |
| [`lib/features/stock/presentation/pages/stock_page.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/stock/presentation/pages/stock_page.dart) | Real-time stock levels, category filters, and reorder modal. |
| [`lib/features/cycles/presentation/pages/cycles_page.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/cycles/presentation/pages/cycles_page.dart) | Autoclave sterilization cycle log and validation tracker. |
| [`lib/features/profile/presentation/pages/profile_page.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/lib/features/profile/presentation/pages/profile_page.dart) | User profile, active role badge, permissions chips, and sign-out. |
| [`test/features/auth/rbac_test.dart`](file:///home/ghizlan/Desktop/steriqore_mobile/test/features/auth/rbac_test.dart) | RBAC test suite verifying permissions, router guards, bottom nav, and home dashboard. |

---

## 🧪 7. Test Verification & Code Quality

- **Static Analysis**: `flutter analyze` &rarr; **0 issues found** (clean code).
- **Test Suite**: `flutter test` &rarr; **104 / 104 tests passed (100%)**.
