import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/core/theme/app_theme.dart';
import 'package:steriqore_mobile/features/auth/domain/entities/user.dart';
import 'package:steriqore_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/login.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/logout.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:steriqore_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:steriqore_mobile/features/home/presentation/bloc/home_state.dart';
import 'package:steriqore_mobile/features/home/presentation/pages/home_page.dart';
import 'package:steriqore_mobile/features/home/domain/entities/dashboard_stats.dart';
import 'package:steriqore_mobile/features/home/domain/repositories/home_repository.dart';
import 'package:steriqore_mobile/features/home/domain/usecases/get_dashboard_stats.dart';
import 'package:steriqore_mobile/shared/widgets/role_based_bottom_nav.dart';

class MockAuthRepository implements AuthRepository {
  User? currentUser;

  MockAuthRepository([this.currentUser]);

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    return Right(currentUser ?? const User(id: 1, name: 'Test User', email: 'test@cabinet.fr', role: 'practitioner'));
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    String? phone,
    required String cabinetCode,
    required String password,
    required String confirmPassword,
    String role = 'practitioner',
  }) async {
    return Right(currentUser ?? User(id: 1, name: name, email: email, role: role));
  }

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async {
    return Right(currentUser ?? const User(id: 1, name: 'Test User', email: 'test@cabinet.fr', role: 'practitioner'));
  }

  @override
  Future<Either<Failure, void>> selectRole(String role) async => const Right(null);

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (currentUser == null) return const Left(AuthFailure('No active session', 401));
    return Right(currentUser!);
  }

  @override
  Future<bool> isLoggedIn() async => currentUser != null;

  @override
  Future<String?> getSavedRole() async => currentUser?.role;
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    return const Right(DashboardStats(
      todayScansCount: 12,
      pendingSyncCount: 2,
      activeAlertsCount: 1,
      lastCycleTimestamp: '10:45 AM',
      activeAlertMessages: ['1 batch expiring in 48 hours'],
    ));
  }
}

