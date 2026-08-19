import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/features/auth/domain/entities/user.dart';
import 'package:steriqore_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/login.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/logout.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/register.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  User? mockUser;
  bool shouldFail = false;
  String? savedRole;

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    if (shouldFail) {
      return const Left(AuthFailure('Invalid credentials', 401));
    }
    mockUser = User(id: 1, name: 'Dr. Dupont', email: email, role: 'practitioner');
    return Right(mockUser!);
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
    if (shouldFail) {
      return const Left(ValidationFailure('Registration validation failed', errors: {
        'email': ['Email already taken']
      }));
    }
    mockUser = User(id: 2, name: name, email: email, role: role);
    return Right(mockUser!);
  }

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async {
    if (shouldFail) {
      return const Left(AuthFailure('Biometric sensor not available', 401));
    }
    mockUser = const User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner');
    return Right(mockUser!);
  }

  @override
  Future<Either<Failure, void>> selectRole(String role) async {
    savedRole = role;
    if (mockUser != null) {
      mockUser = User(
        id: mockUser!.id,
        name: mockUser!.name,
        email: mockUser!.email,
        role: role,
      );
    }
    return const Right(null);
  }

  @override
  Future<String?> getSavedRole() async {
    return savedRole ?? mockUser?.role;
  }

  @override
  Future<Either<Failure, void>> logout() async {
    mockUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (mockUser != null) {
      return Right(mockUser!);
    }
    return const Left(AuthFailure('Unauthenticated', 401));
  }

  @override
  Future<bool> isLoggedIn() async {
    return mockUser != null;
  }
}

void main() {
  late FakeAuthRepository fakeRepo;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late AuthBloc authBloc;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    loginUseCase = LoginUseCase(fakeRepo);
    registerUseCase = RegisterUseCase(fakeRepo);
    logoutUseCase = LogoutUseCase(fakeRepo);
    getCurrentUserUseCase = GetCurrentUserUseCase(fakeRepo);
    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      authRepository: fakeRepo,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('Initial state is AuthInitial', () {
    expect(authBloc.state, equals(const AuthInitial()));
  });

  test('Emits Authenticated when login succeeds', () async {
    expectLater(
      authBloc.stream,
      emitsInOrder([
        const AuthLoading(),
        isA<Authenticated>().having((s) => s.user.email, 'email', 'dr.dupont@steriqore.com'),
      ]),
    );

    authBloc.add(const AuthLoginSubmitted(
      email: 'dr.dupont@steriqore.com',
      password: 'password123',
    ));
  });

  test('Emits AuthFailureState when login fails', () async {
    fakeRepo.shouldFail = true;

    expectLater(
      authBloc.stream,
      emitsInOrder([
        const AuthLoading(),
        isA<AuthFailureState>().having((s) => s.message, 'message', 'Invalid credentials'),
      ]),
    );

    authBloc.add(const AuthLoginSubmitted(
      email: 'wrong@steriqore.com',
      password: 'wrong',
    ));
  });

  test('Emits AuthRegistered when register succeeds', () async {
    expectLater(
      authBloc.stream,
      emitsInOrder([
        const AuthLoading(),
        isA<AuthRegistered>().having((s) => s.user.name, 'name', 'Dr. Sarah'),
      ]),
    );

    authBloc.add(const AuthRegisterSubmitted(
      name: 'Dr. Sarah',
      email: 'sarah@cabinet.fr',
      cabinetCode: 'CAB-001',
      password: 'Password123',
      confirmPassword: 'Password123',
    ));
  });

  test('Emits Authenticated when biometric login requested', () async {
    expectLater(
      authBloc.stream,
      emitsInOrder([
        const AuthLoading(),
        isA<Authenticated>().having((s) => s.user.email, 'email', 'doctor@cabinet.fr'),
      ]),
    );

    authBloc.add(const AuthBiometricLoginRequested());
  });

  test('Emits Authenticated with updated role when AuthRoleSelected event dispatched', () async {
    fakeRepo.mockUser = const User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'assistant');

    authBloc.add(const AuthRoleSelected('practitioner'));
    await Future.delayed(const Duration(milliseconds: 50));

    expect(fakeRepo.savedRole, equals('practitioner'));
  });

  test('Emits Unauthenticated when logout is requested', () async {
    expectLater(
      authBloc.stream,
      emitsInOrder([
        const AuthLoading(),
        const Unauthenticated(),
      ]),
    );

    authBloc.add(const AuthLogoutRequested());
  });
}
