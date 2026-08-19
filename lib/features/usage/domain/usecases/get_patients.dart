import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/usage_repository.dart';

class GetPatientsParams extends Equatable {
  final String? query;

  const GetPatientsParams({this.query});

  @override
  List<Object?> get props => [query];
}

class GetPatientsUseCase implements UseCase<List<Patient>, GetPatientsParams> {
  final UsageRepository repository;

  GetPatientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Patient>>> call(GetPatientsParams params) {
    return repository.getPatients(query: params.query);
  }
}
