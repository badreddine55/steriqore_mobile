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
import 'package:steriqore_mobile/features/auth/presentation/pages/login_page.dart';

class MockAuthRepo implements AuthRepository {
  String? lastLoginEmail;
  String? lastLoginPassword;
  bool biometricCalled = false;

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    return const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));
  }

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async {
    biometricCalled = true;
    return const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));
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
  }) async =>
      const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));

  @override
  Future<Either<Failure, void>> selectRole(String role) async => const Right(null);

  @override
  Future<String?> getSavedRole() async => 'practitioner';

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

  testWidgets('LoginPage renders header, inputs, and buttons properly', (tester) async {
    await tester.pumpWidget(buildTestApp(LoginPage(authBloc: authBloc)));
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to your dental practice'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign in with Biometrics'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('LoginPage submits credentials when Sign In is tapped', (tester) async {
    await tester.pumpWidget(buildTestApp(LoginPage(authBloc: authBloc)));
    await tester.pump();

    final signInButton = find.text('Sign In');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();

    expect(mockAuthRepo.lastLoginEmail, equals('doctor@cabinet.fr'));
    expect(mockAuthRepo.lastLoginPassword, equals('secret123'));
  });

  testWidgets('LoginPage triggers biometric login when tapped', (tester) async {
    await tester.pumpWidget(buildTestApp(LoginPage(authBloc: authBloc)));
    await tester.pump();

    final biometricButton = find.text('Sign in with Biometrics');
    await tester.ensureVisible(biometricButton);
    await tester.tap(biometricButton);
    await tester.pump();

    expect(mockAuthRepo.biometricCalled, isTrue);
  });
}
