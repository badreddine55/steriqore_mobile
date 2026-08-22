import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_audit_trail.dart';
import 'admin_audit_event.dart';
import 'admin_audit_state.dart';

class AdminAuditBloc extends Bloc<AdminAuditEvent, AdminAuditState> {
  final GetAuditTrailUseCase getAuditTrailUseCase;

  AdminAuditBloc({required this.getAuditTrailUseCase}) : super(const AdminAuditState()) {
    on<AdminLoadAuditRequested>(_onLoadAudit);
    on<AdminRefreshAuditRequested>(_onRefreshAudit);
    on<AdminAuditSearchChanged>(_onSearchChanged);
    on<AdminAuditDateFilterChanged>(_onDateFilterChanged);
    on<AdminAuditActionFilterChanged>(_onActionFilterChanged);
  }

  Future<void> _onLoadAudit(
    AdminLoadAuditRequested event,
    Emitter<AdminAuditState> emit,
  ) async {
    emit(state.copyWith(status: AdminAuditStatus.loading));

    final result = await getAuditTrailUseCase(GetAuditTrailParams(
      search: event.search ?? (state.searchQuery.isNotEmpty ? state.searchQuery : null),
      action: event.action ?? (state.activeActionFilter != 'all' ? state.activeActionFilter : null),
      userId: event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminAuditStatus.error,
        errorMessage: failure.message,
      )),
      (entries) => emit(state.copyWith(
        status: AdminAuditStatus.loaded,
        entries: entries,
      )),
    );
  }

  Future<void> _onRefreshAudit(
    AdminRefreshAuditRequested event,
    Emitter<AdminAuditState> emit,
  ) async {
    final result = await getAuditTrailUseCase(GetAuditTrailParams(
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      action: state.activeActionFilter != 'all' ? state.activeActionFilter : null,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminAuditStatus.error,
        errorMessage: failure.message,
      )),
      (entries) => emit(state.copyWith(
        status: AdminAuditStatus.loaded,
        entries: entries,
      )),
    );
  }

  void _onSearchChanged(
    AdminAuditSearchChanged event,
    Emitter<AdminAuditState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onDateFilterChanged(
    AdminAuditDateFilterChanged event,
    Emitter<AdminAuditState> emit,
  ) {
    emit(state.copyWith(activeDateFilter: event.filter));
  }

  void _onActionFilterChanged(
    AdminAuditActionFilterChanged event,
    Emitter<AdminAuditState> emit,
  ) {
    emit(state.copyWith(activeActionFilter: event.action));
  }
}
