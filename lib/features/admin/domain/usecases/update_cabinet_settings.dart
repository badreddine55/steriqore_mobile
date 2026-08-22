import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cabinet_settings.dart';
import '../repositories/admin_repository.dart';

class UpdateCabinetSettingsUseCase implements UseCase<CabinetSettings, UpdateCabinetSettingsParams> {
  final AdminRepository repository;

  UpdateCabinetSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, CabinetSettings>> call(UpdateCabinetSettingsParams params) {
    return repository.updateCabinetSettings(params.settings);
  }
}

class UpdateCabinetSettingsParams extends Equatable {
  final CabinetSettings settings;

  const UpdateCabinetSettingsParams(this.settings);

  @override
  List<Object?> get props => [settings];
}
