import '../../domain/entities/sterilization_cycle.dart';

class CycleModel extends SterilizationCycle {
  const CycleModel({
    required super.id,
    required super.cycleNumber,
    required super.autoclaveName,
    super.programName = 'Prion 134°C - 18min',
    super.temperature = 134.0,
    super.pressureBar = 2.1,
    super.durationMinutes = 18,
    super.isValidated = true,
    required super.sterilizationDate,
    super.operatorName = 'Dr. Practitioner',
    super.certificateUrl,
    super.attachments = const [],
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String? ?? 'passed').toLowerCase();
    final isValidated = statusStr == 'passed' ||
        statusStr == 'validated' ||
        statusStr == 'conforming' ||
        json['is_validated'] == true;

    DateTime steriDate = DateTime.now().subtract(const Duration(days: 2));
    if (json['sterilization_date'] != null || json['created_at'] != null) {
      try {
        steriDate = DateTime.parse((json['sterilization_date'] ?? json['created_at']).toString());
      } catch (_) {}
    }

    final attachmentsList = (json['attachments'] as List?)
            ?.map((e) => e is Map ? (e['url'] ?? e['name'] ?? '').toString() : e.toString())
            .toList() ??
        [];

    return CycleModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      cycleNumber: json['cycle_number'] as String? ?? json['number'] as String? ?? 'CYC-089',
      autoclaveName: json['autoclave_name'] as String? ?? json['device'] as String? ?? 'Melag Vacuklav 40B',
      programName: json['program_name'] as String? ?? 'Prion 134°C - 18min',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 134.0,
      pressureBar: (json['pressure'] as num?)?.toDouble() ?? 2.1,
      durationMinutes: json['duration_minutes'] as int? ?? 18,
      isValidated: isValidated,
      sterilizationDate: steriDate,
      operatorName: json['operator_name'] as String? ?? 'Dr. Dupont',
      certificateUrl: json['certificate_url'] as String?,
      attachments: attachmentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycle_number': cycleNumber,
      'autoclave_name': autoclaveName,
      'program_name': programName,
      'temperature': temperature,
      'pressure': pressureBar,
      'duration_minutes': durationMinutes,
      'is_validated': isValidated,
      'sterilization_date': sterilizationDate.toIso8601String(),
      'operator_name': operatorName,
      'certificate_url': certificateUrl,
      'attachments': attachments,
    };
  }

  SterilizationCycle toEntity() {
    return SterilizationCycle(
      id: id,
      cycleNumber: cycleNumber,
      autoclaveName: autoclaveName,
      programName: programName,
      temperature: temperature,
      pressureBar: pressureBar,
      durationMinutes: durationMinutes,
      isValidated: isValidated,
      sterilizationDate: sterilizationDate,
      operatorName: operatorName,
      certificateUrl: certificateUrl,
      attachments: attachments,
    );
  }
}