void main() {
  group('RBAC User Entity & AuthState Tests', () {
    test('Practitioner role detection and permission matrix', () {
      const user = User(
        id: 1,
        name: 'Dr. Julien Dubois',
        email: 'julien@cabinet.fr',
        role: 'practitioner',
        permissions: ['scan', 'usage', 'history', 'patients_read'],
      );

      expect(user.isPractitioner, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.isAssistant, isFalse);

      expect(user.canAccessAdmin, isFalse);
      expect(user.canAccessStock, isFalse);
      expect(user.canAccessCycles, isFalse);
      expect(user.canAccessScanner, isTrue);
      expect(user.canAccessUsage, isTrue);
      expect(user.canAccessHistory, isTrue);
      expect(user.canAccessProfile, isTrue);

      const state = Authenticated(user);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.isPractitioner, isTrue);
      expect(state.canAccessAdmin, isFalse);
      expect(state.canAccessStock, isFalse);
      expect(state.canAccessCycles, isFalse);
      expect(state.canAccessScanner, isTrue);
    });

    test('Assistant role detection and permission matrix', () {
      const user = User(
        id: 2,
        name: 'Émilie Leroy',
        email: 'emilie@cabinet.fr',
        role: 'assistant',
        permissions: ['stock', 'cycles', 'scan', 'usage'],
      );

      expect(user.isAssistant, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.isPractitioner, isFalse);

      expect(user.canAccessAdmin, isFalse);
      expect(user.canAccessStock, isTrue);
      expect(user.canAccessCycles, isTrue);
      expect(user.canAccessScanner, isTrue);
      expect(user.canAccessUsage, isTrue);
      expect(user.canAccessHistory, isTrue);

      const state = Authenticated(user);
      expect(state.canAccessAdmin, isFalse);
      expect(state.canAccessStock, isTrue);
      expect(state.canAccessCycles, isTrue);
    });

    test('Administrator role detection and permission matrix', () {
      const user = User(
        id: 3,
        name: 'Dr. Sarah Martin',
        email: 'sarah@cabinet.fr',
        role: 'admin',
        permissions: ['all'],
      );

      expect(user.isAdmin, isTrue);
      expect(user.isAssistant, isFalse);
      expect(user.isPractitioner, isFalse);

      expect(user.canAccessAdmin, isTrue);
      expect(user.canAccessStock, isTrue);
      expect(user.canAccessCycles, isTrue);
      expect(user.canAccessScanner, isTrue);
      expect(user.canAccessUsage, isTrue);
      expect(user.canAccessHistory, isTrue);
      expect(user.canAccessProfile, isTrue);

      const state = Authenticated(user);
      expect(state.canAccessAdmin, isTrue);
      expect(state.canAccessStock, isTrue);
      expect(state.canAccessCycles, isTrue);
    });
  });

  group('Role-Based Bottom Navigation Tests', () {
    Widget buildNavTest(User user) {
      final mockAuth = MockAuthRepository(user);
      final authBloc = AuthBloc(
        loginUseCase: LoginUseCase(mockAuth),
        logoutUseCase: LogoutUseCase(mockAuth),
        getCurrentUserUseCase: GetCurrentUserUseCase(mockAuth),
      )..emit(Authenticated(user));

      return BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          home: const Scaffold(
            bottomNavigationBar: RoleBasedBottomNav(currentRoute: '/home'),
          ),
        ),
      );
    }

    testWidgets('Practitioner sees 4 specific tabs: Home, Scan, History, Profile', (tester) async {
      const user = User(id: 1, name: 'Dr. Julien', email: 'j@c.fr', role: 'practitioner');
      await tester.pumpWidget(buildNavTest(user));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      expect(find.text('Stock'), findsNothing);
      expect(find.text('Cycles'), findsNothing);
      expect(find.text('Users'), findsNothing);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('Assistant sees 4 specific tabs: Dashboard, Stock, Cycles, Scan', (tester) async {
      const user = User(id: 2, name: 'Émilie', email: 'e@c.fr', role: 'assistant');
      await tester.pumpWidget(buildNavTest(user));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      expect(find.text('Cycles'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);

      expect(find.text('Users'), findsNothing);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('History'), findsNothing);
    });

    testWidgets('Administrator sees 5 specific tabs: Dashboard, Stock, Cycles, Users, Settings', (tester) async {
      const user = User(id: 3, name: 'Dr. Sarah', email: 's@c.fr', role: 'admin');
      await tester.pumpWidget(buildNavTest(user));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      expect(find.text('Cycles'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('HomePage Role-Aware Dashboard Widgets Tests', () {
    Widget buildHomePageTest(User user) {
      final mockAuth = MockAuthRepository(user);
      final authBloc = AuthBloc(
        loginUseCase: LoginUseCase(mockAuth),
        logoutUseCase: LogoutUseCase(mockAuth),
        getCurrentUserUseCase: GetCurrentUserUseCase(mockAuth),
      )..emit(Authenticated(user));

      final mockHome = MockHomeRepository();
      final homeBloc = HomeBloc(getDashboardStatsUseCase: GetDashboardStatsUseCase(mockHome))
        ..emit(const HomeLoaded(DashboardStats(
          todayScansCount: 15,
          pendingSyncCount: 0,
          activeAlertsCount: 0,
          lastCycleTimestamp: '11:30 AM',
          activeAlertMessages: [],
        )));

      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<HomeBloc>.value(value: homeBloc),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomePage(authBloc: authBloc, homeBloc: homeBloc),
        ),
      );
    }

    testWidgets('Practitioner sees Clinical Greeting, Hero Scan CTA, Today Scans, and Recent Logs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const user = User(id: 1, name: 'Julien Dubois', email: 'j@c.fr', role: 'practitioner');
      await tester.pumpWidget(buildHomePageTest(user));
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Julien Dubois'), findsOneWidget);
      expect(find.text('Scan Instrument Package'), findsOneWidget);
      expect(find.text('Usage History'), findsOneWidget);
      expect(find.text('COMPLIANCE & ALERTS'), findsOneWidget);
      expect(find.text('RECENT TRACEABILITY LOGS'), findsOneWidget);
    });

    testWidgets('Assistant sees Sterilization & Stock Overview and Operations Modules', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const user = User(id: 2, name: 'Émilie Leroy', email: 'e@c.fr', role: 'assistant');
      await tester.pumpWidget(buildHomePageTest(user));
      await tester.pumpAndSettle();

      expect(find.text('Sterilization & Stock Overview'), findsOneWidget);
      expect(find.text('Low Stock Items'), findsOneWidget);
      expect(find.text('Autoclave Batch'), findsOneWidget);
      expect(find.text('Start Sterilization Cycle'), findsOneWidget);
      expect(find.text('Inventory & Reorders'), findsOneWidget);
    });

    testWidgets('Admin sees Practice Administration, Staff KPI, and Management Modules', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const user = User(id: 3, name: 'Dr. Sarah Martin', email: 's@c.fr', role: 'admin');
      await tester.pumpWidget(buildHomePageTest(user));
      await tester.pumpAndSettle();

      expect(find.text('Practice Administration'), findsOneWidget);
      expect(find.text('Staff Accounts'), findsOneWidget);
      expect(find.text('Audit Events'), findsOneWidget);
      expect(find.text('User Management & Roles'), findsOneWidget);
      expect(find.text('Audit & Compliance Trail'), findsOneWidget);
      expect(find.text('Practice & Safety Settings'), findsOneWidget);
    });
  });
}
