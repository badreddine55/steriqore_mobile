import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/scan_label.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ScanLabelUseCase scanLabelUseCase;
  bool _isTorchOn = false;
  String _lastScannedCode = '';
  DateTime? _lastScanTime;
  Timer? _autoDismissTimer;

  ScannerBloc({
    required this.scanLabelUseCase,
  }) : super(const ScannerInitial()) {
    on<ScannerInitRequested>(_onInit);
    on<ScannerCodeDetected>(_onCodeDetected);
    on<ScannerManualCodeSubmitted>(_onManualCodeSubmitted);
    on<ScannerTorchToggled>(_onTorchToggled);
    on<ScannerResetRequested>(_onReset);
    on<ScannerDismissBannerRequested>(_onDismissBanner);
    on<ScannerAcknowledgeBlockRequested>(_onAcknowledgeBlock);
    on<ScannerPermissionDeniedEvent>(_onPermissionDenied);
  }

  @override
  Future<void> close() {
    _autoDismissTimer?.cancel();
    return super.close();
  }

  void _onInit(ScannerInitRequested event, Emitter<ScannerState> emit) {
    _autoDismissTimer?.cancel();
    emit(ScannerScanning(isTorchOn: _isTorchOn));
  }

  void _onPermissionDenied(ScannerPermissionDeniedEvent event, Emitter<ScannerState> emit) {
    _autoDismissTimer?.cancel();
    emit(const ScannerPermissionDeniedState());
  }

  Future<void> _onCodeDetected(
    ScannerCodeDetected event,
    Emitter<ScannerState> emit,
  ) async {
    final code = event.rawCode.trim();
    if (code.isEmpty) return;

    // Lock scanning if currently processing or blocked or displaying active feedback
    if (state is ScannerProcessing ||
        state is ScannerLabelBlocked ||
        state is ScannerRateLimited) {
      return;
    }

    // Debounce repeated scans of the same code within 3 seconds
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 3000) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    await _processCode(code, emit);
  }

  Future<void> _onManualCodeSubmitted(
    ScannerManualCodeSubmitted event,
    Emitter<ScannerState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty) return;
    _lastScannedCode = code;
    _lastScanTime = DateTime.now();
    await _processCode(code, emit);
  }

  Future<void> _processCode(String code, Emitter<ScannerState> emit) async {
    _autoDismissTimer?.cancel();
    emit(ScannerProcessing(code));

    final result = await scanLabelUseCase(ScanLabelParams(code));

    result.fold(
      (failure) {
        if (failure is BlockingFailure || failure.statusCode == 410) {
          emit(ScannerLabelBlocked(
            code: code,
            reason: failure.message,
            recallReason: failure is BlockingFailure ? failure.recallReason : null,
          ));
        } else if (failure is NotFoundFailure || failure.statusCode == 404) {
          emit(ScannerLabelNotFound(code: code, message: failure.message));
          _scheduleAutoDismiss();
        } else if (failure is AlreadyUsedFailure || failure.statusCode == 409) {
          emit(ScannerAlreadyUsed(code: code, message: failure.message));
          _scheduleAutoDismiss();
        } else if (failure is RateLimitedFailure || failure.statusCode == 429) {
          final cooldown = failure is RateLimitedFailure ? failure.retryAfterSeconds : 5;
          emit(ScannerRateLimited(cooldownSeconds: cooldown, message: failure.message));
          _scheduleCooldown(cooldown);
        } else if (failure is AuthFailure || failure.statusCode == 401) {
          emit(ScannerSessionExpired(failure.message));
        } else if (failure is NetworkFailure) {
          emit(ScannerOffline(code: code, message: failure.message));
          _scheduleAutoDismiss();
        } else {
          emit(ScannerError(failure.message));
          _scheduleAutoDismiss();
        }
      },
      (label) {
        emit(ScannerLabelFound(label));
      },
    );
  }

  void _scheduleAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!isClosed && (state is ScannerLabelNotFound || state is ScannerAlreadyUsed || state is ScannerOffline || state is ScannerError)) {
        add(const ScannerDismissBannerRequested());
      }
    });
  }

  void _scheduleCooldown(int seconds) {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(Duration(seconds: seconds), () {
      if (!isClosed && state is ScannerRateLimited) {
        add(const ScannerDismissBannerRequested());
      }
    });
  }

  void _onTorchToggled(ScannerTorchToggled event, Emitter<ScannerState> emit) {
    _isTorchOn = !_isTorchOn;
    if (state is ScannerScanning) {
      emit(ScannerScanning(isTorchOn: _isTorchOn));
    }
  }

  void _onDismissBanner(ScannerDismissBannerRequested event, Emitter<ScannerState> emit) {
    _autoDismissTimer?.cancel();
    emit(ScannerScanning(isTorchOn: _isTorchOn));
  }

  void _onAcknowledgeBlock(ScannerAcknowledgeBlockRequested event, Emitter<ScannerState> emit) {
    _autoDismissTimer?.cancel();
    emit(ScannerScanning(isTorchOn: _isTorchOn));
  }

  void _onReset(ScannerResetRequested event, Emitter<ScannerState> emit) {
    _autoDismissTimer?.cancel();
    emit(ScannerScanning(isTorchOn: _isTorchOn));
  }
}
