import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/label_model.dart';
import '../models/usage_model.dart';

/// Local persistent storage queue for offline scans, usage recordings, and cached labels
class ScanOutbox {
  static const String _outboxKey = 'practitioner_scan_outbox_items';
  static const String _labelCacheKey = 'practitioner_cached_labels';

  /// Fetch all queued usage recordings from local device storage
  static Future<List<UsageModel>> getAllQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_outboxKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => UsageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get only items waiting to be synchronized (pending or failed)
  static Future<List<UsageModel>> getPendingQueue() async {
    final all = await getAllQueue();
    return all.where((item) => item.syncStatus != SyncStatus.synced).toList();
  }

  /// Add a newly created usage record to the offline outbox
  static Future<void> addToQueue(UsageModel usage) async {
    final all = await getAllQueue();
    // Avoid duplicate insertions with same idempotency key
    all.removeWhere((item) => item.idempotencyKey == usage.idempotencyKey);
    all.insert(0, usage);
    await _saveAll(all);
  }

  /// Update an existing item's sync status, server ID, or error message
  static Future<void> updateItem(UsageModel updated) async {
    final all = await getAllQueue();
    final index = all.indexWhere((item) => item.idempotencyKey == updated.idempotencyKey);
    if (index != -1) {
      all[index] = updated;
      await _saveAll(all);
    } else {
      all.insert(0, updated);
      await _saveAll(all);
    }
  }

  /// Remove item from outbox
  static Future<void> removeItem(String idempotencyKey) async {
    final all = await getAllQueue();
    all.removeWhere((item) => item.idempotencyKey == idempotencyKey);
    await _saveAll(all);
  }

  /// Save full list back to persistent storage
  static Future<void> _saveAll(List<UsageModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_outboxKey, raw);
  }

  /// Cache a scanned label locally so offline inspections can immediately check DLC / Recalls
  static Future<void> cacheLabel(LabelModel label) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_labelCacheKey);
      Map<String, dynamic> map = {};
      if (raw != null && raw.isNotEmpty) {
        map = jsonDecode(raw) as Map<String, dynamic>;
      }
      map[label.code.trim()] = label.toJson();
      await prefs.setString(_labelCacheKey, jsonEncode(map));
    } catch (_) {}
  }

  /// Retrieve locally cached label data by barcode / DataMatrix code
  static Future<LabelModel?> getCachedLabel(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_labelCacheKey);
      if (raw == null || raw.isEmpty) return null;

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final labelJson = map[code.trim()];
      if (labelJson != null) {
        return LabelModel.fromJson(labelJson as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
