import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerInitialized extends ScannerEvent {
  const ScannerInitialized();
}

class ScannerBarcodeDetected extends ScannerEvent {
  final String code;
  const ScannerBarcodeDetected(this.code);

  @override
  List<Object?> get props => [code];
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

class ScannerPermissionDenied extends ScannerEvent {
  const ScannerPermissionDenied();
}

class ScannerReset extends ScannerEvent {
  const ScannerReset();
}
