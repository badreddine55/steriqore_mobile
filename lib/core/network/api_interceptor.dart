import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../errors/exceptions.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  ApiInterceptor([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token if present
    final token = await _secureStorage.read(key: StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    if (kDebugMode) {
      debugPrint('➡️ [DIO REQ] ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('📦 [BODY] ${options.data}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ [DIO RESP] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final statusCode = response?.statusCode ?? 0;

    String? backendMessage;
    if (response?.data is Map) {
      backendMessage = response?.data['message']?.toString();
    }

    final message = ApiErrorHandler.getMessage(statusCode, backendMessage);

    if (kDebugMode) {
      debugPrint('❌ [DIO ERR] Status: $statusCode Message: $message');
    }

    if (statusCode == 410 || statusCode == 409) {
      final recallReason = response?.data is Map ? response?.data['recall_reason']?.toString() : null;
      throw BlockingException(
        message: message,
        statusCode: statusCode,
        recallReason: recallReason,
      );
    } else if (statusCode == 422 && response?.data is Map && response?.data['errors'] != null) {
      final rawErrors = response?.data['errors'] as Map;
      final errorsMap = <String, List<String>>{};
      rawErrors.forEach((key, val) {
        if (val is List) {
          errorsMap[key.toString()] = val.map((e) => e.toString()).toList();
        } else {
          errorsMap[key.toString()] = [val.toString()];
        }
      });
      throw ValidationException(message: message, errors: errorsMap);
    } else if (statusCode == 401) {
      throw AuthException(message: message, statusCode: statusCode);
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      throw const NetworkException(message: 'Connection timed out or network offline.');
    }

    handler.next(err);
  }
}
