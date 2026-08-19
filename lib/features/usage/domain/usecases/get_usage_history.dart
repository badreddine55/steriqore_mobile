import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/instrument_usage.dart';
import '../repositories/usage_repository.dart';

class GetUsageHistoryUseCase implements UseCase<List<InstrumentUsage>, NoParams> {
  final UsageRepository repository;

  GetUsageHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<InstrumentUsage>>> call(NoParams params) {
    return repository.getUsageHistory();
  }
}
