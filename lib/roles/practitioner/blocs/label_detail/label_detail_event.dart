import 'package:equatable/equatable.dart';
import '../../models/label_model.dart';

abstract class LabelDetailEvent extends Equatable {
  const LabelDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadLabelDetail extends LabelDetailEvent {
  final String code;
  final LabelModel? initialLabel;

  const LoadLabelDetail(this.code, {this.initialLabel});

  @override
  List<Object?> get props => [code, initialLabel];
}

class RefreshLabelDetail extends LabelDetailEvent {
  const RefreshLabelDetail();
}
