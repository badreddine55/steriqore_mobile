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
import 'package:steriqore_mobile/features/auth/domain/usecases/register.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:steriqore_mobile/features/auth/presentation/pages/register_page.dart';

class MockAuthRepo implements AuthRepository {
  String? registeredName;
  String? registeredEmail;
  String? registeredCode;

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
    registeredName = name;
    registeredEmail = email;
    registeredCode = cabinetCode;
    return Right(User(id: 2, name: name, email: email, role: role));
  }

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async =>
      const Right(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner'));

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async =>
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
      registerUseCase: RegisterUseCase(mockAuthRepo),
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

  testWidgets('RegisterPage renders all 6 fields, buttons, and links', (tester) async {
    await tester.pumpWidget(buildTestApp(RegisterPage(authBloc: authBloc)));
    await tester.pump();

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Join your dental practice team'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone (Optional)'), findsOneWidget);
    expect(find.text('Cabinet Code'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Register with Invitation Link'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('RegisterPage validates empty fields on submit', (tester) async {
    await tester.pumpWidget(buildTestApp(RegisterPage(authBloc: authBloc)));
    await tester.pump();

    final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Cabinet code must be at least 4 characters'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('RegisterPage validates password mismatch and strength', (tester) async {
    await tester.pumpWidget(buildTestApp(RegisterPage(authBloc: authBloc)));
    await tester.pump();

    // Enter name
    await tester.enterText(find.byType(TextFormField).at(0), 'Dr. Marie');
    // Enter email
    await tester.enterText(find.byType(TextFormField).at(1), 'marie@cabinet.fr');
    // Enter phone
    await tester.enterText(find.byType(TextFormField).at(2), '+33612345678');
    // Enter code
    await tester.enterText(find.byType(TextFormField).at(3), 'CAB-PARIS-01');
    // Enter weak password
    await tester.enterText(find.byType(TextFormField).at(4), 'secret');
    // Enter mismatch
    await tester.enterText(find.byType(TextFormField).at(5), 'diff');

    final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
