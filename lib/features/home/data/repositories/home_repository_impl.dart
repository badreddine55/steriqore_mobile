import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../usage/data/datasources/usage_local_datasource.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/dashboard_stats_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final UsageLocalDataSource usageLocalDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.usageLocalDataSource,
  });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final stats = await remoteDataSource.getStats();
      final pendingUsages = await usageLocalDataSource.getPendingQueue();

      final updated = DashboardStatsModel(
        todayScansCount: stats.todayScansCount + pendingUsages.length,
        pendingSyncCount: pendingUsages.length,
        activeAlertsCount: stats.activeAlertsCount,
        lastCycleTimestamp: stats.lastCycleTimestamp,
        activeAlertMessages: stats.activeAlertMessages,
      );

      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
