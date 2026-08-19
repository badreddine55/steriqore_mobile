import 'package:equatable/equatable.dart';

class CycleItem extends Equatable {
  final int id;
  final String productName;
  final String lotNumber;
  final int quantity;

  const CycleItem({
    required this.id,
    required this.productName,
    required this.lotNumber,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [id, productName, lotNumber, quantity];
}
