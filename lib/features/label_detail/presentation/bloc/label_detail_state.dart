import 'package:equatable/equatable.dart';
import '../../../scanner/domain/entities/label.dart';
import '../../domain/entities/sterilization_cycle.dart';

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
  final Label label;
  final SterilizationCycle? cycle;
  final bool isBlocked;
  final String? blockReason;

  const LabelDetailLoaded({
    required this.label,
    this.cycle,
    this.isBlocked = false,
    this.blockReason,
  });

  @override
  List<Object?> get props => [label, cycle, isBlocked, blockReason];
}

class LabelDetailError extends LabelDetailState {
  final String message;

  const LabelDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
