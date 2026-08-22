import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cabinet_user.dart';
import '../repositories/admin_repository.dart';

class UpdateCabinetUserUseCase implements UseCase<CabinetUser, UpdateCabinetUserParams> {
  final AdminRepository repository;

  UpdateCabinetUserUseCase(this.repository);

  @override
  Future<Either<Failure, CabinetUser>> call(UpdateCabinetUserParams params) {
    return repository.updateUser(
      params.id,
      name: params.name,
      email: params.email,
      phone: params.phone,
      role: params.role,
      cabinetRoom: params.cabinetRoom,
      permissions: params.permissions,
    );
  }
}

class UpdateCabinetUserParams extends Equatable {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? cabinetRoom;
  final List<String>? permissions;

  const UpdateCabinetUserParams({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.cabinetRoom,
    this.permissions,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        cabinetRoom,
        permissions,
      ];
}
