import 'package:flutter/foundation.dart';

/// Sync lifecycle status for medical usage recordings
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed;

  static SyncStatus fromString(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'syncing':
        return SyncStatus.syncing;
      case 'synced':
      case 'success':
        return SyncStatus.synced;
      case 'failed':
      case 'error':
        return SyncStatus.failed;
      case 'pending':
      default:
        return SyncStatus.pending;
    }
  }

  String toDisplayString() {
    switch (this) {
      case SyncStatus.pending:
        return 'Pending Sync (Offline)';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced with Cloud';
      case SyncStatus.failed:
        return 'Sync Failed';
    }
  }
}

/// Recorded usage of a sterilized instrument label on a patient by a practitioner
@immutable
class UsageModel {
  final int? id; // Server ID (null when locally queued)
  final String idempotencyKey; // UUID generated client-side per scan attempt
  final int labelId;
  final String labelCode;
  final String productName;
  final String lotNumber;
  final String reference;
  final int patientId;
  final String patientName;
  final String? patientIdentifier;
  final int practitionerId;
  final String practitionerName;
  final DateTime usedAt;
  final SyncStatus syncStatus;
  final String? notes;
  final String? procedureType;
  final String? errorMessage;
  final int retryCount;

  const UsageModel({
    this.id,
    required this.idempotencyKey,
    required this.labelId,
    required this.labelCode,
    required this.productName,
    required this.lotNumber,
    this.reference = '',
    required this.patientId,
    required this.patientName,
    this.patientIdentifier,
    required this.practitionerId,
    required this.practitionerName,
    required this.usedAt,
    this.syncStatus = SyncStatus.synced,
    this.notes,
    this.procedureType,
    this.errorMessage,
    this.retryCount = 0,
  });

  UsageModel copyWith({
    int? id,
    String? idempotencyKey,
    int? labelId,
    String? labelCode,
    String? productName,
    String? lotNumber,
    String? reference,
    int? patientId,
    String? patientName,
    String? patientIdentifier,
    int? practitionerId,
    String? practitionerName,
    DateTime? usedAt,
    SyncStatus? syncStatus,
    String? notes,
    String? procedureType,
    String? errorMessage,
    int? retryCount,
  }) {
    return UsageModel(
      id: id ?? this.id,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      labelId: labelId ?? this.labelId,
      labelCode: labelCode ?? this.labelCode,
      productName: productName ?? this.productName,
      lotNumber: lotNumber ?? this.lotNumber,
      reference: reference ?? this.reference,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientIdentifier: patientIdentifier ?? this.patientIdentifier,
      practitionerId: practitionerId ?? this.practitionerId,
      practitionerName: practitionerName ?? this.practitionerName,
      usedAt: usedAt ?? this.usedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      notes: notes ?? this.notes,
      procedureType: procedureType ?? this.procedureType,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    final patientJson = json['patient'] as Map<String, dynamic>?;
    final labelJson = json['label'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>? ?? json['practitioner'] as Map<String, dynamic>?;

    return UsageModel(
      id: json['id'] as int?,
      idempotencyKey: json['idempotency_key'] as String? ?? json['uuid'] as String? ?? 'LOCAL-${DateTime.now().millisecondsSinceEpoch}',
      labelId: json['label_id'] as int? ?? labelJson?['id'] as int? ?? 0,
      labelCode: json['label_code'] as String? ?? labelJson?['code'] as String? ?? '',
      productName: json['product_name'] as String? ?? labelJson?['product_name'] as String? ?? 'Medical Device',
      lotNumber: json['lot_number'] as String? ?? labelJson?['lot_number'] as String? ?? '',
      reference: json['reference'] as String? ?? labelJson?['reference'] as String? ?? '',
      patientId: json['patient_id'] as int? ?? patientJson?['id'] as int? ?? 0,
      patientName: json['patient_name'] as String? ??
          (patientJson != null ? '${patientJson['first_name']} ${patientJson['last_name']}' : 'Patient'),
      patientIdentifier: json['patient_identifier'] as String? ?? patientJson?['identifier'] as String?,
      practitionerId: json['practitioner_id'] as int? ?? userJson?['id'] as int? ?? 0,
      practitionerName: json['practitioner_name'] as String? ?? userJson?['name'] as String? ?? 'Practitioner',
      usedAt: json['used_at'] != null
          ? DateTime.tryParse(json['used_at'].toString()) ?? DateTime.now()
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
      syncStatus: SyncStatus.fromString(json['sync_status'] as String?),
      notes: json['notes'] as String?,
      procedureType: json['procedure_type'] as String?,
      errorMessage: json['error_message'] as String?,
      retryCount: json['retry_count'] as int? ?? 0,
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
      'reference': reference,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_identifier': patientIdentifier,
      'practitioner_id': practitionerId,
      'practitioner_name': practitionerName,
      'used_at': usedAt.toIso8601String(),
      'sync_status': syncStatus.name,
      'notes': notes,
      'procedure_type': procedureType,
      'error_message': errorMessage,
      'retry_count': retryCount,
    };
  }
}
