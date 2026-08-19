import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/features/history/domain/entities/usage_history_entry.dart';
import 'package:steriqore_mobile/features/history/domain/repositories/history_repository.dart';
import 'package:steriqore_mobile/features/history/domain/usecases/get_practitioner_history.dart';
import 'package:steriqore_mobile/features/history/presentation/bloc/history_bloc.dart';
import 'package:steriqore_mobile/features/history/presentation/bloc/history_event.dart';
import 'package:steriqore_mobile/features/history/presentation/bloc/history_state.dart';
import 'package:steriqore_mobile/features/usage/domain/entities/instrument_usage.dart';

class FakeHistoryRepository implements HistoryRepository {
  @override
  Future<Either<Failure, List<UsageHistoryEntry>>> getPractitionerHistory({
    int page = 1,
    String? search,
    String? filterDate,
  }) async {
    return Right([
      UsageHistoryEntry(
        id: '1',
        idempotencyKey: 'UUID-1',
        labelCode: 'LOT-1',
        productName: 'Curette Gracey 1/2',
        lotNumber: 'LOT-2026-89A',
        patientName: 'Marie Dubois',
        dossierId: 'DOS-2024-001',
        usedAt: DateTime.now(),
        syncStatus: UsageSyncStatus.synced,
      ),
      UsageHistoryEntry(
        id: '2',
        idempotencyKey: 'UUID-2',
        labelCode: 'LOT-2',
        productName: 'Implant 3.5mm',
        lotNumber: 'LOT-2026-99B',
        patientName: 'Jean Moreau',
        dossierId: 'DOS-2024-045',
        usedAt: DateTime.now().subtract(const Duration(days: 20)),
        syncStatus: UsageSyncStatus.pending,
      ),
    ]);
  }

  @override
  Future<Either<Failure, void>> syncPendingEntries() async => const Right(null);
}

void main() {
  late FakeHistoryRepository fakeRepo;
  late GetPractitionerHistoryUseCase getHistoryUseCase;
  late HistoryBloc historyBloc;

  setUp(() {
    fakeRepo = FakeHistoryRepository();
    getHistoryUseCase = GetPractitionerHistoryUseCase(fakeRepo);
    historyBloc = HistoryBloc(getPractitionerHistoryUseCase: getHistoryUseCase);
  });

  tearDown(() {
    historyBloc.close();
  });

  test('Loads all history entries on HistoryLoadRequested', () {
    expectLater(
      historyBloc.stream,
      emitsInOrder([
        isA<HistoryState>().having((s) => s.status, 'status', HistoryStatus.loading),
        isA<HistoryState>()
            .having((s) => s.status, 'status', HistoryStatus.loaded)
            .having((s) => s.items.length, 'length', 2),
      ]),
    );

    historyBloc.add(const HistoryLoadRequested());
  });

  test('Filters pending sync entries correctly', () {
    expectLater(
      historyBloc.stream,
      emitsInOrder([
        isA<HistoryState>().having((s) => s.status, 'status', HistoryStatus.loading),
        isA<HistoryState>()
            .having((s) => s.status, 'status', HistoryStatus.loaded)
            .having((s) => s.items.length, 'length', 1)
            .having((s) => s.items.first.patientName, 'patient', 'Jean Moreau'),
      ]),
    );

    historyBloc.add(const HistoryLoadRequested(filter: 'pending'));
  });
}
