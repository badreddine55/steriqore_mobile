import 'package:equatable/equatable.dart';
import '../../models/label_model.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

class ScannerReady extends ScannerState {
  final bool isTorchOn;
  final bool isScanning;

  const ScannerReady({
    this.isTorchOn = false,
    this.isScanning = true,
  });

  ScannerReady copyWith({bool? isTorchOn, bool? isScanning}) {
    return ScannerReady(
      isTorchOn: isTorchOn ?? this.isTorchOn,
      isScanning: isScanning ?? this.isScanning,
    );
  }

  @override
  List<Object?> get props => [isTorchOn, isScanning];
}

class ScannerProcessing extends ScannerState {
  final String code;
  const ScannerProcessing(this.code);

  @override
  List<Object?> get props => [code];
}

class ScannerSuccess extends ScannerState {
  final LabelModel label;
  const ScannerSuccess(this.label);

  @override
  List<Object?> get props => [label];
}

/// 410 Blocked / Expired / Recalled state
class ScannerBlocked extends ScannerState {
  final LabelModel label;
  final String reason;
  const ScannerBlocked(this.label, this.reason);

  @override
  List<Object?> get props => [label, reason];
}

/// 409 Usage already recorded
class ScannerAlreadyUsed extends ScannerState {
  final LabelModel? label;
  final String message;
  const ScannerAlreadyUsed({this.label, required this.message});

  @override
  List<Object?> get props => [label, message];
}

/// 404 Not Found
class ScannerNotFound extends ScannerState {
  final String code;
  const ScannerNotFound(this.code);

  @override
  List<Object?> get props => [code];
}

/// 429 Rate limited with countdown
class ScannerRateLimited extends ScannerState {
  final int retryAfterSeconds;
  const ScannerRateLimited(this.retryAfterSeconds);

  @override
  List<Object?> get props => [retryAfterSeconds];
}

/// Camera permission denied state
class ScannerPermissionError extends ScannerState {
  final String message;
  const ScannerPermissionError([this.message = 'Camera permission is required to scan instrument packaging.']);

  @override
  List<Object?> get props => [message];
}

/// Generic failure
class ScannerError extends ScannerState {
  final String message;
  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
