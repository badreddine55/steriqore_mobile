import '../../../../features/usage/domain/entities/instrument_usage.dart';
import '../../domain/entities/usage_history_entry.dart';

class UsageHistoryModel extends UsageHistoryEntry {
  const UsageHistoryModel({
    required super.id,
    required super.idempotencyKey,
    required super.labelCode,
    required super.productName,
    required super.lotNumber,
    required super.patientName,
    required super.dossierId,
    required super.usedAt,
    super.syncStatus = UsageSyncStatus.synced,
    super.procedureType,
    super.notes,
  });

  factory UsageHistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime usedDate = DateTime.now();
    if (json['used_at'] != null) {
      try {
        usedDate = DateTime.parse(json['used_at'].toString());
      } catch (_) {}
    }

    final statusStr = (json['sync_status'] as String? ?? 'synced').toLowerCase();
    UsageSyncStatus status = UsageSyncStatus.synced;
    if (statusStr.contains('pending')) {
      status = UsageSyncStatus.pending;
    } else if (statusStr.contains('syncing')) {
      status = UsageSyncStatus.syncing;
    } else if (statusStr.contains('failed')) {
      status = UsageSyncStatus.failed;
    }

    return UsageHistoryModel(
      id: json['id']?.toString() ?? '1',
      idempotencyKey: json['idempotency_key'] as String? ?? 'KEY',
      labelCode: json['label_code'] as String? ?? json['code'] as String? ?? 'LBL-01',
      productName: json['product_name'] as String? ?? json['name'] as String? ?? 'Dental Instrument',
      lotNumber: json['lot_number'] as String? ?? json['lot'] as String? ?? 'LOT-01',
      patientName: json['patient_name'] as String? ?? 'Patient',
      dossierId: json['dossier_id'] as String? ?? 'DOS-2024-001',
      usedAt: usedDate,
      syncStatus: status,
      procedureType: json['procedure_type'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idempotency_key': idempotencyKey,
      'label_code': labelCode,
      'product_name': productName,
      'lot_number': lotNumber,
      'patient_name': patientName,
      'dossier_id': dossierId,
      'used_at': usedAt.toIso8601String(),
      'sync_status': syncStatus.name,
      'procedure_type': procedureType,
      'notes': notes,
    };
  }

  UsageHistoryEntry toEntity() => UsageHistoryEntry(
        id: id,
        idempotencyKey: idempotencyKey,
        labelCode: labelCode,
        productName: productName,
        lotNumber: lotNumber,
        patientName: patientName,
        dossierId: dossierId,
        usedAt: usedAt,
        syncStatus: syncStatus,
        procedureType: procedureType,
        notes: notes,
      );
}
