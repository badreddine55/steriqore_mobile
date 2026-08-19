import 'package:equatable/equatable.dart';
import '../../models/usage_model.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<UsageModel> allUsages;
  final List<UsageModel> filteredUsages;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? selectedPatientId;
  final String searchQuery;
  final int pendingSyncCount;

  const HistoryLoaded({
    required this.allUsages,
    required this.filteredUsages,
    this.fromDate,
    this.toDate,
    this.selectedPatientId,
    this.searchQuery = '',
    this.pendingSyncCount = 0,
  });

  HistoryLoaded copyWith({
    List<UsageModel>? allUsages,
    List<UsageModel>? filteredUsages,
    DateTime? fromDate,
    bool clearFromDate = false,
    DateTime? toDate,
    bool clearToDate = false,
    int? selectedPatientId,
    bool clearPatientId = false,
    String? searchQuery,
    int? pendingSyncCount,
  }) {
    return HistoryLoaded(
      allUsages: allUsages ?? this.allUsages,
      filteredUsages: filteredUsages ?? this.filteredUsages,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      selectedPatientId: clearPatientId ? null : (selectedPatientId ?? this.selectedPatientId),
      searchQuery: searchQuery ?? this.searchQuery,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }

  @override
  List<Object?> get props => [
        allUsages,
        filteredUsages,
        fromDate,
        toDate,
        selectedPatientId,
        searchQuery,
        pendingSyncCount,
      ];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
