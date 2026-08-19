import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Saved — will sync when online.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Session expired. Please log in again.', super.statusCode = 401]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Invalid code — no such label.', super.statusCode = 404]);
}

class AlreadyUsedFailure extends Failure {
  const AlreadyUsedFailure([super.message = 'This instrument was already recorded as used.', super.statusCode = 409]);
}

class RateLimitedFailure extends Failure {
  final int retryAfterSeconds;

  const RateLimitedFailure([
    super.message = 'Too many scans — wait a moment.',
    this.retryAfterSeconds = 5,
    super.statusCode = 429,
  ]);

  @override
  List<Object?> get props => [message, statusCode, retryAfterSeconds];
}

class BlockingFailure extends Failure {
  final String? recallReason;

  const BlockingFailure(
    String message, {
    int? statusCode = 410,
    this.recallReason,
  }) : super(message, statusCode);

  @override
  List<Object?> get props => [message, statusCode, recallReason];
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure(
    String message, {
    this.errors = const {},
  }) : super(message, 422);

  @override
  List<Object?> get props => [message, statusCode, errors];
}
