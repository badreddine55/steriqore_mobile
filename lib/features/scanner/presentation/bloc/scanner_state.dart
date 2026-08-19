import 'package:equatable/equatable.dart';
import '../../domain/entities/label.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

/// Active scanning state (idle, camera feed active, ready for barcode/DataMatrix)
class ScannerScanning extends ScannerState {
  final bool isTorchOn;
  final bool isLocked;

  const ScannerScanning({
    this.isTorchOn = false,
    this.isLocked = false,
  });

  ScannerScanning copyWith({bool? isTorchOn, bool? isLocked}) {
    return ScannerScanning(
      isTorchOn: isTorchOn ?? this.isTorchOn,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [isTorchOn, isLocked];
}

/// Backward-compatible alias for ScannerScanning
typedef ScannerReady = ScannerScanning;

/// Code detected, currently verifying with API (brief loading indicator over live camera)
class ScannerProcessing extends ScannerState {
  final String code;

  const ScannerProcessing(this.code);

  @override
  List<Object?> get props => [code];
}

/// 200 OK — Label found and verified compliant (auto-navigates to LabelDetail)
class ScannerLabelFound extends ScannerState {
  final Label label;

  const ScannerLabelFound(this.label);

  @override
  List<Object?> get props => [label];
}

/// Backward-compatible alias for ScannerLabelFound
typedef ScannerSuccess = ScannerLabelFound;

/// 404 Not Found — Invalid code, shows auto-dismissing inline banner
class ScannerLabelNotFound extends ScannerState {
  final String code;
  final String message;

  const ScannerLabelNotFound({
    required this.code,
    this.message = 'Invalid code — no such label',
  });

  @override
  List<Object?> get props => [code, message];
}

/// 410 Blocked — Expired DLC or Recalled instrument, requires explicit user acknowledgment
class ScannerLabelBlocked extends ScannerState {
  final String code;
  final String reason;
  final String? recallReason;

  const ScannerLabelBlocked({
    required this.code,
    required this.reason,
    this.recallReason,
  });

  @override
  List<Object?> get props => [code, reason, recallReason];
}

/// Backward-compatible alias for ScannerLabelBlocked
typedef ScannerBlocked = ScannerLabelBlocked;

/// 409 Conflict — Already recorded as used (amber warning banner, informational)
class ScannerAlreadyUsed extends ScannerState {
  final String code;
  final String message;

  const ScannerAlreadyUsed({
    required this.code,
    this.message = 'This instrument was already recorded as used',
  });

  @override
  List<Object?> get props => [code, message];
}

/// 429 Rate Limited — Too many scans (banner with cooldown countdown)
class ScannerRateLimited extends ScannerState {
  final int cooldownSeconds;
  final String message;

  const ScannerRateLimited({
    this.cooldownSeconds = 5,
    this.message = 'Too many scans — wait a moment',
  });

  @override
  List<Object?> get props => [cooldownSeconds, message];
}

/// 401 Unauthorized — Session expired, redirect directly to Login
class ScannerSessionExpired extends ScannerState {
  final String message;

  const ScannerSessionExpired([this.message = 'Session expired. Please log in again.']);

  @override
  List<Object?> get props => [message];
}

/// Offline Mode — Queued scan ("Saved — will sync when online")
class ScannerOffline extends ScannerState {
  final String code;
  final String message;

  const ScannerOffline({
    required this.code,
    this.message = 'Saved — will sync when online',
  });

  @override
  List<Object?> get props => [code, message];
}

/// Camera permission denied
class ScannerPermissionDeniedState extends ScannerState {
  final String message;

  const ScannerPermissionDeniedState([this.message = 'Camera permission is required to scan sterilization pouches.']);

  @override
  List<Object?> get props => [message];
}

/// Generic error banner state
class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
