import 'package:equatable/equatable.dart';
import '../../domain/entities/audit_entry.dart';

enum AdminAuditStatus { initial, loading, loaded, error }

class AdminAuditState extends Equatable {
  final AdminAuditStatus status;
  final List<AuditEntry> entries;
  final String searchQuery;
  final String activeDateFilter; // 'all', 'today', 'week', 'month'
  final String activeActionFilter; // 'all', 'RECORD_USAGE', 'VALIDATE_CYCLE', etc.
  final String? errorMessage;

  const AdminAuditState({
    this.status = AdminAuditStatus.initial,
    this.entries = const [],
    this.searchQuery = '',
    this.activeDateFilter = 'all',
    this.activeActionFilter = 'all',
    this.errorMessage,
  });

  AdminAuditState copyWith({
    AdminAuditStatus? status,
    List<AuditEntry>? entries,
    String? searchQuery,
    String? activeDateFilter,
    String? activeActionFilter,
    String? errorMessage,
  }) {
    return AdminAuditState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      activeDateFilter: activeDateFilter ?? this.activeDateFilter,
      activeActionFilter: activeActionFilter ?? this.activeActionFilter,
      errorMessage: errorMessage,
    );
  }

  List<AuditEntry> get filteredEntries {
    final now = DateTime.now();
    return entries.where((e) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final match = e.action.toLowerCase().contains(q) ||
            e.userName.toLowerCase().contains(q) ||
            e.details.toLowerCase().contains(q) ||
            (e.entityId?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (activeActionFilter != 'all') {
        if (e.action.toLowerCase() != activeActionFilter.toLowerCase()) return false;
      }
      if (activeDateFilter == 'today') {
        final startOfToday = DateTime(now.year, now.month, now.day);
        if (e.timestamp.isBefore(startOfToday)) return false;
      } else if (activeDateFilter == 'week') {
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        if (e.timestamp.isBefore(sevenDaysAgo)) return false;
      } else if (activeDateFilter == 'month') {
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        if (e.timestamp.isBefore(thirtyDaysAgo)) return false;
      }
      return true;
    }).toList();
  }

  @override
  List<Object?> get props => [
        status,
        entries,
        searchQuery,
        activeDateFilter,
        activeActionFilter,
        errorMessage,
      ];
}
