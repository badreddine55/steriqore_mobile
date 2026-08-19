import '../../domain/entities/label.dart';

class LabelModel extends Label {
  const LabelModel({
    required super.id,
    required super.code,
    required super.productName,
    required super.reference,
    required super.lotNumber,
    required super.expirationDate,
    super.status = LabelStatusType.valid,
    super.cycleId,
    super.cycleNumber,
    super.autoclaveName,
    super.sterilizationDate,
    super.recallReason,
    super.usedAt,
    super.usedByPatientName,
    super.operatorName,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String? ?? 'valid').toLowerCase();
    LabelStatusType statusType = LabelStatusType.valid;
    if (statusStr.contains('expired')) {
      statusType = LabelStatusType.expired;
    } else if (statusStr.contains('recalled') || statusStr.contains('recall')) {
      statusType = LabelStatusType.recalled;
    } else if (statusStr.contains('used') || statusStr.contains('already')) {
      statusType = LabelStatusType.alreadyUsed;
    } else if (statusStr.contains('pending')) {
      statusType = LabelStatusType.pendingValidation;
    }

    DateTime expiry = DateTime.now().add(const Duration(days: 180));
    if (json['expiration_date'] != null || json['dlc'] != null) {
      try {
        expiry = DateTime.parse((json['expiration_date'] ?? json['dlc']).toString());
      } catch (_) {}
    }

    DateTime? steriDate;
    if (json['sterilization_date'] != null || json['sterilized_at'] != null) {
      try {
        steriDate = DateTime.parse((json['sterilization_date'] ?? json['sterilized_at']).toString());
      } catch (_) {}
    }

    DateTime? usedDate;
    if (json['used_at'] != null) {
      try {
        usedDate = DateTime.parse(json['used_at'].toString());
      } catch (_) {}
    }

    return LabelModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      code: json['code'] as String? ?? json['barcode'] as String? ?? 'UNKNOWN',
      productName: json['product_name'] as String? ?? json['name'] as String? ?? 'Dental Instrument',
      reference: json['reference'] as String? ?? json['sku'] as String? ?? 'REF-001',
      lotNumber: json['lot_number'] as String? ?? json['lot'] as String? ?? 'LOT-DEFAULT',
      expirationDate: expiry,
      status: statusType,
      cycleId: json['cycle_id'] as int?,
      cycleNumber: json['cycle_number'] as String? ?? json['cycle_code'] as String?,
      autoclaveName: json['autoclave_name'] as String? ?? json['device'] as String?,
      sterilizationDate: steriDate,
      recallReason: json['recall_reason'] as String?,
      usedAt: usedDate,
      usedByPatientName: json['used_by_patient_name'] as String? ?? json['patient_name'] as String?,
      operatorName: json['operator_name'] as String?,
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
      'autoclave_name': autoclaveName,
      'sterilization_date': sterilizationDate?.toIso8601String(),
      'recall_reason': recallReason,
      'used_at': usedAt?.toIso8601String(),
      'used_by_patient_name': usedByPatientName,
      'operator_name': operatorName,
    };
  }

  Label toEntity() {
    return Label(
      id: id,
      code: code,
      productName: productName,
      reference: reference,
      lotNumber: lotNumber,
      expirationDate: expirationDate,
      status: status,
      cycleId: cycleId,
      cycleNumber: cycleNumber,
      autoclaveName: autoclaveName,
      sterilizationDate: sterilizationDate,
      recallReason: recallReason,
      usedAt: usedAt,
      usedByPatientName: usedByPatientName,
      operatorName: operatorName,
    );
  }
}
