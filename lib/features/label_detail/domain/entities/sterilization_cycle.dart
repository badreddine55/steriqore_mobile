import 'package:equatable/equatable.dart';

class SterilizationCycle extends Equatable {
  final int id;
  final String cycleNumber;
  final String autoclaveName;
  final String? programName;
  final double temperature;
  final double pressureBar;
  final int durationMinutes;
  final bool isValidated;
  final DateTime sterilizationDate;
  final String operatorName;
  final String? certificateUrl;
  final List<String> attachments;

  const SterilizationCycle({
    required this.id,
    required this.cycleNumber,
    required this.autoclaveName,
    this.programName = 'Prion 134°C - 18min',
    this.temperature = 134.0,
    this.pressureBar = 2.1,
    this.durationMinutes = 18,
    this.isValidated = true,
    required this.sterilizationDate,
    this.operatorName = 'Dr. Practitioner',
    this.certificateUrl,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        cycleNumber,
        autoclaveName,
        programName,
        temperature,
        pressureBar,
        durationMinutes,
        isValidated,
        sterilizationDate,
        operatorName,
        certificateUrl,
        attachments,
      ];
}
