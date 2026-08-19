import 'package:equatable/equatable.dart';
import '../../domain/entities/instrument_usage.dart';
import '../../domain/entities/patient.dart';

enum UsageFormStatus {
  initial,
  loadingPatients,
  patientsLoaded,
  submitting,
  success,
  blocked,
  alreadyUsed,
  failure,
}

class UsageState extends Equatable {
  final UsageFormStatus status;
  final List<Patient> patients;
  final Patient? selectedPatient;
  final String notes;
  final String procedureType;
  final InstrumentUsage? recordedUsage;
  final String? errorMessage;
  final bool isOfflineQueued;

  const UsageState({
    this.status = UsageFormStatus.initial,
    this.patients = const [],
    this.selectedPatient,
    this.notes = '',
    this.procedureType = 'Dental Implant / Care',
    this.recordedUsage,
    this.errorMessage,
    this.isOfflineQueued = false,
  });

  bool get canSubmit =>
      selectedPatient != null &&
      status != UsageFormStatus.submitting &&
      status != UsageFormStatus.blocked;

  UsageState copyWith({
    UsageFormStatus? status,
    List<Patient>? patients,
    Patient? selectedPatient,
    bool clearPatient = false,
    String? notes,
    String? procedureType,
    InstrumentUsage? recordedUsage,
    String? errorMessage,
    bool clearError = false,
    bool? isOfflineQueued,
  }) {
    return UsageState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      selectedPatient: clearPatient ? null : (selectedPatient ?? this.selectedPatient),
      notes: notes ?? this.notes,
      procedureType: procedureType ?? this.procedureType,
      recordedUsage: recordedUsage ?? this.recordedUsage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOfflineQueued: isOfflineQueued ?? this.isOfflineQueued,
    );
  }

  @override
  List<Object?> get props => [
        status,
        patients,
        selectedPatient,
        notes,
        procedureType,
        recordedUsage,
        errorMessage,
        isOfflineQueued,
      ];
}
