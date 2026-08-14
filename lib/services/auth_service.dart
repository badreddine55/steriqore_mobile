import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
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
}

class AuthService {
  static const String _tokenKey = 'auth_bearer_token';

  /// Save token to persistent device storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Remove stored token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Log in with email & password
  static Future<AuthResult> login({
    required String email,
    required String password,
    String deviceName = 'Flutter Mobile App',
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
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        final data = body['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        await saveToken(token);

        return AuthResult(
          success: true,
          message: body['message'] as String? ?? 'Login successful',
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
        message: 'Connection failed. Please ensure the backend is running at ${ApiConstants.baseUrl}',
      );
    }
  }

  /// Register new user account
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String deviceName = 'Flutter Mobile App',
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
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && body['status'] == 'success') {
        final data = body['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        await saveToken(token);

        return AuthResult(
          success: true,
          message: body['message'] as String? ?? 'Registration successful',
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
        message: 'Connection failed. Please ensure the backend is running at ${ApiConstants.baseUrl}',
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
      );

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
        );
      }
    } finally {
      await clearToken();
    }
    return true;
  }
}
