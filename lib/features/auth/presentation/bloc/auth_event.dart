import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String? phone;
  final String cabinetCode;
  final String password;
  final String confirmPassword;
  final String role;

  const AuthRegisterSubmitted({
    required this.name,
    required this.email,
    this.phone,
    required this.cabinetCode,
    required this.password,
    required this.confirmPassword,
    this.role = 'practitioner',
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        cabinetCode,
        password,
        confirmPassword,
        role,
      ];
}

class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested();
}

class AuthRoleSelected extends AuthEvent {
  final String role;

  const AuthRoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
