import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../usage/data/datasources/usage_local_datasource.dart';
import '../../domain/entities/usage_history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';
import '../models/usage_history_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final UsageLocalDataSource usageLocalDataSource;

  HistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.usageLocalDataSource,
  });

  @override
  Future<Either<Failure, List<UsageHistoryEntry>>> getPractitionerHistory({
    int page = 1,
    String? search,
    String? filterDate,
  }) async {
    try {
      final localList = await usageLocalDataSource.getAllHistory();
      final remoteList = await remoteDataSource.getHistory(
        page: page,
        search: search,
        filterDate: filterDate,
      );

      final combined = <String, UsageHistoryModel>{};

      for (final r in remoteList) {
        combined[r.idempotencyKey] = r;
      }

      for (final l in localList) {
        combined[l.idempotencyKey] = UsageHistoryModel(
          id: l.id,
          idempotencyKey: l.idempotencyKey,
          labelCode: l.labelCode,
          productName: l.productName,
          lotNumber: l.lotNumber,
          patientName: l.patientName,
          dossierId: l.dossierId ?? 'DOS-2026',
          usedAt: l.usedAt,
          syncStatus: l.syncStatus,
          procedureType: l.procedureType,
          notes: l.notes,
        );
      }

      var resultList = combined.values.toList();
      resultList.sort((a, b) => b.usedAt.compareTo(a.usedAt));

      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase().trim();
        resultList = resultList.where((item) {
          return item.patientName.toLowerCase().contains(q) ||
              item.productName.toLowerCase().contains(q) ||
              item.lotNumber.toLowerCase().contains(q) ||
              item.dossierId.toLowerCase().contains(q);
        }).toList();
      }

      return Right(resultList.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingEntries() async {
    return const Right(null);
  }
}
