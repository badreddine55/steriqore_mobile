import 'package:equatable/equatable.dart';

abstract class LabelDetailEvent extends Equatable {
  const LabelDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadLabelDetailRequested extends LabelDetailEvent {
  final String code;

  const LoadLabelDetailRequested(this.code);

  @override
  List<Object?> get props => [code];
}

class RefreshLabelDetailRequested extends LabelDetailEvent {
  final String code;

  const RefreshLabelDetailRequested(this.code);

  @override
  List<Object?> get props => [code];
}
