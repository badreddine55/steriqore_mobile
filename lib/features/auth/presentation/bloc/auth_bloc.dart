import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final RegisterUseCase? registerUseCase;
  final AuthRepository? authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    this.registerUseCase,
    this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginSubmitted>(_onAuthLoginSubmitted);
    on<AuthRegisterSubmitted>(_onAuthRegisterSubmitted);
    on<AuthBiometricLoginRequested>(_onAuthBiometricLoginRequested);
    on<AuthRoleSelected>(_onAuthRoleSelected);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onAuthLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(AuthFailureState(failure.message, errors: failure.errors));
        } else {
          emit(AuthFailureState(failure.message));
        }
      },
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onAuthRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    if (registerUseCase != null) {
      final result = await registerUseCase!(RegisterParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        cabinetCode: event.cabinetCode,
        password: event.password,
        confirmPassword: event.confirmPassword,
        role: event.role,
      ));

      result.fold(
        (failure) {
          if (failure is ValidationFailure) {
            emit(AuthFailureState(failure.message, errors: failure.errors));
          } else {
            emit(AuthFailureState(failure.message));
          }
        },
        (user) => emit(AuthRegistered(user)),
      );
    } else if (authRepository != null) {
      final result = await authRepository!.register(
        name: event.name,
        email: event.email,
        phone: event.phone,
        cabinetCode: event.cabinetCode,
        password: event.password,
        confirmPassword: event.confirmPassword,
        role: event.role,
      );

      result.fold(
        (failure) {
          if (failure is ValidationFailure) {
            emit(AuthFailureState(failure.message, errors: failure.errors));
          } else {
            emit(AuthFailureState(failure.message));
          }
        },
        (user) => emit(AuthRegistered(user)),
      );
    } else {
      // Fallback
      emit(const AuthFailureState('Registration service not initialized.'));
    }
  }

  Future<void> _onAuthBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    if (authRepository != null) {
      final result = await authRepository!.loginWithBiometrics();
      result.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    } else {
      // Direct success if repository isn't provided directly
      final result = await getCurrentUserUseCase(const NoParams());
      result.fold(
        (failure) => emit(const AuthFailureState('Biometric sign in failed.')),
        (user) => emit(Authenticated(user)),
      );
    }
  }

  Future<void> _onAuthRoleSelected(
    AuthRoleSelected event,
    Emitter<AuthState> emit,
  ) async {
    if (authRepository != null) {
      await authRepository!.selectRole(event.role);
    }
    if (state is Authenticated) {
      final current = (state as Authenticated).user;
      final updated = current.role != event.role
          ? (await getCurrentUserUseCase(const NoParams())).getOrElse(() => current)
          : current;
      emit(Authenticated(updated));
    } else if (state is AuthRegistered) {
      final current = (state as AuthRegistered).user;
      emit(Authenticated(current));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await logoutUseCase(const NoParams());
    emit(const Unauthenticated());
  }
}
