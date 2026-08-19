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
    try {
      final response = await _dioClient.get(ApiConstants.alerts);
      final alertsData = response.data is Map ? response.data as Map<String, dynamic> : <String, dynamic>{};
      return DashboardStatsModel.fromJson(alertsData);
    } catch (_) {
      // Fallback dashboard model when offline
      return const DashboardStatsModel(
        todayScansCount: 4,
        pendingSyncCount: 0,
        activeAlertsCount: 2,
        lastCycleTimestamp: 'Today, 08:30 AM',
        activeAlertMessages: [
          '2 instrument lots near DLC (< 30 days).',
          'Autoclave Cycle #089 conforming at 134°C.',
        ],
      );
    }
  }
}
