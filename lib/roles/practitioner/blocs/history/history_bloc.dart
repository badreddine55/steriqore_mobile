import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/usage_model.dart';
import '../../offline/sync_service.dart';
import '../../repositories/usage_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final UsageRepository _usageRepository;
  final SyncService _syncService;

  HistoryBloc({
    UsageRepository? usageRepository,
    SyncService? syncService,
  })  : _usageRepository = usageRepository ?? UsageRepository(),
        _syncService = syncService ?? SyncService(),
        super(const HistoryInitial()) {
    on<LoadUsageHistory>(_onLoadHistory);
    on<FilterHistoryByDate>(_onFilterByDate);
    on<FilterHistoryByPatient>(_onFilterByPatient);
    on<SearchHistory>(_onSearch);
    on<RetrySyncItem>(_onRetrySyncItem);
  }

  Future<void> _onLoadHistory(
    LoadUsageHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    try {
      final usages = await _usageRepository.getUsageHistory();
      final pendingCount = usages.where((u) => u.syncStatus != SyncStatus.synced).length;

      emit(HistoryLoaded(
        allUsages: usages,
        filteredUsages: usages,
        pendingSyncCount: pendingCount,
      ));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  void _onFilterByDate(FilterHistoryByDate event, Emitter<HistoryState> emit) {
    if (state is! HistoryLoaded) return;
    final curr = state as HistoryLoaded;

    final from = event.from;
    final to = event.to;

    final filtered = _applyFilters(
      curr.allUsages,
      from: from,
      to: to,
      patientId: curr.selectedPatientId,
      query: curr.searchQuery,
    );

    emit(curr.copyWith(
      fromDate: from,
      clearFromDate: from == null,
      toDate: to,
      clearToDate: to == null,
      filteredUsages: filtered,
    ));
  }

  void _onFilterByPatient(FilterHistoryByPatient event, Emitter<HistoryState> emit) {
    if (state is! HistoryLoaded) return;
    final curr = state as HistoryLoaded;

    final filtered = _applyFilters(
      curr.allUsages,
      from: curr.fromDate,
      to: curr.toDate,
      patientId: event.patientId,
      query: curr.searchQuery,
    );

    emit(curr.copyWith(
      selectedPatientId: event.patientId,
      clearPatientId: event.patientId == null,
      filteredUsages: filtered,
    ));
  }

  void _onSearch(SearchHistory event, Emitter<HistoryState> emit) {
    if (state is! HistoryLoaded) return;
    final curr = state as HistoryLoaded;

    final query = event.query.trim();

    final filtered = _applyFilters(
      curr.allUsages,
      from: curr.fromDate,
      to: curr.toDate,
      patientId: curr.selectedPatientId,
      query: query,
    );

    emit(curr.copyWith(
      searchQuery: query,
      filteredUsages: filtered,
    ));
  }

  Future<void> _onRetrySyncItem(RetrySyncItem event, Emitter<HistoryState> emit) async {
    await _syncService.syncNow();
    add(const LoadUsageHistory());
  }

  List<UsageModel> _applyFilters(
    List<UsageModel> source, {
    DateTime? from,
    DateTime? to,
    int? patientId,
    String query = '',
  }) {
    return source.where((item) {
      if (patientId != null && item.patientId != patientId) {
        return false;
      }
      if (from != null && item.usedAt.isBefore(from)) {
        return false;
      }
      if (to != null && item.usedAt.isAfter(to.add(const Duration(days: 1)))) {
        return false;
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = item.productName.toLowerCase().contains(q) ||
            item.lotNumber.toLowerCase().contains(q) ||
            item.labelCode.toLowerCase().contains(q) ||
            item.patientName.toLowerCase().contains(q) ||
            (item.patientIdentifier?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }
}
