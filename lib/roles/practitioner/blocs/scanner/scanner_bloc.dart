import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/label_repository.dart';
import '../../repositories/practitioner_exceptions.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final LabelRepository _labelRepository;
  bool _isTorchOn = false;
  bool _isProcessing = false;

  ScannerBloc({LabelRepository? labelRepository})
      : _labelRepository = labelRepository ?? LabelRepository(),
        super(const ScannerInitial()) {
    on<ScannerInitialized>(_onInitialized);
    on<ScannerBarcodeDetected>(_onBarcodeDetected);
    on<ScannerManualCodeSubmitted>(_onManualCodeSubmitted);
    on<ScannerTorchToggled>(_onTorchToggled);
    on<ScannerPermissionDenied>(_onPermissionDenied);
    on<ScannerReset>(_onReset);
  }

  void _onInitialized(ScannerInitialized event, Emitter<ScannerState> emit) {
    _isProcessing = false;
    emit(ScannerReady(isTorchOn: _isTorchOn, isScanning: true));
  }

  Future<void> _onBarcodeDetected(
    ScannerBarcodeDetected event,
    Emitter<ScannerState> emit,
  ) async {
    if (_isProcessing) return;
    final code = event.code.trim();
    if (code.isEmpty) return;

    _isProcessing = true;
    emit(ScannerProcessing(code));
    await _lookupLabel(code, emit);
  }

  Future<void> _onManualCodeSubmitted(
    ScannerManualCodeSubmitted event,
    Emitter<ScannerState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty) {
      emit(const ScannerError('Please enter a valid label code.'));
      return;
    }

    emit(ScannerProcessing(code));
    await _lookupLabel(code, emit);
  }

  Future<void> _lookupLabel(String code, Emitter<ScannerState> emit) async {
    try {
      final label = await _labelRepository.getLabelByCode(code);
      _isProcessing = false;
      emit(ScannerSuccess(label));
    } on LabelBlockedException catch (e) {
      _isProcessing = false;
      emit(ScannerBlocked(e.label, e.reason));
    } on UsageAlreadyRecordedException catch (e) {
      _isProcessing = false;
      emit(ScannerAlreadyUsed(label: e.label, message: e.message));
    } on LabelNotFoundException catch (e) {
      _isProcessing = false;
      emit(ScannerNotFound(e.code));
    } on RateLimitException catch (e) {
      _isProcessing = false;
      emit(ScannerRateLimited(e.retryAfterSeconds));
    } on TokenExpiredException {
      _isProcessing = false;
      emit(const ScannerError('Session expired. Please log in again.'));
    } on RoleForbiddenException {
      _isProcessing = false;
      emit(const ScannerError('Access denied: Practitioner permissions required.'));
    } catch (e) {
      _isProcessing = false;
      emit(ScannerError(e.toString()));
    }
  }

  void _onTorchToggled(ScannerTorchToggled event, Emitter<ScannerState> emit) {
    _isTorchOn = !_isTorchOn;
    if (state is ScannerReady) {
      emit((state as ScannerReady).copyWith(isTorchOn: _isTorchOn));
    } else {
      emit(ScannerReady(isTorchOn: _isTorchOn, isScanning: true));
    }
  }

  void _onPermissionDenied(ScannerPermissionDenied event, Emitter<ScannerState> emit) {
    _isProcessing = false;
    emit(const ScannerPermissionError());
  }

  void _onReset(ScannerReset event, Emitter<ScannerState> emit) {
    _isProcessing = false;
    emit(ScannerReady(isTorchOn: _isTorchOn, isScanning: true));
  }
}
