import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/instrument_usage.dart';
import '../../domain/usecases/get_patients.dart';
import '../../domain/usecases/record_usage.dart';
import 'usage_event.dart';
import 'usage_state.dart';

class UsageBloc extends Bloc<UsageEvent, UsageState> {
  final GetPatientsUseCase getPatientsUseCase;
  final RecordUsageUseCase recordUsageUseCase;

  UsageBloc({
    required this.getPatientsUseCase,
    required this.recordUsageUseCase,
  }) : super(const UsageState()) {
    on<UsageLoadPatientsRequested>(_onLoadPatients);
    on<UsagePatientSelectedEvent>(_onPatientSelected);
    on<UsagePatientClearedEvent>(_onPatientCleared);
    on<UsageNotesChangedEvent>(_onNotesChanged);
    on<UsageProcedureChangedEvent>(_onProcedureChanged);
    on<UsageSubmitRequested>(_onSubmit);
  }

  Future<void> _onLoadPatients(
    UsageLoadPatientsRequested event,
    Emitter<UsageState> emit,
  ) async {
    emit(state.copyWith(status: UsageFormStatus.loadingPatients));

    final result = await getPatientsUseCase(GetPatientsParams(query: event.query));
    result.fold(
      (failure) => emit(state.copyWith(
        status: UsageFormStatus.patientsLoaded,
        errorMessage: failure.message,
      )),
      (patients) => emit(state.copyWith(
        status: UsageFormStatus.patientsLoaded,
        patients: patients,
      )),
    );
  }

  void _onPatientSelected(UsagePatientSelectedEvent event, Emitter<UsageState> emit) {
    emit(state.copyWith(selectedPatient: event.patient, clearError: true));
  }

  void _onPatientCleared(UsagePatientClearedEvent event, Emitter<UsageState> emit) {
    emit(state.copyWith(clearPatient: true));
  }

  void _onNotesChanged(UsageNotesChangedEvent event, Emitter<UsageState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onProcedureChanged(UsageProcedureChangedEvent event, Emitter<UsageState> emit) {
    emit(state.copyWith(procedureType: event.procedure));
  }

  Future<void> _onSubmit(UsageSubmitRequested event, Emitter<UsageState> emit) async {
    final patient = state.selectedPatient;
    if (patient == null) {
      emit(state.copyWith(
        status: UsageFormStatus.failure,
        errorMessage: 'A patient must be selected to record clinical traceability.',
      ));
      return;
    }

    if (event.label.isBlocked) {
      emit(state.copyWith(
        status: UsageFormStatus.blocked,
        errorMessage: 'SAFETY BLOCK: Cannot record usage of an expired or recalled instrument.',
      ));
      return;
    }

    emit(state.copyWith(status: UsageFormStatus.submitting, clearError: true));

    final result = await recordUsageUseCase(RecordUsageParams(
      label: event.label,
      patient: patient,
      practitionerId: event.practitionerId,
      practitionerName: event.practitionerName,
      procedureType: state.procedureType.isNotEmpty ? state.procedureType : null,
      notes: state.notes.isNotEmpty ? state.notes : null,
    ));

    result.fold(
      (failure) {
        if (failure is BlockingFailure) {
          emit(state.copyWith(
            status: UsageFormStatus.blocked,
            errorMessage: failure.message,
          ));
        } else {
          emit(state.copyWith(
            status: UsageFormStatus.failure,
            errorMessage: failure.message,
          ));
        }
      },
      (usage) {
        final isOffline = usage.syncStatus == UsageSyncStatus.pending;
        emit(state.copyWith(
          status: UsageFormStatus.success,
          recordedUsage: usage,
          isOfflineQueued: isOffline,
        ));
      },
    );
  }
}
