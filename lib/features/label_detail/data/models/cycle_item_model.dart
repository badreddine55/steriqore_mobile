import '../../domain/entities/cycle_item.dart';

class CycleItemModel extends CycleItem {
  const CycleItemModel({
    required super.id,
    required super.productName,
    required super.lotNumber,
    super.quantity = 1,
  });

  factory CycleItemModel.fromJson(Map<String, dynamic> json) {
    return CycleItemModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      productName: json['product_name'] as String? ?? json['name'] as String? ?? 'Dental Instrument',
      lotNumber: json['lot_number'] as String? ?? json['lot'] as String? ?? 'LOT-01',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'lot_number': lotNumber,
      'quantity': quantity,
    };
  }

  CycleItem toEntity() => CycleItem(
        id: id,
        productName: productName,
        lotNumber: lotNumber,
        quantity: quantity,
      );
}

class AttachmentModel {
  final String id;
  final String filename;
  final String url;
  final String? mimeType;

  const AttachmentModel({
    required this.id,
    required this.filename,
    required this.url,
    this.mimeType,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id']?.toString() ?? '1',
      filename: json['filename'] as String? ?? json['name'] as String? ?? 'cycle_report.pdf',
      url: json['url'] as String? ?? '',
      mimeType: json['mime_type'] as String? ?? 'application/pdf',
    );
  }
}
