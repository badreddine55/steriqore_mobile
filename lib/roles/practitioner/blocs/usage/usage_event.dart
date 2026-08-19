import 'package:equatable/equatable.dart';
import '../../models/label_model.dart';
import '../../models/patient_model.dart';

abstract class UsageEvent extends Equatable {
  const UsageEvent();

  @override
  List<Object?> get props => [];
}

class UsagePatientSelected extends UsageEvent {
  final PatientModel patient;
  const UsagePatientSelected(this.patient);

  @override
  List<Object?> get props => [patient];
}

class UsagePatientCleared extends UsageEvent {
  const UsagePatientCleared();
}

class UsageNotesChanged extends UsageEvent {
  final String notes;
  const UsageNotesChanged(this.notes);

  @override
  List<Object?> get props => [notes];
}

class UsageProcedureTypeChanged extends UsageEvent {
  final String procedureType;
  const UsageProcedureTypeChanged(this.procedureType);

  @override
  List<Object?> get props => [procedureType];
}

class UsageSubmitted extends UsageEvent {
  final LabelModel label;
  const UsageSubmitted({required this.label});

  @override
  List<Object?> get props => [label];
}
