import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRegistered extends AuthState {
  final User user;

  const AuthRegistered(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailureState extends AuthState {
  final String message;
  final Map<String, List<String>> errors;

  const AuthFailureState(this.message, {this.errors = const {}});

  @override
  List<Object?> get props => [message, errors];
}
