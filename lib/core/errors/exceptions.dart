class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  const ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection.'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({
    this.message = 'Authentication failed.',
    this.statusCode = 401,
  });

  @override
  String toString() => 'AuthException: $message';
}

class BlockingException implements Exception {
  final String message;
  final int statusCode; // 410 (expired/recalled) or 409 (already used)
  final String? recallReason;

  const BlockingException({
    required this.message,
    required this.statusCode,
    this.recallReason,
  });

  @override
  String toString() => 'BlockingException: $message (code: $statusCode)';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  const ValidationException({
    required this.message,
    required this.errors,
  });

  @override
  String toString() => 'ValidationException: $message, errors: $errors';
}
