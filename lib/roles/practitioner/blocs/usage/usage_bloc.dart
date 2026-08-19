import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/usage_model.dart';
import '../../repositories/practitioner_exceptions.dart';
import '../../repositories/usage_repository.dart';
import 'usage_event.dart';
import 'usage_state.dart';

class UsageBloc extends Bloc<UsageEvent, UsageState> {
  final UsageRepository _usageRepository;

  UsageBloc({UsageRepository? usageRepository})
      : _usageRepository = usageRepository ?? UsageRepository(),
        super(const UsageState()) {
    on<UsagePatientSelected>(_onPatientSelected);
    on<UsagePatientCleared>(_onPatientCleared);
    on<UsageNotesChanged>(_onNotesChanged);
    on<UsageProcedureTypeChanged>(_onProcedureTypeChanged);
    on<UsageSubmitted>(_onSubmitted);
  }

  void _onPatientSelected(UsagePatientSelected event, Emitter<UsageState> emit) {
    emit(state.copyWith(
      selectedPatient: event.patient,
      clearErrorMessage: true,
      fieldErrors: {},
    ));
  }

  void _onPatientCleared(UsagePatientCleared event, Emitter<UsageState> emit) {
    emit(state.copyWith(clearPatient: true));
  }

  void _onNotesChanged(UsageNotesChanged event, Emitter<UsageState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onProcedureTypeChanged(UsageProcedureTypeChanged event, Emitter<UsageState> emit) {
    emit(state.copyWith(procedureType: event.procedureType));
  }

  Future<void> _onSubmitted(UsageSubmitted event, Emitter<UsageState> emit) async {
    final patient = state.selectedPatient;
    if (patient == null) {
      emit(state.copyWith(
        status: UsageFormStatus.validationError,
        errorMessage: 'A patient must be selected to record clinical traceability.',
        fieldErrors: {
          'patient_id': ['Patient selection is required.'],
        },
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

    emit(state.copyWith(status: UsageFormStatus.submitting, clearErrorMessage: true));

    try {
      final usage = await _usageRepository.recordUsage(
        label: event.label,
        patient: patient,
        notes: state.notes.isNotEmpty ? state.notes : null,
        procedureType: state.procedureType.isNotEmpty ? state.procedureType : null,
      );

      final isOffline = usage.syncStatus == SyncStatus.pending;

      emit(state.copyWith(
        status: UsageFormStatus.success,
        recordedUsage: usage,
        isOfflineQueued: isOffline,
      ));
    } on LabelBlockedException catch (e) {
      emit(state.copyWith(
        status: UsageFormStatus.blocked,
        errorMessage: e.reason,
      ));
    } on UsageAlreadyRecordedException catch (e) {
      emit(state.copyWith(
        status: UsageFormStatus.alreadyUsed,
        errorMessage: e.message,
      ));
    } on PractitionerValidationException catch (e) {
      emit(state.copyWith(
        status: UsageFormStatus.validationError,
        errorMessage: e.firstError,
        fieldErrors: e.errors,
      ));
    } on TokenExpiredException {
      emit(state.copyWith(
        status: UsageFormStatus.failure,
        errorMessage: 'Session expired. Please re-authenticate.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UsageFormStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
