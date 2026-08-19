import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/label.dart';
import '../repositories/scanner_repository.dart';

class ScanLabelParams extends Equatable {
  final String rawCode;

  const ScanLabelParams(this.rawCode);

  @override
  List<Object?> get props => [rawCode];
}

class ScanLabelUseCase implements UseCase<Label, ScanLabelParams> {
  final ScannerRepository repository;

  ScanLabelUseCase(this.repository);

  @override
  Future<Either<Failure, Label>> call(ScanLabelParams params) {
    return repository.scanLabel(params.rawCode);
  }
}
