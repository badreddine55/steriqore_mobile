import '../../domain/entities/instrument_usage.dart';

class UsageResponseModel extends InstrumentUsage {
  const UsageResponseModel({
    required super.id,
    required super.idempotencyKey,
    required super.labelId,
    required super.labelCode,
    required super.productName,
    required super.lotNumber,
    required super.patientId,
    required super.patientName,
    super.dossierId,
    super.patientAllergies = const [],
    required super.practitionerId,
    required super.practitionerName,
    required super.usedAt,
    super.syncStatus = UsageSyncStatus.synced,
    super.errorMessage,
    super.procedureType,
    super.notes,
  });

  factory UsageResponseModel.fromJson(Map<String, dynamic> json) {
    DateTime usedDate = DateTime.now();
    if (json['used_at'] != null) {
      try {
        usedDate = DateTime.parse(json['used_at'].toString());
      } catch (_) {}
    }

    final rawAllergies = json['allergies'] as List? ?? [];
    final allergiesList = rawAllergies.map((e) => e.toString()).toList();

    final statusStr = (json['sync_status'] as String? ?? 'synced').toLowerCase();
    UsageSyncStatus status = UsageSyncStatus.synced;
    if (statusStr.contains('pending')) {
      status = UsageSyncStatus.pending;
    } else if (statusStr.contains('syncing')) {
      status = UsageSyncStatus.syncing;
    } else if (statusStr.contains('failed')) {
      status = UsageSyncStatus.failed;
    }

    return UsageResponseModel(
      id: json['id']?.toString() ?? '1',
      idempotencyKey: json['idempotency_key'] as String? ?? 'UUID-DEFAULT',
      labelId: json['label_id']?.toString() ?? '1',
      labelCode: json['label_code'] as String? ?? json['code'] as String? ?? 'LBL-01',
      productName: json['product_name'] as String? ?? 'Dental Instrument',
      lotNumber: json['lot_number'] as String? ?? 'LOT-01',
      patientId: json['patient_id']?.toString() ?? 'PAT-001',
      patientName: json['patient_name'] as String? ?? 'Patient',
      dossierId: json['dossier_id'] as String?,
      patientAllergies: allergiesList,
      practitionerId: json['practitioner_id']?.toString() ?? '1',
      practitionerName: json['practitioner_name'] as String? ?? 'Dr. Practitioner',
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
      'label_id': labelId,
      'label_code': labelCode,
      'product_name': productName,
      'lot_number': lotNumber,
      'patient_id': patientId,
      'patient_name': patientName,
      'dossier_id': dossierId,
      'allergies': patientAllergies,
      'practitioner_id': practitionerId,
      'practitioner_name': practitionerName,
      'used_at': usedAt.toIso8601String(),
      'sync_status': syncStatus.name,
      'error_message': errorMessage,
      'procedure_type': procedureType,
      'notes': notes,
    };
  }

  InstrumentUsage toEntity() => InstrumentUsage(
        id: id,
        idempotencyKey: idempotencyKey,
        labelId: labelId,
        labelCode: labelCode,
        productName: productName,
        lotNumber: lotNumber,
        patientId: patientId,
        patientName: patientName,
        dossierId: dossierId,
        patientAllergies: patientAllergies,
        practitionerId: practitionerId,
        practitionerName: practitionerName,
        usedAt: usedAt,
        syncStatus: syncStatus,
        errorMessage: errorMessage,
        procedureType: procedureType,
        notes: notes,
      );
}
