import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cycle_item.dart';
import '../repositories/label_detail_repository.dart';
import 'get_cycle_details.dart';

class GetCycleItemsUseCase implements UseCase<List<CycleItem>, GetCycleDetailsParams> {
  final LabelDetailRepository repository;

  GetCycleItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CycleItem>>> call(GetCycleDetailsParams params) {
    return repository.getCycleItems(params.cycleId);
  }
}
