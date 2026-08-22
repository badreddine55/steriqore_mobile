import 'package:equatable/equatable.dart';

abstract class AdminAuditEvent extends Equatable {
  const AdminAuditEvent();

  @override
  List<Object?> get props => [];
}

class AdminLoadAuditRequested extends AdminAuditEvent {
  final String? search;
  final String? action;
  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const AdminLoadAuditRequested({
    this.search,
    this.action,
    this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [search, action, userId, startDate, endDate];
}

class AdminRefreshAuditRequested extends AdminAuditEvent {
  const AdminRefreshAuditRequested();
}

class AdminAuditSearchChanged extends AdminAuditEvent {
  final String query;
  const AdminAuditSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class AdminAuditDateFilterChanged extends AdminAuditEvent {
  final String filter; // 'all', 'today', 'week', 'month'
  const AdminAuditDateFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class AdminAuditActionFilterChanged extends AdminAuditEvent {
  final String action; // 'all', 'RECORD_USAGE', 'VALIDATE_CYCLE', 'CREATE_USER', 'UPDATE_SETTINGS'
  const AdminAuditActionFilterChanged(this.action);

  @override
  List<Object?> get props => [action];
}
