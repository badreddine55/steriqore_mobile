import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cabinet_user.dart';
import '../repositories/admin_repository.dart';

class GetCabinetUsersUseCase implements UseCase<List<CabinetUser>, GetCabinetUsersParams> {
  final AdminRepository repository;

  GetCabinetUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<CabinetUser>>> call(GetCabinetUsersParams params) {
    return repository.getUsers(
      search: params.search,
      role: params.role,
      isActive: params.isActive,
    );
  }
}

class GetCabinetUsersParams extends Equatable {
  final String? search;
  final String? role;
  final bool? isActive;

  const GetCabinetUsersParams({
    this.search,
    this.role,
    this.isActive,
  });

  @override
  List<Object?> get props => [search, role, isActive];
}
