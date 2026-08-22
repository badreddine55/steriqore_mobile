# 🏥 STERIQORE — ROLE-BASED ACCESS CONTROL (RBAC)
## AI Agent Prompt — Login → Role Detection → Page Gating

---

## 🔐 THE FLOW

```
Admin creates user (Web Panel)
    ↓
Specifies role: [Admin] [Assistant] [Practitioner]
    ↓
User receives credentials via email
    ↓
User opens mobile app → taps LOGIN
    ↓
POST /auth/login → returns token
    ↓
GET /auth/me → returns user object with role field
    ↓
App reads role → decides which pages to show
    ↓
Router guards block unauthorized routes
```

---

## 📡 API: GET /auth/me

**Response:**
```json
{
  "id": "USR-2026-004",
  "name": "Dr. Sarah Martin",
  "email": "sarah@cabinet.fr",
  "role": "practitioner",
  "cabinet_id": "CAB-2026-001",
  "cabinet_name": "Cabinet Central Paris",
  "permissions": ["scan", "usage", "history", "patients_read"]
}
```

**Roles:** `admin` | `assistant` | `practitioner`

---

## 🧱 AUTH BLOC — ROLE DETECTION

```dart
// lib/features/auth/presentation/bloc/auth_state.dart
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  bool get isAdmin => user?.role == 'admin';
  bool get isAssistant => user?.role == 'assistant';
  bool get isPractitioner => user?.role == 'practitioner';

  // Computed getters for route guards
  bool get canAccessAdmin => isAdmin;
  bool get canAccessStock => isAdmin || isAssistant;
  bool get canAccessCycles => isAdmin || isAssistant;
  bool get canAccessScanner => isAdmin || isAssistant || isPractitioner;
  bool get canAccessUsage => isAdmin || isAssistant || isPractitioner;
  bool get canAccessHistory => isAdmin || isAssistant || isPractitioner;
}
```

---

## 🗺️ ROUTER WITH ROLE GUARDS

```dart
// lib/core/router/app_router.dart

final router = GoRouter(
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    final location = state.matchedLocation;

    // Not logged in → login
    if (authState.status != AuthStatus.authenticated) {
      return location == '/login' ? null : '/login';
    }

    // Logged in but on login page → home
    if (location == '/login') return '/home';

    // Role-based guards
    if (location.startsWith('/admin') && !user.isAdmin) return '/home';
    if (location.startsWith('/stock') && !user.canAccessStock) return '/home';
    if (location.startsWith('/cycles') && !user.canAccessCycles) return '/home';

    return null; // allow
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    GoRoute(path: '/scanner', builder: (_, __) => const ScannerPage()),
    GoRoute(path: '/usage/confirm', builder: (_, __) => const UsageConfirmPage()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
    GoRoute(path: '/stock', builder: (_, __) => const StockPage()),
    GoRoute(path: '/cycles', builder: (_, __) => const CyclesPage()),
    GoRoute(path: '/admin/users', builder: (_, __) => const UserManagementPage()),
    GoRoute(path: '/admin/audit', builder: (_, __) => const AuditTrailPage()),
  ],
);
```

---

## 📊 BOTTOM NAVIGATION — ROLE-BASED TABS

```dart
// lib/shared/widgets/role_based_bottom_nav.dart

class RoleBasedBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    final role = user?.role ?? 'practitioner';

    final items = _getNavItems(role);

    return BottomNavigationBar(
      items: items,
      // ...
    );
  }

  List<BottomNavItem> _getNavItems(String role) {
    switch (role) {
      case 'admin':
        return [
          BottomNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/home'),
          BottomNavItem(icon: Icons.inventory_2_outlined, label: 'Stock', route: '/stock'),
          BottomNavItem(icon: Icons.local_hospital_outlined, label: 'Cycles', route: '/cycles'),
          BottomNavItem(icon: Icons.people_outlined, label: 'Users', route: '/admin/users'),
          BottomNavItem(icon: Icons.settings_outlined, label: 'Settings', route: '/admin/settings'),
        ];
      case 'assistant':
        return [
          BottomNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/home'),
          BottomNavItem(icon: Icons.inventory_2_outlined, label: 'Stock', route: '/stock'),
          BottomNavItem(icon: Icons.local_hospital_outlined, label: 'Cycles', route: '/cycles'),
          BottomNavItem(icon: Icons.qr_code_scanner_outlined, label: 'Scan', route: '/scanner'),
        ];
      case 'practitioner':
        return [
          BottomNavItem(icon: Icons.dashboard_outlined, label: 'Home', route: '/home'),
          BottomNavItem(icon: Icons.qr_code_scanner_outlined, label: 'Scan', route: '/scanner'),
          BottomNavItem(icon: Icons.history_outlined, label: 'History', route: '/history'),
          BottomNavItem(icon: Icons.person_outlined, label: 'Profile', route: '/profile'),
        ];
      default:
        return [];
    }
  }
}
```

