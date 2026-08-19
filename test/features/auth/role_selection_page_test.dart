import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/features/auth/domain/entities/user.dart';
import 'package:steriqore_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/login.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/logout.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:steriqore_mobile/features/auth/presentation/pages/role_selection_page.dart';
import 'package:steriqore_mobile/features/auth/presentation/widgets/role_selection_card.dart';

class MockAuthRepo implements AuthRepository {
  String? selectedRole;

  @override
  Future<Either<Failure, void>> selectRole(String role) async {
    selectedRole = role;
    return const Right(null);
  }

  @override
  Future<String?> getSavedRole() async => selectedRole;

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async =>
      const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    String? phone,
    required String cabinetCode,
    required String password,
    required String confirmPassword,
    String role = 'practitioner',
  }) async =>
      const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async =>
      const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, User>> getCurrentUser() async =>
      const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));

  @override
  Future<bool> isLoggedIn() async => true;
}

void main() {
  late MockAuthRepo mockAuthRepo;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    authBloc = AuthBloc(
      loginUseCase: LoginUseCase(mockAuthRepo),
      logoutUseCase: LogoutUseCase(mockAuthRepo),
      getCurrentUserUseCase: GetCurrentUserUseCase(mockAuthRepo),
      authRepository: mockAuthRepo,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  Widget buildTestApp(Widget child) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('RoleSelectionPage renders header and 3 role cards', (tester) async {
    await tester.pumpWidget(buildTestApp(RoleSelectionPage(authBloc: authBloc)));
    await tester.pump();

    expect(find.text('Select your role'), findsOneWidget);
    expect(find.text('Choose how you will use STERIQORE'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
    expect(find.text('Stock Manager'), findsOneWidget);
    expect(find.text('Practitioner'), findsOneWidget);
    expect(find.byType(RoleSelectionCard), findsNWidgets(3));
  });

  testWidgets('Tapping Practitioner card selects role and invokes callback', (tester) async {
    String? selected;

    await tester.pumpWidget(buildTestApp(RoleSelectionPage(
      authBloc: authBloc,
      onRoleSelected: (role) => selected = role,
    )));
    await tester.pump();

    final practitionerCard = find.text('Practitioner');
    await tester.tap(practitionerCard);
    await tester.pump();

    expect(selected, equals('practitioner'));
    expect(mockAuthRepo.selectedRole, equals('practitioner'));
  });
}
