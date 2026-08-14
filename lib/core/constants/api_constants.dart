import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URL resolution:
  // - Android Emulator uses 10.0.2.2 to reach host machine localhost:8000
  // - iOS simulator, Web, and Desktop use 127.0.0.1:8000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  // Auth endpoints
  static String get status => '$baseUrl/';
  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
  static String get user => '$baseUrl/user';
  static String get logout => '$baseUrl/logout';
}
