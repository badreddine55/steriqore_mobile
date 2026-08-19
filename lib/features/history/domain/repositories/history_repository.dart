import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/usage_history_entry.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<UsageHistoryEntry>>> getPractitionerHistory({
    int page = 1,
    String? search,
    String? filterDate,
  });

  Future<Either<Failure, void>> syncPendingEntries();
}
