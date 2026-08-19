import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/home_repository.dart';

class GetDashboardStatsUseCase implements UseCase<DashboardStats, NoParams> {
  final HomeRepository repository;

  GetDashboardStatsUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) {
    return repository.getDashboardStats();
  }
}