---

## 🏠 HOME DASHBOARD — ROLE-BASED WIDGETS

```dart
// lib/features/home/presentation/pages/home_page.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final role = context.select((AuthBloc b) => b.state.user?.role);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(role),
              const SizedBox(height: 24),
              if (role == 'admin') ..._buildAdminWidgets(),
              if (role == 'assistant') ..._buildAssistantWidgets(),
              if (role == 'practitioner') ..._buildPractitionerWidgets(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const RoleBasedBottomNav(),
    );
  }

  Widget _buildHeader(String? role) {
    final title = switch (role) {
      'admin' => 'Admin Dashboard',
      'assistant' => 'Stock Overview',
      'practitioner' => 'Good morning, Doctor',
      _ => 'Welcome',
    };
    return Text(title, style: AppTypography.h1);
  }

  List<Widget> _buildAdminWidgets() => [
    KpiCardGrid(), // Users count, alerts, sync status
    RecentAuditList(),
    QuickActionButton(icon: Icons.person_add, label: 'Add User', route: '/admin/users'),
  ];

  List<Widget> _buildAssistantWidgets() => [
    StockLevelSummary(),
    AlertSummaryCard(),
    QuickActionButton(icon: Icons.add_box, label: 'New Order', route: '/stock/orders'),
    QuickActionButton(icon: Icons.local_hospital, label: 'New Cycle', route: '/cycles/new'),
  ];

  List<Widget> _buildPractitionerWidgets() => [
    TodayScanCount(),
    RecentScansList(),
    AlertSummaryCard(),
    QuickActionButton(icon: Icons.qr_code_scanner, label: 'Scan Instrument', route: '/scanner'),
  ];
}
```

---

## 🚫 WHAT TO BLOCK PER ROLE

| Page / Action | Admin | Assistant | Practitioner |
|---------------|-------|-----------|--------------|
| Create users | ✅ | ❌ | ❌ |
| View all users | ✅ | ❌ | ❌ |
| View audit trail | ✅ | ❌ (own only) | ❌ (own only) |
| Edit cabinet settings | ✅ | ❌ | ❌ |
| Create products | ✅ | ✅ | ❌ |
| Manage orders | ✅ | ✅ | ❌ |
| Run sterilization cycles | ✅ | ✅ | ❌ |
| Scan labels | ✅ | ✅ | ✅ |
| Record usage | ✅ | ✅ | ✅ |
| View patient list | ✅ | ✅ | ✅ (read-only) |
| View own history | ✅ | ✅ | ✅ |
| View others' history | ✅ | ❌ | ❌ |

---

## ⚡ CRITICAL RULES

1. **Server is the source of truth** — Always check role server-side via `/auth/me`. Never trust local storage for role.
2. **Router guards on EVERY protected route** — Never rely on hiding UI alone. Deep links can bypass hidden buttons.
3. **Bottom nav changes per role** — Practitioner sees 4 tabs. Assistant sees 4 different tabs. Admin sees 5 tabs.
4. **Home dashboard is role-aware** — Same route `/home`, different widgets based on role.
5. **If role is unknown / null** — Show loading spinner. If error, redirect to login.
6. **Role change requires re-login** — If admin changes a user's role, they must log out and back in to see new navigation.
7. **No "Register" on mobile** — Only login. Registration happens on Web Admin by Admin only.
