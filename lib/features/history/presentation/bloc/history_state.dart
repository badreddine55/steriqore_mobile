import 'package:equatable/equatable.dart';
import '../../domain/entities/usage_history_entry.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<UsageHistoryEntry> items;
  final String activeFilter; // 'all', 'today', 'week', 'pending'
  final String searchQuery;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const [],
    this.activeFilter = 'all',
    this.searchQuery = '',
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<UsageHistoryEntry>? items,
    String? activeFilter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, activeFilter, searchQuery, errorMessage];
}
