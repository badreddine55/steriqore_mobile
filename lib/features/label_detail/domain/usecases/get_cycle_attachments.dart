import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/label_detail_repository.dart';
import 'get_cycle_details.dart';

class GetCycleAttachmentsUseCase implements UseCase<List<String>, GetCycleDetailsParams> {
  final LabelDetailRepository repository;

  GetCycleAttachmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(GetCycleDetailsParams params) {
    return repository.getCycleAttachments(params.cycleId);
  }
}
