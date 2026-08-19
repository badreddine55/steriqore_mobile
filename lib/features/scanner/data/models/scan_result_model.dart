import 'package:equatable/equatable.dart';
import 'label_model.dart';

class ScanResultModel extends Equatable {
  final String rawCode;
  final LabelModel? label;
  final bool isSuccess;
  final String? errorMessage;
  final bool isBlocked;

  const ScanResultModel({
    required this.rawCode,
    this.label,
    required this.isSuccess,
    this.errorMessage,
    this.isBlocked = false,
  });

  @override
  List<Object?> get props => [rawCode, label, isSuccess, errorMessage, isBlocked];
}
