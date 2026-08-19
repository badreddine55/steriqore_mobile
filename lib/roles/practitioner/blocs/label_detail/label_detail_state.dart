import 'package:equatable/equatable.dart';
import '../../models/cycle_model.dart';
import '../../models/label_model.dart';

abstract class LabelDetailState extends Equatable {
  const LabelDetailState();

  @override
  List<Object?> get props => [];
}

class LabelDetailInitial extends LabelDetailState {
  const LabelDetailInitial();
}

class LabelDetailLoading extends LabelDetailState {
  const LabelDetailLoading();
}

class LabelDetailLoaded extends LabelDetailState {
  final LabelModel label;
  final CycleModel? cycle;
  final bool isOffline;

  const LabelDetailLoaded({
    required this.label,
    this.cycle,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [label, cycle, isOffline];
}

/// 410 Blocked State (Safety Gate)
class LabelDetailBlocked extends LabelDetailState {
  final LabelModel label;
  final String reason;
  final CycleModel? cycle;

  const LabelDetailBlocked({
    required this.label,
    required this.reason,
    this.cycle,
  });

  @override
  List<Object?> get props => [label, reason, cycle];
}

/// 409 Already Used State
class LabelDetailAlreadyUsed extends LabelDetailState {
  final LabelModel label;
  final String message;
  final CycleModel? cycle;

  const LabelDetailAlreadyUsed({
    required this.label,
    required this.message,
    this.cycle,
  });

  @override
  List<Object?> get props => [label, message, cycle];
}

class LabelDetailNotFound extends LabelDetailState {
  final String code;
  const LabelDetailNotFound(this.code);

  @override
  List<Object?> get props => [code];
}

class LabelDetailError extends LabelDetailState {
  final String message;
  const LabelDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
