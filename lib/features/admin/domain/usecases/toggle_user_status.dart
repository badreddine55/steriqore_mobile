import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cabinet_user.dart';
import '../repositories/admin_repository.dart';

class ToggleUserStatusUseCase implements UseCase<CabinetUser, ToggleUserStatusParams> {
  final AdminRepository repository;

  ToggleUserStatusUseCase(this.repository);

  @override
  Future<Either<Failure, CabinetUser>> call(ToggleUserStatusParams params) {
    return repository.toggleUserStatus(params.id, params.isActive);
  }
}

class ToggleUserStatusParams extends Equatable {
  final int id;
  final bool isActive;

  const ToggleUserStatusParams({
    required this.id,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, isActive];
}
