import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

abstract class AuthState extends Equatable {
  const AuthState();

  AuthStatus get status => AuthStatus.unknown;
  User? get user => null;

  bool get isAdmin => user?.isAdmin ?? false;
  bool get isAssistant => user?.isAssistant ?? false;
  bool get isPractitioner => user?.isPractitioner ?? false;

  // Computed getters for RBAC route guards
  bool get canAccessAdmin => isAdmin;
  bool get canAccessStock => isAdmin || isAssistant;
  bool get canAccessCycles => isAdmin || isAssistant;
  bool get canAccessScanner => isAdmin || isAssistant || isPractitioner;
  bool get canAccessUsage => isAdmin || isAssistant || isPractitioner;
  bool get canAccessHistory => isAdmin || isAssistant || isPractitioner;
  bool get canAccessProfile => true;

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  AuthStatus get status => AuthStatus.unknown;
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  AuthStatus get status => AuthStatus.loading;
}

class Authenticated extends AuthState {
  @override
  final User user;

  const Authenticated(this.user);

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  List<Object?> get props => [user];
}

class AuthRegistered extends AuthState {
  @override
  final User user;

  const AuthRegistered(this.user);

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  AuthStatus get status => AuthStatus.unauthenticated;
}

class AuthFailureState extends AuthState {
  final String message;
  final Map<String, List<String>> errors;

  const AuthFailureState(this.message, {this.errors = const {}});

  @override
  AuthStatus get status => AuthStatus.failure;

  @override
  List<Object?> get props => [message, errors];
}
