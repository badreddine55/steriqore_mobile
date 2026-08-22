import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static const int backendPort = 8000;

  // Your PC's LAN IP — used when testing on a physical Android device over WiFi.
  // Update this if your PC's IP changes (check with `hostname -I` on Linux).
  static const String _lanHost = '10.32.73.207';

  // Optional override: run with `flutter run --dart-define=API_HOST=x.x.x.x`
  static const String _overrideHost = String.fromEnvironment('API_HOST');

  static String get _host {
    if (_overrideHost.isNotEmpty) return _overrideHost;
    if (kIsWeb) return '127.0.0.1';
    if (!kIsWeb && Platform.isAndroid) return _lanHost;
    return '127.0.0.1';
  }

  static String get baseUrl => 'http://$_host:$backendPort';
  static const String apiVersion = '/api/v1';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String user = '/auth/me';
  static const String status = '/health';

  // Scanner / Labels
  static const String labels = '/labels';
  static String labelDetail(dynamic code) => '/labels/$code';
  static String labelByCode(dynamic code) => '/labels/$code';

  // Cycles
  static const String cycles = '/cycles';
  static String cycleDetail(dynamic id) => '/cycles/$id';
  static String cycleDetails(dynamic id) => '/cycles/$id';
  static String cycleItems(dynamic id) => '/cycles/$id/items';
  static String cycleLabels(dynamic id) => '/cycles/$id/labels';
  static String cycleAttachments(dynamic id) => '/cycles/$id/attachments';

  // Usage
  static String recordUsage(dynamic labelId) => '/labels/$labelId/usage';
  static String labelUsage(dynamic labelId) => '/labels/$labelId/usage';
  static const String usages = '/usages';
  static const String myHistory = '/practitioner/usages';

  // Patients
  static const String patients = '/patients';

  // History / Dashboard
  static const String stockLevels = '/stock-levels';
  static const String alerts = '/alerts';

  // Admin
  static const String users = '/users';
  static String userDetail(dynamic id) => '/users/$id';
  static const String auditTrail = '/audit-trail';
  static const String organizations = '/organizations/current';
}

class ApiErrorHandler {
  ApiErrorHandler._();

  static String getMessage(int statusCode, String? backendMessage) {
    switch (statusCode) {
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Item not found. Please check the code and try again.';
      case 409:
        return 'This instrument has already been recorded as used.';
      case 410:
        return 'This instrument is expired or recalled and cannot be used.';
      case 422:
        return backendMessage ?? 'Invalid data. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return backendMessage ?? 'An unexpected error occurred. Please try again.';
    }
  }

  static bool isBlockingError(int statusCode) {
    return statusCode == 410 || statusCode == 409;
  }
}
