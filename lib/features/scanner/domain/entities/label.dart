import 'package:equatable/equatable.dart';

enum LabelStatusType {
  valid,
  expired,
  recalled,
  alreadyUsed,
  pendingValidation,
  unknown,
}

class Label extends Equatable {
  final int id;
  final String code;
  final String productName;
  final String reference;
  final String lotNumber;
  final DateTime expirationDate;
  final LabelStatusType status;
  final int? cycleId;
  final String? cycleNumber;
  final String? autoclaveName;
  final DateTime? sterilizationDate;
  final String? recallReason;
  final DateTime? usedAt;
  final String? usedByPatientName;
  final String? operatorName;

  const Label({
    required this.id,
    required this.code,
    required this.productName,
    required this.reference,
    required this.lotNumber,
    required this.expirationDate,
    this.status = LabelStatusType.valid,
    this.cycleId,
    this.cycleNumber,
    this.autoclaveName,
    this.sterilizationDate,
    this.recallReason,
    this.usedAt,
    this.usedByPatientName,
    this.operatorName,
  });

  bool get isExpiredByDate => expirationDate.isBefore(DateTime.now());

  bool get isBlocked =>
      status == LabelStatusType.expired ||
      status == LabelStatusType.recalled ||
      isExpiredByDate;

  bool get isUsed => status == LabelStatusType.alreadyUsed || usedAt != null;

  int get remainingDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
    return expiry.difference(today).inDays;
  }

  bool get isNearExpiration => remainingDays >= 0 && remainingDays <= 30;

  @override
  List<Object?> get props => [
        id,
        code,
        productName,
        reference,
        lotNumber,
        expirationDate,
        status,
        cycleId,
        cycleNumber,
        autoclaveName,
        sterilizationDate,
        recallReason,
        usedAt,
        usedByPatientName,
        operatorName,
      ];
}
