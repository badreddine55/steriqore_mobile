import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/label.dart';
import '../repositories/scanner_repository.dart';

class GetLabelDetailsParams extends Equatable {
  final String code;

  const GetLabelDetailsParams(this.code);

  @override
  List<Object?> get props => [code];
}

class GetLabelDetailsUseCase implements UseCase<Label, GetLabelDetailsParams> {
  final ScannerRepository repository;

  GetLabelDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Label>> call(GetLabelDetailsParams params) {
    return repository.getLabelDetails(params.code);
  }
}
