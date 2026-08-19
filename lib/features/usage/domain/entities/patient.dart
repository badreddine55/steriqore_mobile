import 'package:equatable/equatable.dart';

enum AllergySeverity { severe, moderate, mild }

class PatientAllergy extends Equatable {
  final String name;
  final AllergySeverity severity;

  const PatientAllergy({
    required this.name,
    this.severity = AllergySeverity.moderate,
  });

  @override
  List<Object?> get props => [name, severity];
}

class Patient extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String dossierId;
  final List<PatientAllergy> allergies;
  final String? lastVisit;
  final String? cabinetRoom;

  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dossierId,
    this.allergies = const [],
    this.lastVisit,
    this.cabinetRoom,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        dossierId,
        allergies,
        lastVisit,
        cabinetRoom,
      ];
}
