import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sterilization_cycle.dart';
import '../repositories/label_detail_repository.dart';

class GetCycleDetailsParams extends Equatable {
  final String cycleId;

  const GetCycleDetailsParams(this.cycleId);

  @override
  List<Object?> get props => [cycleId];
}

class GetCycleDetailsUseCase implements UseCase<SterilizationCycle, GetCycleDetailsParams> {
  final LabelDetailRepository repository;

  GetCycleDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, SterilizationCycle>> call(GetCycleDetailsParams params) {
    return repository.getCycleDetails(params.cycleId);
  }
}
