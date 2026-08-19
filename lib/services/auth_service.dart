import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/storage_keys.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;
  final Map<String, dynamic>? errors;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errors,
  });

  /// Extract the first readable validation error string
  String get firstErrorMessage {
    if (errors != null && errors!.isNotEmpty) {
      final firstVal = errors!.values.first;
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
      return firstVal.toString();
    }
    return message;
  }
}

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _lastUserKey = 'last_user_name';

  /// Save token securely
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    try {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: StorageKeys.authToken, value: token);
    } catch (_) {}
  }

  /// Alias for setToken
  static Future<void> saveToken(String token) => setToken(token);

  /// Get stored token
  static Future<String?> getToken() async {
    try {
      const secureStorage = FlutterSecureStorage();
      final secToken = await secureStorage.read(key: StorageKeys.authToken);
      if (secToken != null && secToken.isNotEmpty) return secToken;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Remove stored token and all session state
  static Future<void> clearToken() async {
    try {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: StorageKeys.authToken);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(StorageKeys.currentUser);
    await prefs.remove(StorageKeys.userRole);

    try {
      if (Hive.isBoxOpen(StorageKeys.authBox)) {
        final box = Hive.box(StorageKeys.authBox);
        await box.delete(StorageKeys.currentUser);
        await box.delete(StorageKeys.userRole);
      }
    } catch (_) {}
  }

  /// Remember email for quick login
  static Future<void> setRememberedEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_rememberedEmailKey, email);
    } else {
      await prefs.remove(_rememberedEmailKey);
    }
  }

  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberedEmailKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Health check of the backend
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.status),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Log in with email & password
  static Future<AuthResult> login({
    required String email,
    required String password,
    String deviceName = 'DentisTrack Mobile Client',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'device_name': deviceName,
        }),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && (body['status'] == 'success' || body['data'] != null)) {
        final data = body['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        await saveToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastUserKey, user.name);

        return AuthResult(
          success: true,
          message: body['message'] as String? ?? 'Authenticated successfully.',
          token: token,
          user: user,
        );
      } else {
        final message = body['message'] as String? ?? 'Invalid credentials';
        final errors = body['errors'] as Map<String, dynamic>?;
        return AuthResult(
          success: false,
          message: message,
          errors: errors,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Could not connect to API server (${ApiConstants.baseUrl}). Please verify the backend is running.',
      );
    }
  }

  /// Register new user account
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String deviceName = 'DentisTrack Mobile Client',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'device_name': deviceName,
        }),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && (body['status'] == 'success' || body['data'] != null)) {
        final data = body['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        await saveToken(token);

        return AuthResult(
          success: true,
          message: body['message'] as String? ?? 'User registered successfully.',
          token: token,
          user: user,
        );
      } else {
        final message = body['message'] as String? ?? 'Registration failed';
        final errors = body['errors'] as Map<String, dynamic>?;
        return AuthResult(
          success: false,
          message: message,
          errors: errors,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Could not connect to API server (${ApiConstants.baseUrl}). Please verify the backend is running.',
      );
    }
  }

  /// Fetch authenticated user profile
  static Future<UserModel?> getUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.user),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Logout and revoke token
  static Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));
      }
    } catch (_) {
      // Proceed to clear local token even if network fails
    } finally {
      await clearToken();
    }
    return true;
  }
}
