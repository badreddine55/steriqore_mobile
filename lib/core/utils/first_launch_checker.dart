import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class FirstLaunchChecker {
  final SharedPreferences? prefs;

  FirstLaunchChecker({this.prefs});

  /// Check if the app is being launched for the very first time.
  Future<bool> isFirstLaunch() async {
    try {
      if (Hive.isBoxOpen(StorageKeys.appSettingsBox)) {
        final box = Hive.box(StorageKeys.appSettingsBox);
        final completed = box.get(StorageKeys.isFirstLaunch);
        if (completed != null) {
          return completed == true;
        }
      } else {
        final box = await Hive.openBox(StorageKeys.appSettingsBox);
        final completed = box.get(StorageKeys.isFirstLaunch);
        if (completed != null) {
          return completed == true;
        }
      }
    } catch (_) {}

    final sp = prefs ?? await SharedPreferences.getInstance();
    final isFirst = sp.getBool(StorageKeys.isFirstLaunch);
    return isFirst ?? true; // Defaults to true on fresh install
  }

  /// Check if onboarding has been completed or skipped.
  Future<bool> isOnboardingCompleted() async {
    try {
      if (Hive.isBoxOpen(StorageKeys.appSettingsBox)) {
        final box = Hive.box(StorageKeys.appSettingsBox);
        final completed = box.get(StorageKeys.onboardingCompleted);
        if (completed != null) {
          return completed as bool;
        }
      } else {
        final box = await Hive.openBox(StorageKeys.appSettingsBox);
        final completed = box.get(StorageKeys.onboardingCompleted);
        if (completed != null) {
          return completed as bool;
        }
      }
    } catch (_) {}

    final sp = prefs ?? await SharedPreferences.getInstance();
    return sp.getBool(StorageKeys.onboardingCompleted) ?? false;
  }

  /// Mark onboarding as completed in both Hive and SharedPreferences.
  Future<void> setOnboardingCompleted() async {
    try {
      Box box;
      if (Hive.isBoxOpen(StorageKeys.appSettingsBox)) {
        box = Hive.box(StorageKeys.appSettingsBox);
      } else {
        box = await Hive.openBox(StorageKeys.appSettingsBox);
      }
      await box.put(StorageKeys.onboardingCompleted, true);
      await box.put(StorageKeys.isFirstLaunch, false);
    } catch (_) {}

    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.setBool(StorageKeys.onboardingCompleted, true);
    await sp.setBool(StorageKeys.isFirstLaunch, false);
  }

  /// Reset first launch and onboarding state (useful for tests and debug).
  Future<void> resetFirstLaunch() async {
    try {
      Box box;
      if (Hive.isBoxOpen(StorageKeys.appSettingsBox)) {
        box = Hive.box(StorageKeys.appSettingsBox);
      } else {
        box = await Hive.openBox(StorageKeys.appSettingsBox);
      }
      await box.delete(StorageKeys.onboardingCompleted);
      await box.delete(StorageKeys.isFirstLaunch);
    } catch (_) {}

    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.remove(StorageKeys.onboardingCompleted);
    await sp.remove(StorageKeys.isFirstLaunch);
  }
}
