import '../../domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.dossierId,
    super.allergies = const [],
    super.lastVisit,
    super.cabinetRoom,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final rawAllergies = json['allergies'] as List? ?? [];
    final rawSeverities = json['allergySeverity'] as List? ?? json['allergy_severities'] as List? ?? [];

    final allergiesList = <PatientAllergy>[];
    for (int i = 0; i < rawAllergies.length; i++) {
      final name = rawAllergies[i].toString();
      final severityStr = (i < rawSeverities.length ? rawSeverities[i].toString() : 'moderate').toLowerCase();
      AllergySeverity severity = AllergySeverity.moderate;
      if (severityStr.contains('severe')) {
        severity = AllergySeverity.severe;
      } else if (severityStr.contains('mild')) {
        severity = AllergySeverity.mild;
      }
      allergiesList.add(PatientAllergy(name: name, severity: severity));
    }

    return PatientModel(
      id: json['id']?.toString() ?? 'PAT-001',
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? 'Patient',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      dossierId: json['dossierId'] as String? ?? json['dossier_id'] as String? ?? json['identifier'] as String? ?? 'DOS-2024-001',
      allergies: allergiesList,
      lastVisit: json['lastVisit'] as String? ?? json['last_visit'] as String?,
      cabinetRoom: json['cabinetRoom'] as String? ?? json['cabinet_room'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dossierId': dossierId,
      'allergies': allergies.map((a) => a.name).toList(),
      'allergySeverity': allergies.map((a) => a.severity.name).toList(),
      'lastVisit': lastVisit,
      'cabinetRoom': cabinetRoom,
    };
  }

  Patient toEntity() => Patient(
        id: id,
        firstName: firstName,
        lastName: lastName,
        dossierId: dossierId,
        allergies: allergies,
        lastVisit: lastVisit,
        cabinetRoom: cabinetRoom,
      );
}
