import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/usage/domain/entities/instrument_usage.dart';
import '../../domain/entities/usage_history_entry.dart';
import '../../domain/usecases/get_practitioner_history.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetPractitionerHistoryUseCase getPractitionerHistoryUseCase;

  HistoryBloc({
    required this.getPractitionerHistoryUseCase,
  }) : super(const HistoryState()) {
    on<HistoryLoadRequested>(_onLoad);
    on<HistoryRefreshRequested>(_onRefresh);
    on<HistoryFilterChangedEvent>(_onFilterChanged);
  }

  Future<void> _onLoad(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    final result = await getPractitionerHistoryUseCase(
      GetPractitionerHistoryParams(
        search: event.query ?? state.searchQuery,
        filterDate: event.filter ?? state.activeFilter,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.error,
        errorMessage: failure.message,
      )),
      (items) {
        final filtered = _applyFilter(items, event.filter ?? state.activeFilter);
        emit(state.copyWith(
          status: HistoryStatus.loaded,
          items: filtered,
          activeFilter: event.filter ?? state.activeFilter,
          searchQuery: event.query ?? state.searchQuery,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    HistoryRefreshRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await getPractitionerHistoryUseCase(
      GetPractitionerHistoryParams(
        search: state.searchQuery,
        filterDate: state.activeFilter,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.error,
        errorMessage: failure.message,
      )),
      (items) {
        final filtered = _applyFilter(items, state.activeFilter);
        emit(state.copyWith(
          status: HistoryStatus.loaded,
          items: filtered,
        ));
      },
    );
  }

  void _onFilterChanged(
    HistoryFilterChangedEvent event,
    Emitter<HistoryState> emit,
  ) {
    add(HistoryLoadRequested(filter: event.filter));
  }

  List<UsageHistoryEntry> _applyFilter(List<UsageHistoryEntry> items, String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (filter == 'today') {
      return items.where((item) {
        final d = DateTime(item.usedAt.year, item.usedAt.month, item.usedAt.day);
        return d.isAtSameMomentAs(today);
      }).toList();
    } else if (filter == 'week') {
      final weekAgo = today.subtract(const Duration(days: 7));
      return items.where((item) => item.usedAt.isAfter(weekAgo)).toList();
    } else if (filter == 'pending') {
      return items.where((item) => item.syncStatus == UsageSyncStatus.pending).toList();
    }
    return items;
  }
}
