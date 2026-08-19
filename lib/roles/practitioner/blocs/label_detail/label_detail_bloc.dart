import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/cycle_model.dart';
import '../../models/label_model.dart';
import '../../repositories/cycle_repository.dart';
import '../../repositories/label_repository.dart';
import '../../repositories/practitioner_exceptions.dart';
import 'label_detail_event.dart';
import 'label_detail_state.dart';

class LabelDetailBloc extends Bloc<LabelDetailEvent, LabelDetailState> {
  final LabelRepository _labelRepository;
  final CycleRepository _cycleRepository;
  String _currentCode = '';

  LabelDetailBloc({
    LabelRepository? labelRepository,
    CycleRepository? cycleRepository,
  })  : _labelRepository = labelRepository ?? LabelRepository(),
        _cycleRepository = cycleRepository ?? CycleRepository(),
        super(const LabelDetailInitial()) {
    on<LoadLabelDetail>(_onLoadLabelDetail);
    on<RefreshLabelDetail>(_onRefreshLabelDetail);
  }

  Future<void> _onLoadLabelDetail(
    LoadLabelDetail event,
    Emitter<LabelDetailState> emit,
  ) async {
    _currentCode = event.code;
    emit(const LabelDetailLoading());

    LabelModel? label = event.initialLabel;
    CycleModel? cycle;
    bool isOffline = false;

    try {
      label ??= await _labelRepository.getLabelByCode(event.code);

      // Fetch sterilization cycle info if cycleId exists
      if (label.cycleId != null && label.cycleId! > 0) {
        try {
          cycle = await _cycleRepository.getCycleDetails(label.cycleId!);
        } catch (_) {}
      }

      if (label.isBlocked) {
        emit(LabelDetailBlocked(
          label: label,
          reason: label.recallReason ??
              (label.isExpiredByDate ? 'DLC Expired (${label.expirationDate.toString().split(' ')[0]})' : 'Recalled'),
          cycle: cycle,
        ));
      } else if (label.isUsed) {
        emit(LabelDetailAlreadyUsed(
          label: label,
          message: 'This instrument package was recorded as used on ${label.usedAt ?? 'a previous session'}.',
          cycle: cycle,
        ));
      } else {
        emit(LabelDetailLoaded(label: label, cycle: cycle, isOffline: isOffline));
      }
    } on LabelBlockedException catch (e) {
      emit(LabelDetailBlocked(label: e.label, reason: e.reason, cycle: cycle));
    } on UsageAlreadyRecordedException catch (e) {
      if (e.label != null) {
        emit(LabelDetailAlreadyUsed(label: e.label!, message: e.message, cycle: cycle));
      } else {
        emit(LabelDetailError(e.message));
      }
    } on LabelNotFoundException catch (e) {
      emit(LabelDetailNotFound(e.code));
    } on NetworkOfflineException {
      if (label != null) {
        emit(LabelDetailLoaded(label: label, cycle: cycle, isOffline: true));
      } else {
        emit(const LabelDetailError('Network offline and label not found in local cache.'));
      }
    } catch (e) {
      emit(LabelDetailError(e.toString()));
    }
  }

  Future<void> _onRefreshLabelDetail(
    RefreshLabelDetail event,
    Emitter<LabelDetailState> emit,
  ) async {
    if (_currentCode.isNotEmpty) {
      add(LoadLabelDetail(_currentCode));
    }
  }
}
