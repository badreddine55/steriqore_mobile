import 'package:equatable/equatable.dart';
import '../../models/patient_model.dart';
import '../../models/usage_model.dart';

enum UsageFormStatus {
  initial,
  submitting,
  success,
  blocked,
  alreadyUsed,
  validationError,
  failure,
}

class UsageState extends Equatable {
  final UsageFormStatus status;
  final PatientModel? selectedPatient;
  final String notes;
  final String procedureType;
  final UsageModel? recordedUsage;
  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;
  final bool isOfflineQueued;

  const UsageState({
    this.status = UsageFormStatus.initial,
    this.selectedPatient,
    this.notes = '',
    this.procedureType = 'Dental Procedure',
    this.recordedUsage,
    this.errorMessage,
    this.fieldErrors = const {},
    this.isOfflineQueued = false,
  });

  bool get canSubmit =>
      selectedPatient != null &&
      status != UsageFormStatus.submitting &&
      status != UsageFormStatus.blocked;

  UsageState copyWith({
    UsageFormStatus? status,
    PatientModel? selectedPatient,
    bool clearPatient = false,
    String? notes,
    String? procedureType,
    UsageModel? recordedUsage,
    String? errorMessage,
    bool clearErrorMessage = false,
    Map<String, List<String>>? fieldErrors,
    bool? isOfflineQueued,
  }) {
    return UsageState(
      status: status ?? this.status,
      selectedPatient: clearPatient ? null : (selectedPatient ?? this.selectedPatient),
      notes: notes ?? this.notes,
      procedureType: procedureType ?? this.procedureType,
      recordedUsage: recordedUsage ?? this.recordedUsage,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isOfflineQueued: isOfflineQueued ?? this.isOfflineQueued,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedPatient,
        notes,
        procedureType,
        recordedUsage,
        errorMessage,
        fieldErrors,
        isOfflineQueued,
      ];
}
