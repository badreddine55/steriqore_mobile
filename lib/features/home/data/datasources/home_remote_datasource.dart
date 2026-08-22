import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_stats_model.dart';

abstract class HomeRemoteDataSource {
  Future<DashboardStatsModel> getStats();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl([DioClient? dioClient])
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<DashboardStatsModel> getStats() async {
    int todayScans = 0;
    int pendingSync = 0;
    int activeAlertsCount = 0;
    String lastCycleTimestamp = 'N/A';
    List<String> activeAlertMessages = [];

    // 1. Fetch live alerts from API
    try {
      final alertsRes = await _dioClient.get(ApiConstants.alerts);
      final dynamic aData = alertsRes.data;
      List<dynamic> aList = [];
      if (aData is List) {
        aList = aData;
      } else if (aData is Map && aData.containsKey('data') && aData['data'] is List) {
        aList = aData['data'] as List;
      }

      activeAlertsCount = aList.length;
      activeAlertMessages = aList.map((item) {
        if (item is Map) {
          return (item['title'] ?? item['message'] ?? item['description'] ?? 'Sterilization Alert').toString();
        }
        return item.toString();
      }).toList();
    } catch (_) {}

    // 2. Fetch live usages from API to calculate today's scans count
    try {
      final usagesRes = await _dioClient.get(ApiConstants.usages);
      final dynamic uData = usagesRes.data;
      List<dynamic> uList = [];
      if (uData is List) {
        uList = uData;
      } else if (uData is Map && uData.containsKey('data') && uData['data'] is List) {
        uList = uData['data'] as List;
      }

      final now = DateTime.now();
      todayScans = uList.where((item) {
        if (item is Map) {
          final dateStr = item['used_at'] ?? item['created_at'];
          if (dateStr != null) {
            final dt = DateTime.tryParse(dateStr.toString());
            if (dt != null) {
              return dt.year == now.year && dt.month == now.month && dt.day == now.day;
            }
          }
        }
        return false;
      }).length;

      if (uList.isNotEmpty) {
        final first = uList.first;
        if (first is Map && (first['used_at'] != null || first['created_at'] != null)) {
          lastCycleTimestamp = (first['used_at'] ?? first['created_at']).toString();
        }
      }
    } catch (_) {}

    // 3. Check latest cycle for lastCycleTimestamp if not found
    if (lastCycleTimestamp == 'N/A') {
      try {
        final cyclesRes = await _dioClient.get(ApiConstants.cycles);
        final dynamic cData = cyclesRes.data;
        List<dynamic> cList = [];
        if (cData is List) {
          cList = cData;
        } else if (cData is Map && cData.containsKey('data') && cData['data'] is List) {
          cList = cData['data'] as List;
        }
        if (cList.isNotEmpty && cList.first is Map) {
          final c = cList.first as Map;
          lastCycleTimestamp = (c['sterilized_at'] ?? c['created_at'] ?? c['started_at'] ?? 'Validated').toString();
        }
      } catch (_) {}
    }

    return DashboardStatsModel(
      todayScansCount: todayScans,
      pendingSyncCount: pendingSync,
      activeAlertsCount: activeAlertsCount,
      lastCycleTimestamp: lastCycleTimestamp,
      activeAlertMessages: activeAlertMessages,
    );
  }
}
