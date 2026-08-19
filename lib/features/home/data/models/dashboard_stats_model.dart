import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.todayScansCount,
    required super.pendingSyncCount,
    required super.activeAlertsCount,
    super.lastCycleTimestamp,
    super.activeAlertMessages = const [],
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json, {int pendingLocal = 0}) {
    final alertsList = (json['alerts'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return DashboardStatsModel(
      todayScansCount: json['today_scans'] as int? ?? json['scans_count'] as int? ?? 0,
      pendingSyncCount: pendingLocal,
      activeAlertsCount: json['active_alerts_count'] as int? ?? alertsList.length,
      lastCycleTimestamp: json['last_cycle_at'] as String? ?? 'Today, 08:30',
      activeAlertMessages: alertsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_scans': todayScansCount,
      'pending_sync': pendingSyncCount,
      'active_alerts_count': activeAlertsCount,
      'last_cycle_at': lastCycleTimestamp,
      'alerts': activeAlertMessages,
    };
  }
}
