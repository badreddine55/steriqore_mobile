import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/label_model.dart';

abstract class ScannerLocalDataSource {
  Future<void> cacheLabel(LabelModel label);
  Future<LabelModel?> getCachedLabel(String code);
  Future<List<String>> getRecentCodes();
  Future<void> saveRecentCode(String code);
}

class ScannerLocalDataSourceImpl implements ScannerLocalDataSource {
  final SharedPreferences? _prefs;

  ScannerLocalDataSourceImpl([this._prefs]);

  @override
  Future<void> cacheLabel(LabelModel label) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('label_${label.code}', jsonEncode(label.toJson()));
  }

  @override
  Future<LabelModel?> getCachedLabel(String code) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final str = prefs.getString('label_$code');
    if (str != null && str.isNotEmpty) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return LabelModel.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<List<String>> getRecentCodes() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getStringList(StorageKeys.recentCodes) ?? [];
  }

  @override
  Future<void> saveRecentCode(String code) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final list = prefs.getStringList(StorageKeys.recentCodes) ?? [];
    list.remove(code);
    list.insert(0, code);
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    await prefs.setStringList(StorageKeys.recentCodes, list);
  }
}
