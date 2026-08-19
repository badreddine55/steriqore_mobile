import 'package:flutter/foundation.dart';

enum CycleStatus {
  validated,
  failed,
  inProgress,
  pending,
  unknown;

  static CycleStatus fromString(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'validated':
      case 'valide':
      case 'success':
      case 'conforme':
        return CycleStatus.validated;
      case 'failed':
      case 'echoue':
      case 'non_conforme':
      case 'error':
        return CycleStatus.failed;
      case 'in_progress':
      case 'en_cours':
      case 'running':
        return CycleStatus.inProgress;
      case 'pending':
      case 'en_attente':
        return CycleStatus.pending;
      default:
        return CycleStatus.unknown;
    }
  }

  String toDisplayString() {
    switch (this) {
      case CycleStatus.validated:
        return 'Conformity Validated';
      case CycleStatus.failed:
        return 'Cycle Failed (Non-Conformant)';
      case CycleStatus.inProgress:
        return 'Cycle In Progress';
      case CycleStatus.pending:
        return 'Pending Release';
      case CycleStatus.unknown:
        return 'Unknown';
    }
  }
}

@immutable
class CycleAttachmentModel {
  final int id;
  final String fileName;
  final String fileType; // pdf, image, log
  final String downloadUrl;
  final DateTime createdAt;

  const CycleAttachmentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.downloadUrl,
    required this.createdAt,
  });

  factory CycleAttachmentModel.fromJson(Map<String, dynamic> json) {
    return CycleAttachmentModel(
      id: json['id'] as int? ?? 0,
      fileName: json['file_name'] as String? ?? json['name'] as String? ?? 'attachment.pdf',
      fileType: json['file_type'] as String? ?? 'pdf',
      downloadUrl: json['download_url'] as String? ?? json['url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': fileType,
      'download_url': downloadUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

@immutable
class CycleItemModel {
  final int id;
  final String labelCode;
  final String productName;
  final String lotNumber;
  final int quantity;

  const CycleItemModel({
    required this.id,
    required this.labelCode,
    required this.productName,
    required this.lotNumber,
    this.quantity = 1,
  });

  factory CycleItemModel.fromJson(Map<String, dynamic> json) {
    return CycleItemModel(
      id: json['id'] as int? ?? 0,
      labelCode: json['label_code'] as String? ?? json['code'] as String? ?? '',
      productName: json['product_name'] as String? ?? json['name'] as String? ?? 'Device',
      lotNumber: json['lot_number'] as String? ?? json['lot'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label_code': labelCode,
      'product_name': productName,
      'lot_number': lotNumber,
      'quantity': quantity,
    };
  }
}

/// Represents an autoclave sterilization cycle
@immutable
class CycleModel {
  final int id;
  final String cycleNumber;
  final String autoclaveName;
  final String operatorName;
  final double temperature; // e.g. 134.0 °C
  final double pressure; // e.g. 2.1 bar
  final int durationMinutes; // e.g. 18 min
  final CycleStatus status;
  final DateTime sterilizedAt;
  final DateTime? validatedAt;
  final bool helixTestPassed;
  final bool vacuumTestPassed;
  final int itemsCount;
  final int attachmentsCount;
  final List<CycleItemModel> items;
  final List<CycleAttachmentModel> attachments;
  final List<String> linkedLabels;

  const CycleModel({
    required this.id,
    required this.cycleNumber,
    required this.autoclaveName,
    required this.operatorName,
    this.temperature = 134.0,
    this.pressure = 2.1,
    this.durationMinutes = 18,
    required this.status,
    required this.sterilizedAt,
    this.validatedAt,
    this.helixTestPassed = true,
    this.vacuumTestPassed = true,
    this.itemsCount = 0,
    this.attachmentsCount = 0,
    this.items = const [],
    this.attachments = const [],
    this.linkedLabels = const [],
  });

  bool get isValidated => status == CycleStatus.validated;

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => CycleItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final attachmentsList = (json['attachments'] as List<dynamic>?)
            ?.map((e) => CycleAttachmentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final labelsList = (json['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return CycleModel(
      id: json['id'] as int? ?? 0,
      cycleNumber: json['cycle_number'] as String? ?? json['number'] as String? ?? 'CYC-000',
      autoclaveName: json['autoclave_name'] as String? ?? json['autoclave'] as String? ?? 'Melag Vacuklav 40B',
      operatorName: json['operator_name'] as String? ?? json['operator'] as String? ?? 'Sterilization Team',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 134.0,
      pressure: (json['pressure'] as num?)?.toDouble() ?? 2.1,
      durationMinutes: json['duration_minutes'] as int? ?? 18,
      status: CycleStatus.fromString(json['status'] as String?),
      sterilizedAt: json['sterilized_at'] != null
          ? DateTime.tryParse(json['sterilized_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      validatedAt: json['validated_at'] != null
          ? DateTime.tryParse(json['validated_at'].toString())
          : null,
      helixTestPassed: json['helix_test_passed'] as bool? ?? true,
      vacuumTestPassed: json['vacuum_test_passed'] as bool? ?? true,
      itemsCount: json['items_count'] as int? ?? itemsList.length,
      attachmentsCount: json['attachments_count'] as int? ?? attachmentsList.length,
      items: itemsList,
      attachments: attachmentsList,
      linkedLabels: labelsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycle_number': cycleNumber,
      'autoclave_name': autoclaveName,
      'operator_name': operatorName,
      'temperature': temperature,
      'pressure': pressure,
      'duration_minutes': durationMinutes,
      'status': status.name,
      'sterilized_at': sterilizedAt.toIso8601String(),
      'validated_at': validatedAt?.toIso8601String(),
      'helix_test_passed': helixTestPassed,
      'vacuum_test_passed': vacuumTestPassed,
      'items_count': itemsCount,
      'attachments_count': attachmentsCount,
      'items': items.map((e) => e.toJson()).toList(),
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'labels': linkedLabels,
    };
  }
}
