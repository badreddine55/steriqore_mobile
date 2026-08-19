import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../scanner/domain/entities/label.dart';
import '../../../scanner/domain/usecases/get_label_details.dart';
import '../../domain/entities/sterilization_cycle.dart';
import '../../domain/usecases/get_cycle_details.dart';
import 'label_detail_event.dart';
import 'label_detail_state.dart';

class LabelDetailBloc extends Bloc<LabelDetailEvent, LabelDetailState> {
  final GetLabelDetailsUseCase getLabelDetailsUseCase;
  final GetCycleDetailsUseCase getCycleDetailsUseCase;

  LabelDetailBloc({
    required this.getLabelDetailsUseCase,
    required this.getCycleDetailsUseCase,
  }) : super(const LabelDetailInitial()) {
    on<LoadLabelDetailRequested>(_onLoadDetail);
    on<RefreshLabelDetailRequested>(_onRefreshDetail);
  }

  Future<void> _onLoadDetail(
    LoadLabelDetailRequested event,
    Emitter<LabelDetailState> emit,
  ) async {
    emit(const LabelDetailLoading());

    final labelResult = await getLabelDetailsUseCase(GetLabelDetailsParams(event.code));

    await labelResult.fold(
      (failure) async {
        if (failure is BlockingFailure) {
          final blockedLabel = Label(
            id: 99,
            code: event.code,
            productName: 'Sterilized Instrument Pouch',
            reference: 'REF-BLOCKED',
            lotNumber: event.code,
            expirationDate: DateTime.now().subtract(const Duration(days: 1)),
            status: failure.recallReason != null ? LabelStatusType.recalled : LabelStatusType.expired,
            recallReason: failure.recallReason,
          );

          emit(LabelDetailLoaded(
            label: blockedLabel,
            isBlocked: true,
            blockReason: failure.message,
          ));
        } else {
          emit(LabelDetailError(failure.message));
        }
      },
      (label) async {
        SterilizationCycle? cycle;
        if (label.cycleId != null) {
          final cycleResult = await getCycleDetailsUseCase(
            GetCycleDetailsParams(label.cycleId.toString()),
          );
          cycleResult.fold((_) => null, (c) => cycle = c);
        }

        emit(LabelDetailLoaded(
          label: label,
          cycle: cycle,
          isBlocked: label.isBlocked,
          blockReason: label.recallReason ??
              (label.isExpiredByDate ? 'DLC Expired (${label.expirationDate.toString().split(' ')[0]})' : null),
        ));
      },
    );
  }

  Future<void> _onRefreshDetail(
    RefreshLabelDetailRequested event,
    Emitter<LabelDetailState> emit,
  ) async {
    add(LoadLabelDetailRequested(event.code));
  }
}
