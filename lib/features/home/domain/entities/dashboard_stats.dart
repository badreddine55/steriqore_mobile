import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int todayScansCount;
  final int pendingSyncCount;
  final int activeAlertsCount;
  final String? lastCycleTimestamp;
  final List<String> activeAlertMessages;

  const DashboardStats({
    required this.todayScansCount,
    required this.pendingSyncCount,
    required this.activeAlertsCount,
    this.lastCycleTimestamp,
    this.activeAlertMessages = const [],
  });

  @override
  List<Object?> get props => [
        todayScansCount,
        pendingSyncCount,
        activeAlertsCount,
        lastCycleTimestamp,
        activeAlertMessages,
      ];
}
