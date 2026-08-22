import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cabinet_user.dart';
import '../repositories/admin_repository.dart';

class CreateCabinetUserUseCase implements UseCase<CabinetUser, CreateCabinetUserParams> {
  final AdminRepository repository;

  CreateCabinetUserUseCase(this.repository);

  @override
  Future<Either<Failure, CabinetUser>> call(CreateCabinetUserParams params) {
    return repository.createUser(
      name: params.name,
      email: params.email,
      phone: params.phone,
      role: params.role,
      password: params.password,
      cabinetRoom: params.cabinetRoom,
      permissions: params.permissions,
    );
  }
}

class CreateCabinetUserParams extends Equatable {
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String password;
  final String? cabinetRoom;
  final List<String>? permissions;

  const CreateCabinetUserParams({
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.password,
    this.cabinetRoom,
    this.permissions,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        role,
        password,
        cabinetRoom,
        permissions,
      ];
}
