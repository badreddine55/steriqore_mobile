import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerInitRequested extends ScannerEvent {
  const ScannerInitRequested();
}

class ScannerCodeDetected extends ScannerEvent {
  final String rawCode;

  const ScannerCodeDetected(this.rawCode);

  @override
  List<Object?> get props => [rawCode];
}

class ScannerManualCodeSubmitted extends ScannerEvent {
  final String code;

  const ScannerManualCodeSubmitted(this.code);

  @override
  List<Object?> get props => [code];
}

class ScannerTorchToggled extends ScannerEvent {
  const ScannerTorchToggled();
}

class ScannerResetRequested extends ScannerEvent {
  const ScannerResetRequested();
}

class ScannerDismissBannerRequested extends ScannerEvent {
  const ScannerDismissBannerRequested();
}

class ScannerAcknowledgeBlockRequested extends ScannerEvent {
  const ScannerAcknowledgeBlockRequested();
}

class ScannerPermissionDeniedEvent extends ScannerEvent {
  const ScannerPermissionDeniedEvent();
}
