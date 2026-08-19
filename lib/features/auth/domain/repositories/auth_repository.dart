import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    String? phone,
    required String cabinetCode,
    required String password,
    required String confirmPassword,
    String role = 'practitioner',
  });

  Future<Either<Failure, User>> loginWithBiometrics();

  Future<Either<Failure, void>> selectRole(String role);

  Future<String?> getSavedRole();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<bool> isLoggedIn();
}
