import 'package:equatable/equatable.dart';
import '../../../scanner/domain/entities/label.dart';
import '../../domain/entities/patient.dart';

abstract class UsageEvent extends Equatable {
  const UsageEvent();

  @override
  List<Object?> get props => [];
}

class UsageLoadPatientsRequested extends UsageEvent {
  final String? query;

  const UsageLoadPatientsRequested({this.query});

  @override
  List<Object?> get props => [query];
}

class UsagePatientSelectedEvent extends UsageEvent {
  final Patient patient;

  const UsagePatientSelectedEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}

class UsagePatientClearedEvent extends UsageEvent {
  const UsagePatientClearedEvent();
}

class UsageNotesChangedEvent extends UsageEvent {
  final String notes;

  const UsageNotesChangedEvent(this.notes);

  @override
  List<Object?> get props => [notes];
}

class UsageProcedureChangedEvent extends UsageEvent {
  final String procedure;

  const UsageProcedureChangedEvent(this.procedure);

  @override
  List<Object?> get props => [procedure];
}

class UsageSubmitRequested extends UsageEvent {
  final Label label;
  final String practitionerId;
  final String practitionerName;

  const UsageSubmitRequested({
    required this.label,
    required this.practitionerId,
    required this.practitionerName,
  });

  @override
  List<Object?> get props => [label, practitionerId, practitionerName];
}
