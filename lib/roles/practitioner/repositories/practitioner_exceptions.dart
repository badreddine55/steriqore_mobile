import '../models/label_model.dart';

/// Base exception class for Practitioner operations
class PractitionerException implements Exception {
  final String message;
  final int? statusCode;

  const PractitionerException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// 401 Unauthorized / Token Expired
class TokenExpiredException extends PractitionerException {
  const TokenExpiredException([String message = 'Session expired. Please re-authenticate.'])
      : super(message, 401);
}

/// 403 Forbidden (Insufficient practice role permissions)
class RoleForbiddenException extends PractitionerException {
  const RoleForbiddenException([String message = 'Access denied: Practitioner role required.'])
      : super(message, 403);
}

/// 404 Label Not Found
class LabelNotFoundException extends PractitionerException {
  final String code;
  const LabelNotFoundException(this.code, [String? message])
      : super(message ?? 'Invalid code — no matching label found for "$code".', 404);
}

/// 409 Conflict: Instrument usage already recorded on a patient
class UsageAlreadyRecordedException extends PractitionerException {
  final LabelModel? label;
  const UsageAlreadyRecordedException([this.label, String? message])
      : super(
          message ?? 'This instrument package was already recorded as used.',
          409,
        );
}

/// 410 Gone / Patient Safety Gate: Expired DLC or Recalled Lot
class LabelBlockedException extends PractitionerException {
  final LabelModel label;
  final String reason;

  const LabelBlockedException(this.label, this.reason, [String? message])
      : super(
          message ?? 'SAFETY BLOCK: Instrument lot is expired or subject to safety recall.',
          410,
        );
}

/// 422 Unprocessable Entity / Validation Error
class PractitionerValidationException extends PractitionerException {
  final Map<String, List<String>> errors;

  const PractitionerValidationException(this.errors, [String message = 'Validation error.'])
      : super(message, 422);

  String get firstError {
    if (errors.isNotEmpty) {
      final firstVal = errors.values.first;
      if (firstVal.isNotEmpty) return firstVal.first;
    }
    return message;
  }
}

/// 429 Too Many Requests / Rate Limited
class RateLimitException extends PractitionerException {
  final int retryAfterSeconds;

  const RateLimitException([this.retryAfterSeconds = 5, String? message])
      : super(
          message ?? 'Too many scans — please wait $retryAfterSeconds seconds before trying again.',
          429,
        );
}

/// Shaky network / connection offline
class NetworkOfflineException extends PractitionerException {
  const NetworkOfflineException([String message = 'No internet connection. Operation queued for sync.'])
      : super(message, 0);
}
