import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/core/theme/app_theme.dart';
import 'package:steriqore_mobile/features/admin/domain/entities/audit_entry.dart';
import 'package:steriqore_mobile/features/admin/domain/entities/cabinet_settings.dart';
import 'package:steriqore_mobile/features/admin/domain/entities/cabinet_user.dart';
import 'package:steriqore_mobile/features/admin/domain/repositories/admin_repository.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/create_cabinet_user.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/get_audit_trail.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/get_cabinet_settings.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/get_cabinet_users.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/toggle_user_status.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/update_cabinet_settings.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/update_cabinet_user.dart';
import 'package:steriqore_mobile/features/admin/presentation/bloc/admin_audit_bloc.dart';
import 'package:steriqore_mobile/features/admin/presentation/bloc/admin_settings_bloc.dart';
import 'package:steriqore_mobile/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:steriqore_mobile/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:steriqore_mobile/features/admin/presentation/pages/audit_trail_page.dart';
import 'package:steriqore_mobile/features/admin/presentation/pages/create_user_page.dart';
import 'package:steriqore_mobile/features/admin/presentation/pages/user_management_page.dart';
import 'package:steriqore_mobile/features/auth/domain/entities/user.dart';
import 'package:steriqore_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/login.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/logout.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/register.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_bloc.dart';

class FakeAdminRepository implements AdminRepository {
  @override
  Future<Either<Failure, List<CabinetUser>>> getUsers({String? search, String? role, bool? isActive}) async {
    return const Right([
      CabinetUser(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin', isActive: true),
      CabinetUser(id: 2, name: 'Dr. Julien Dubois', email: 'julien@cabinet.fr', role: 'practitioner', isActive: true),
    ]);
  }

  @override
  Future<Either<Failure, CabinetUser>> getUserById(int id) async {
    return const Right(CabinetUser(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin'));
  }

  @override
  Future<Either<Failure, CabinetUser>> createUser({
    required String name,
    required String email,
    String? phone,
    required String role,
    required String password,
    String? cabinetRoom,
    List<String>? permissions,
  }) async {
    return Right(CabinetUser(id: 3, name: name, email: email, role: role));
  }

  @override
  Future<Either<Failure, CabinetUser>> updateUser(int id, {String? name, String? email, String? phone, String? role, String? cabinetRoom, List<String>? permissions}) async {
    return const Right(CabinetUser(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin'));
  }

  @override
  Future<Either<Failure, CabinetUser>> toggleUserStatus(int id, bool isActive) async {
    return Right(CabinetUser(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin', isActive: isActive));
  }

  @override
  Future<Either<Failure, List<AuditEntry>>> getAuditTrail({String? search, String? action, int? userId, DateTime? startDate, DateTime? endDate}) async {
    return Right([
      AuditEntry(
        id: 'AUD-001',
        userId: 1,
        userName: 'Dr. Sarah Martin',
        userRole: 'admin',
        action: 'CREATE_USER',
        entityType: 'user',
        details: 'Created assistant user',
        timestamp: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<Either<Failure, CabinetSettings>> getCabinetSettings() async {
    return const Right(CabinetSettings(id: 1, cabinetName: 'Cabinet Central', cabinetCode: 'CAB-01'));
  }

  @override
  Future<Either<Failure, CabinetSettings>> updateCabinetSettings(CabinetSettings settings) async {
    return Right(settings);
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    return const Right(User(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin'));
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
    return const Right(User(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin'));
  }

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async {
    return const Right(User(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin'));
  }

  @override
  Future<Either<Failure, void>> selectRole(String role) async => const Right(null);

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    return const Right(User(id: 1, name: 'Dr. Sarah Martin', email: 'sarah@cabinet.fr', role: 'admin'));
  }

  @override
  Future<bool> isLoggedIn() async => true;

  @override
  Future<String?> getSavedRole() async => 'admin';
}

void main() {
  late FakeAdminRepository fakeAdminRepo;
  late FakeAuthRepository fakeAuthRepo;
  late AdminUsersBloc usersBloc;
  late AdminAuditBloc auditBloc;
  late AdminSettingsBloc settingsBloc;
  late AuthBloc authBloc;

  setUp(() {
    fakeAdminRepo = FakeAdminRepository();
    fakeAuthRepo = FakeAuthRepository();

    usersBloc = AdminUsersBloc(
      getCabinetUsersUseCase: GetCabinetUsersUseCase(fakeAdminRepo),
      createCabinetUserUseCase: CreateCabinetUserUseCase(fakeAdminRepo),
      updateCabinetUserUseCase: UpdateCabinetUserUseCase(fakeAdminRepo),
      toggleUserStatusUseCase: ToggleUserStatusUseCase(fakeAdminRepo),
    );

    auditBloc = AdminAuditBloc(getAuditTrailUseCase: GetAuditTrailUseCase(fakeAdminRepo));
    settingsBloc = AdminSettingsBloc(
      getCabinetSettingsUseCase: GetCabinetSettingsUseCase(fakeAdminRepo),
      updateCabinetSettingsUseCase: UpdateCabinetSettingsUseCase(fakeAdminRepo),
    );

    authBloc = AuthBloc(
      loginUseCase: LoginUseCase(fakeAuthRepo),
      logoutUseCase: LogoutUseCase(fakeAuthRepo),
      getCurrentUserUseCase: GetCurrentUserUseCase(fakeAuthRepo),
      registerUseCase: RegisterUseCase(fakeAuthRepo),
      authRepository: fakeAuthRepo,
    );
  });

  tearDown(() {
    usersBloc.close();
    auditBloc.close();
    settingsBloc.close();
    authBloc.close();
  });

  Widget createTestWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminUsersBloc>.value(value: usersBloc),
        BlocProvider<AdminAuditBloc>.value(value: auditBloc),
        BlocProvider<AdminSettingsBloc>.value(value: settingsBloc),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  testWidgets('AdminDashboardPage renders headline and management tiles', (tester) async {
    await tester.pumpWidget(createTestWidget(const AdminDashboardPage()));
    await tester.pumpAndSettle();

    expect(find.text('Cabinet Administration'), findsOneWidget);
    expect(find.text('User Management'), findsOneWidget);
    expect(find.text('Audit & Compliance Trail'), findsOneWidget);
    expect(find.text('Practice & Safety Settings'), findsOneWidget);
  });

  testWidgets('UserManagementPage renders title and Add User button', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const UserManagementPage()));
    await tester.pumpAndSettle();

    expect(find.text('User Management'), findsOneWidget);
    expect(find.text('Add User'), findsOneWidget);
  });

  testWidgets('CreateUserPage renders role options and create button', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const CreateUserPage()));
    await tester.pumpAndSettle();

    expect(find.text('Add Staff Member'), findsOneWidget);
    expect(find.text('Practitioner'), findsOneWidget);
    expect(find.text('Stock Manager / Assistant'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
    expect(find.text('Create Account & Send Credentials'), findsOneWidget);
  });

  testWidgets('AuditTrailPage renders header and search bar', (tester) async {
    await tester.pumpWidget(createTestWidget(const AuditTrailPage()));
    await tester.pumpAndSettle();

    expect(find.text('Audit Trail & Compliance'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
