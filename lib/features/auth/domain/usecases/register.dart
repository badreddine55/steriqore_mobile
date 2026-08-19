import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String? phone;
  final String cabinetCode;
  final String password;
  final String confirmPassword;
  final String role;

  const RegisterParams({
    required this.name,
    required this.email,
    this.phone,
    required this.cabinetCode,
    required this.password,
    required this.confirmPassword,
    this.role = 'practitioner',
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        cabinetCode,
        password,
        confirmPassword,
        role,
      ];
}

class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      cabinetCode: params.cabinetCode,
      password: params.password,
      confirmPassword: params.confirmPassword,
      role: params.role,
    );
  }
}
