import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> saveRole(String role);
  Future<String?> getRole();
  Future<void> clearAuth();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences? prefs;

  // In-memory token cache for synchronous, zero-latency access across all HTTP requests
  static String? cachedToken;
  static UserModel? cachedUser;

  AuthLocalDataSourceImpl({
    FlutterSecureStorage? secureStorage,
    this.prefs,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    cachedToken = token;
    try {
      await secureStorage.write(key: StorageKeys.authToken, value: token);
    } catch (_) {}

    try {
      final sp = prefs ?? await SharedPreferences.getInstance();
      await sp.setString(StorageKeys.authToken, token);
    } catch (_) {}
  }

  @override
  Future<String?> getToken() async {
    if (cachedToken != null && cachedToken!.isNotEmpty) {
      return cachedToken;
    }

    try {
      final token = await secureStorage.read(key: StorageKeys.authToken);
      if (token != null && token.isNotEmpty) {
        cachedToken = token;
        return token;
      }
    } catch (_) {}

    try {
      final sp = prefs ?? await SharedPreferences.getInstance();
      final spToken = sp.getString(StorageKeys.authToken);
      if (spToken != null && spToken.isNotEmpty) {
        cachedToken = spToken;
        return spToken;
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    cachedUser = user;
    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.setString(StorageKeys.currentUser, jsonEncode(user.toJson()));
    await sp.setString(StorageKeys.userRole, user.role);

    try {
      Box box;
      if (Hive.isBoxOpen(StorageKeys.authBox)) {
        box = Hive.box(StorageKeys.authBox);
      } else {
        box = await Hive.openBox(StorageKeys.authBox);
      }
      await box.put(StorageKeys.currentUser, jsonEncode(user.toJson()));
      await box.put(StorageKeys.userRole, user.role);
    } catch (_) {}
  }

  @override
  Future<UserModel?> getUser() async {
    if (cachedUser != null) {
      return cachedUser;
    }

    final sp = prefs ?? await SharedPreferences.getInstance();
    final userStr = sp.getString(StorageKeys.currentUser);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        final map = jsonDecode(userStr) as Map<String, dynamic>;
        final user = UserModel.fromJson(map);
        cachedUser = user;
        return user;
      } catch (_) {}
    }

    try {
      if (Hive.isBoxOpen(StorageKeys.authBox)) {
        final box = Hive.box(StorageKeys.authBox);
        final hiveUser = box.get(StorageKeys.currentUser);
        if (hiveUser != null) {
          final map = jsonDecode(hiveUser as String) as Map<String, dynamic>;
          final user = UserModel.fromJson(map);
          cachedUser = user;
          return user;
        }
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> saveRole(String role) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.setString(StorageKeys.userRole, role);

    try {
      Box box;
      if (Hive.isBoxOpen(StorageKeys.authBox)) {
        box = Hive.box(StorageKeys.authBox);
      } else {
        box = await Hive.openBox(StorageKeys.authBox);
      }
      await box.put(StorageKeys.userRole, role);
    } catch (_) {}
  }

  @override
  Future<String?> getRole() async {
    if (cachedUser != null) return cachedUser!.role;

    final sp = prefs ?? await SharedPreferences.getInstance();
    final role = sp.getString(StorageKeys.userRole);
    if (role != null && role.isNotEmpty) return role;

    try {
      if (Hive.isBoxOpen(StorageKeys.authBox)) {
        final box = Hive.box(StorageKeys.authBox);
        final hiveRole = box.get(StorageKeys.userRole);
        if (hiveRole != null) return hiveRole as String;
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> clearAuth() async {
    cachedToken = null;
    cachedUser = null;
    try {
      await secureStorage.delete(key: StorageKeys.authToken);
    } catch (_) {}

    try {
      final sp = prefs ?? await SharedPreferences.getInstance();
      await sp.remove(StorageKeys.authToken);
      await sp.remove(StorageKeys.currentUser);
      await sp.remove(StorageKeys.userRole);
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(StorageKeys.authBox)) {
        final box = Hive.box(StorageKeys.authBox);
        await box.delete(StorageKeys.currentUser);
        await box.delete(StorageKeys.userRole);
      }
    } catch (_) {}
  }
}
