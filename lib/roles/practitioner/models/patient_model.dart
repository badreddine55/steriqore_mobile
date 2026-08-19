import 'package:flutter/foundation.dart';

/// Represents a clinic patient eligible to have sterilized instrument usage recorded
@immutable
class PatientModel {
  final int id;
  final String identifier; // Medical record / Chart number / Dossier ID
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? phone;
  final String? email;
  final List<String> allergies;
  final String? medicalAlert;
  final String? cabinetRoom;

  const PatientModel({
    required this.id,
    required this.identifier,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.phone,
    this.email,
    this.allergies = const [],
    this.medicalAlert,
    this.cabinetRoom,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get formattedDisplay => '$fullName ($identifier)';

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final rawAllergies = json['allergies'];
    List<String> parsedAllergies = [];
    if (rawAllergies is List) {
      parsedAllergies = rawAllergies.map((e) => e.toString()).toList();
    } else if (rawAllergies is String && rawAllergies.isNotEmpty) {
      parsedAllergies = rawAllergies.split(',').map((e) => e.trim()).toList();
    }

    return PatientModel(
      id: json['id'] as int? ?? 0,
      identifier: json['identifier'] as String? ??
          json['file_number'] as String? ??
          json['chart_number'] as String? ??
          'PAT-${json['id'] ?? 0}',
      firstName: json['first_name'] as String? ?? json['name'] as String? ?? 'Patient',
      lastName: json['last_name'] as String? ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'].toString())
          : (json['dob'] != null ? DateTime.tryParse(json['dob'].toString()) : null),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      allergies: parsedAllergies,
      medicalAlert: json['medical_alert'] as String? ?? json['notes'] as String?,
      cabinetRoom: json['cabinet_room'] as String? ?? json['room'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifier': identifier,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'phone': phone,
      'email': email,
      'allergies': allergies,
      'medical_alert': medicalAlert,
      'cabinet_room': cabinetRoom,
    };
  }
}
