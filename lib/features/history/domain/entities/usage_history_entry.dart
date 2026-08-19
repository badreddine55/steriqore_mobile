import 'package:equatable/equatable.dart';
import '../../../../features/usage/domain/entities/instrument_usage.dart';

class UsageHistoryEntry extends Equatable {
  final String id;
  final String idempotencyKey;
  final String labelCode;
  final String productName;
  final String lotNumber;
  final String patientName;
  final String dossierId;
  final DateTime usedAt;
  final UsageSyncStatus syncStatus;
  final String? procedureType;
  final String? notes;

  const UsageHistoryEntry({
    required this.id,
    required this.idempotencyKey,
    required this.labelCode,
    required this.productName,
    required this.lotNumber,
    required this.patientName,
    required this.dossierId,
    required this.usedAt,
    this.syncStatus = UsageSyncStatus.synced,
    this.procedureType,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        idempotencyKey,
        labelCode,
        productName,
        lotNumber,
        patientName,
        dossierId,
        usedAt,
        syncStatus,
        procedureType,
        notes,
      ];
}
