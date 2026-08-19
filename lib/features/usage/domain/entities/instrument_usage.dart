import 'package:equatable/equatable.dart';

enum UsageSyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

class InstrumentUsage extends Equatable {
  final String id;
  final String idempotencyKey;
  final String labelId;
  final String labelCode;
  final String productName;
  final String lotNumber;
  final String patientId;
  final String patientName;
  final String? dossierId;
  final List<String> patientAllergies;
  final String practitionerId;
  final String practitionerName;
  final DateTime usedAt;
  final UsageSyncStatus syncStatus;
  final String? errorMessage;
  final String? procedureType;
  final String? notes;

  const InstrumentUsage({
    required this.id,
    required this.idempotencyKey,
    required this.labelId,
    required this.labelCode,
    required this.productName,
    required this.lotNumber,
    required this.patientId,
    required this.patientName,
    this.dossierId,
    this.patientAllergies = const [],
    required this.practitionerId,
    required this.practitionerName,
    required this.usedAt,
    this.syncStatus = UsageSyncStatus.synced,
    this.errorMessage,
    this.procedureType,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        idempotencyKey,
        labelId,
        labelCode,
        productName,
        lotNumber,
        patientId,
        patientName,
        dossierId,
        patientAllergies,
        practitionerId,
        practitionerName,
        usedAt,
        syncStatus,
        errorMessage,
        procedureType,
        notes,
      ];
}
