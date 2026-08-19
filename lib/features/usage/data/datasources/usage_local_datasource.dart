import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../domain/entities/instrument_usage.dart';
import '../models/patient_model.dart';
import '../models/usage_response_model.dart';

abstract class UsageLocalDataSource {
  Future<void> addToPendingQueue(UsageResponseModel usage);
  Future<List<UsageResponseModel>> getPendingQueue();
  Future<List<UsageResponseModel>> getAllHistory();
  Future<void> updateUsage(UsageResponseModel usage);
  Future<void> cachePatients(List<PatientModel> patients);
  Future<List<PatientModel>> getCachedPatients();
}

class UsageLocalDataSourceImpl implements UsageLocalDataSource {
  final SharedPreferences? _prefs;

  UsageLocalDataSourceImpl([this._prefs]);

  @override
  Future<void> addToPendingQueue(UsageResponseModel usage) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final list = await getAllHistory();
    list.removeWhere((item) => item.idempotencyKey == usage.idempotencyKey);
    list.insert(0, usage);
    await _saveList(prefs, list);
  }

  @override
  Future<List<UsageResponseModel>> getPendingQueue() async {
    final all = await getAllHistory();
    return all.where((u) => u.syncStatus == UsageSyncStatus.pending || u.syncStatus == UsageSyncStatus.failed).toList();
  }

  @override
  Future<List<UsageResponseModel>> getAllHistory() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final rawJson = prefs.getString(StorageKeys.cachedHistoryBox);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final list = jsonDecode(rawJson) as List;
        return list.map((e) => UsageResponseModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<void> updateUsage(UsageResponseModel usage) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final list = await getAllHistory();
    final index = list.indexWhere((u) => u.idempotencyKey == usage.idempotencyKey);
    if (index != -1) {
      list[index] = usage;
    } else {
      list.insert(0, usage);
    }
    await _saveList(prefs, list);
  }

  Future<void> _saveList(SharedPreferences prefs, List<UsageResponseModel> list) async {
    final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(StorageKeys.cachedHistoryBox, jsonStr);
  }

  @override
  Future<void> cachePatients(List<PatientModel> patients) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(patients.map((p) => p.toJson()).toList());
    await prefs.setString(StorageKeys.cachedPatientsBox, jsonStr);
  }

  @override
  Future<List<PatientModel>> getCachedPatients() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final rawJson = prefs.getString(StorageKeys.cachedPatientsBox);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final list = jsonDecode(rawJson) as List;
        return list.map((e) => PatientModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }
}
