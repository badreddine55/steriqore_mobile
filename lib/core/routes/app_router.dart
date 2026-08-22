import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../utils/first_launch_checker.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/cycles/presentation/pages/cycles_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/label_detail/presentation/pages/label_detail_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/scanner/domain/entities/label.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../features/usage/domain/entities/instrument_usage.dart';
import '../../features/usage/domain/entities/patient.dart';
import '../../features/usage/presentation/pages/patient_selection_page.dart';
import '../../features/usage/presentation/pages/usage_confirmation_page.dart';
import '../../features/usage/presentation/pages/usage_success_page.dart';
import '../../features/admin/domain/entities/cabinet_user.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/admin/presentation/pages/audit_trail_page.dart';
import '../../features/admin/presentation/pages/create_user_page.dart';
import '../../features/admin/presentation/pages/user_detail_page.dart';
import '../../features/admin/presentation/pages/user_management_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) async {
    final loc = state.matchedLocation;
    final isPublic = loc == '/splash' || loc == '/onboarding' || loc == '/login';

    // Splash handles its own lifecycle
    if (loc == '/splash') return null;

    try {
      final checker = sl<FirstLaunchChecker>();
      final isFirst = await checker.isFirstLaunch();
      final onboardingDone = await checker.isOnboardingCompleted();

      if ((isFirst || !onboardingDone) && loc != '/onboarding') {
        return '/onboarding';
      }

      final authRepo = sl<AuthRepository>();
      final loggedIn = await authRepo.isLoggedIn();

      // Guard unauthenticated access to protected routes
      if (!loggedIn) {
        if (!isPublic) {
          return '/login';
        }
        return null;
      }

      // Authenticated session: fetch server-authoritative role via /auth/me
      final userResult = await authRepo.getCurrentUser();
      final user = userResult.fold((_) => null, (u) => u);

      // Redirect away from login / register / onboarding if already logged in
      if (loc == '/login' || loc == '/register' || loc == '/onboarding') {
        return '/home';
      }

      if (user == null) {
        return '/login';
      }

      // ==================== ROLE-BASED ROUTER GUARDS ====================
      // 1. Admin routes (/admin/*): Blocked unless role is Admin
      if (loc.startsWith('/admin') && !user.canAccessAdmin) {
        return '/home';
      }

      // 2. Stock routes (/stock/*): Blocked unless Admin or Assistant
      if ((loc == '/stock' || loc.startsWith('/stock/')) && !user.canAccessStock) {
        return '/home';
      }

      // 3. Cycles routes (/cycles/*): Blocked unless Admin or Assistant
      if ((loc == '/cycles' || loc.startsWith('/cycles/')) && !user.canAccessCycles) {
        return '/home';
      }

      // 4. Scanner & Usage routes: Blocked if user cannot scan
      if ((loc.startsWith('/scanner') || loc.startsWith('/label') || loc.startsWith('/usage')) && !user.canAccessScanner) {
        return '/home';
      }

      // 5. History routes: Blocked if user cannot view history
      if (loc.startsWith('/history') && !user.canAccessHistory) {
        return '/home';
      }

      return null; // Route authorized
    } catch (_) {
      return null;
    }
  },
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/scanner',
      name: 'scanner',
      builder: (context, state) => const ScannerPage(),
    ),
    GoRoute(
      path: '/label/:code',
      name: 'label-detail',
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? 'LBL-01';
        return LabelDetailPage(code: code);
      },
    ),
    GoRoute(
      path: '/usage/patient-select',
      name: 'usage-patient-select',
      builder: (context, state) {
        final label = state.extra as Label? ??
            Label(
              id: 1,
              code: 'LBL-01',
              productName: 'Dental Instrument',
              reference: 'REF-01',
              lotNumber: 'LOT-01',
              expirationDate: DateTime.now().add(const Duration(days: 180)),
            );
        return PatientSelectionPage(label: label);
      },
    ),
    GoRoute(
      path: '/usage/confirm',
      name: 'usage-confirm',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final label = extra['label'] as Label? ??
            Label(
              id: 1,
              code: 'LBL-01',
              productName: 'Dental Instrument',
              reference: 'REF-01',
              lotNumber: 'LOT-01',
              expirationDate: DateTime.now().add(const Duration(days: 180)),
            );
        final patient = extra['patient'] as Patient? ??
            const Patient(
              id: 'PAT-001',
              firstName: 'Marie',
              lastName: 'Dubois',
              dossierId: 'DOS-2024-001',
            );
        return UsageConfirmationPage(label: label, patient: patient);
      },
    ),
    GoRoute(
      path: '/usage/success',
      name: 'usage-success',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final usage = extra['usage'] as InstrumentUsage? ??
            InstrumentUsage(
              id: '1',
              idempotencyKey: 'UUID-DEFAULT',
              labelId: '1',
              labelCode: 'LBL-01',
              productName: 'Dental Instrument',
              lotNumber: 'LOT-01',
              patientId: 'PAT-001',
              patientName: 'Marie Dubois',
              dossierId: 'DOS-2024-001',
              practitionerId: '1',
              practitionerName: 'Dr. Practitioner',
              usedAt: DateTime.now(),
            );
        final isOffline = extra['isOffline'] as bool? ?? false;
        return UsageSuccessPage(usage: usage, isOffline: isOffline);
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      path: '/stock',
      name: 'stock',
      builder: (context, state) => const StockPage(),
    ),
    GoRoute(
      path: '/cycles',
      name: 'cycles',
      builder: (context, state) => const CyclesPage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),

    // ==================== ADMINISTRATOR ROUTES ====================
    GoRoute(
      path: '/admin/dashboard',
      name: 'admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/admin/users',
      name: 'admin-users',
      builder: (context, state) => const UserManagementPage(),
    ),
    GoRoute(
      path: '/admin/users/create',
      name: 'admin-users-create',
      builder: (context, state) => const CreateUserPage(),
    ),
    GoRoute(
      path: '/admin/users/:id',
      name: 'admin-user-detail',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '1';
        final id = int.tryParse(idStr) ?? 1;
        final user = state.extra as CabinetUser?;
        return UserDetailPage(userId: id, initialUser: user);
      },
    ),
    GoRoute(
      path: '/admin/audit',
      name: 'admin-audit',
      builder: (context, state) => const AuditTrailPage(),
    ),
    GoRoute(
      path: '/admin/settings',
      name: 'admin-settings',
      builder: (context, state) => const AdminSettingsPage(),
    ),
  ],
);
