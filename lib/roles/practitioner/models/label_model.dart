import 'package:flutter/foundation.dart';

/// Compliance status of a physical sterilization label
enum LabelStatus {
  valid,
  expired,
  recalled,
  alreadyUsed,
  pendingValidation,
  unknown;

  static LabelStatus fromString(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'valid':
      case 'validated':
      case 'active':
      case 'conforme':
        return LabelStatus.valid;
      case 'expired':
      case 'perime':
        return LabelStatus.expired;
      case 'recalled':
      case 'rappel':
      case 'bloque':
      case 'blocked':
        return LabelStatus.recalled;
      case 'used':
      case 'already_used':
      case 'utilise':
        return LabelStatus.alreadyUsed;
      case 'pending':
      case 'pending_validation':
      case 'en_attente':
        return LabelStatus.pendingValidation;
      default:
        return LabelStatus.unknown;
    }
  }

  String toDisplayString() {
    switch (this) {
      case LabelStatus.valid:
        return 'Validated / Ready';
      case LabelStatus.expired:
        return 'Expired (DLC Overdue)';
      case LabelStatus.recalled:
        return 'Recalled / Safety Blocked';
      case LabelStatus.alreadyUsed:
        return 'Already Recorded';
      case LabelStatus.pendingValidation:
        return 'Pending Sterilization';
      case LabelStatus.unknown:
        return 'Status Unverified';
    }
  }
}

/// Represents a scanned package label / DataMatrix for dental instruments
@immutable
class LabelModel {
  final int id;
  final String code; // Full DataMatrix/QR payload or human-readable code
  final String productName;
  final String reference;
  final String lotNumber;
  final DateTime expirationDate; // Date Limite de Consommation (DLC)
  final LabelStatus status;
  final int? cycleId;
  final String? cycleNumber;
  final DateTime? sterilizationDate;
  final String? autoclaveName;
  final String? recallReason;
  final bool isUsed;
  final DateTime? usedAt;
  final String? usedByPractitioner;
  final String? patientName;
  final Map<String, dynamic>? metadata;

  const LabelModel({
    required this.id,
    required this.code,
    required this.productName,
    required this.reference,
    required this.lotNumber,
    required this.expirationDate,
    required this.status,
    this.cycleId,
    this.cycleNumber,
    this.sterilizationDate,
    this.autoclaveName,
    this.recallReason,
    this.isUsed = false,
    this.usedAt,
    this.usedByPractitioner,
    this.patientName,
    this.metadata,
  });

  /// Critical medical compliance gate: whether this label cannot be used on a patient
  bool get isBlocked =>
      status == LabelStatus.expired ||
      status == LabelStatus.recalled ||
      isExpiredByDate;

  /// Whether the expiration date is strictly in the past
  bool get isExpiredByDate =>
      expirationDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

  /// Remaining days before expiration
  int get remainingDays =>
      expirationDate.difference(DateTime.now()).inDays;

  /// Near-expiration caution flag (< 30 days)
  bool get isNearExpiration =>
      !isBlocked && remainingDays >= 0 && remainingDays <= 30;

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now().add(const Duration(days: 90));
      }
      return DateTime.now().add(const Duration(days: 90));
    }

    final cycleJson = json['cycle'] as Map<String, dynamic>?;

    return LabelModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? json['barcode'] as String? ?? 'UNKNOWN',
      productName: json['product_name'] as String? ??
          json['name'] as String? ??
          'Dental Medical Device',
      reference: json['reference'] as String? ?? json['sku'] as String? ?? 'REF-000',
      lotNumber: json['lot_number'] as String? ?? json['lot'] as String? ?? 'LOT-DEFAULT',
      expirationDate: parseDate(json['expiration_date'] ?? json['dlc'] ?? json['expires_at']),
      status: LabelStatus.fromString(json['status'] as String?),
      cycleId: json['cycle_id'] as int? ?? cycleJson?['id'] as int?,
      cycleNumber: json['cycle_number'] as String? ?? cycleJson?['cycle_number'] as String?,
      sterilizationDate: json['sterilization_date'] != null
          ? DateTime.tryParse(json['sterilization_date'].toString())
          : (cycleJson?['validated_at'] != null
              ? DateTime.tryParse(cycleJson!['validated_at'].toString())
              : null),
      autoclaveName: json['autoclave_name'] as String? ?? cycleJson?['autoclave_name'] as String?,
      recallReason: json['recall_reason'] as String? ?? json['blocking_reason'] as String?,
      isUsed: json['is_used'] as bool? ?? json['used'] as bool? ?? false,
      usedAt: json['used_at'] != null ? DateTime.tryParse(json['used_at'].toString()) : null,
      usedByPractitioner: json['used_by_practitioner'] as String?,
      patientName: json['patient_name'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'product_name': productName,
      'reference': reference,
      'lot_number': lotNumber,
      'expiration_date': expirationDate.toIso8601String(),
      'status': status.name,
      'cycle_id': cycleId,
      'cycle_number': cycleNumber,
      'sterilization_date': sterilizationDate?.toIso8601String(),
      'autoclave_name': autoclaveName,
      'recall_reason': recallReason,
      'is_used': isUsed,
      'used_at': usedAt?.toIso8601String(),
      'used_by_practitioner': usedByPractitioner,
      'patient_name': patientName,
      'metadata': metadata,
    };
  }
}
