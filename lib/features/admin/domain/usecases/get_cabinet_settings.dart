import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cabinet_settings.dart';
import '../repositories/admin_repository.dart';

class GetCabinetSettingsUseCase implements UseCase<CabinetSettings, NoParams> {
  final AdminRepository repository;

  GetCabinetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, CabinetSettings>> call(NoParams params) {
    return repository.getCabinetSettings();
  }
}
