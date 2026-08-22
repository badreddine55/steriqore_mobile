import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        LoginRequestModel(email: email, password: password),
      );

      // Save token first
      await localDataSource.saveToken(response.token);

      // Fetch server-authoritative user profile & role via GET /auth/me
      UserModel authoritativeUser;
      try {
        authoritativeUser = await remoteDataSource.getMe();
      } catch (_) {
        authoritativeUser = response.user;
      }

      await localDataSource.saveUser(authoritativeUser);
      await localDataSource.saveRole(authoritativeUser.role);

      return Right(authoritativeUser.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.statusCode));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    String? phone,
    required String cabinetCode,
    required String password,
    required String confirmPassword,
    String role = 'practitioner',
  }) async {
    try {
      final response = await remoteDataSource.register(
        RegisterRequestModel(
          name: name,
          email: email,
          phone: phone,
          cabinetCode: cabinetCode,
          password: password,
          confirmPassword: confirmPassword,
          role: role,
        ),
      );

      await localDataSource.saveToken(response.token);
      final user = response.user;
      await localDataSource.saveUser(user);
      await localDataSource.saveRole(user.role);

      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.statusCode));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async {
    try {
      final cachedUser = await localDataSource.getUser();
      final token = await localDataSource.getToken();

      if (cachedUser != null && token != null && token.isNotEmpty) {
        return Right(cachedUser.toEntity());
      }

      return const Left(AuthFailure('No active biometric session. Please sign in with email/password.', 401));
    } catch (e) {
      return Left(ServerFailure('Biometric authentication failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> selectRole(String role) async {
    try {
      await localDataSource.saveRole(role);
      final currentUser = await localDataSource.getUser();
      if (currentUser != null) {
        final updatedUser = UserModel(
          id: currentUser.id,
          name: currentUser.name,
          email: currentUser.email,
          role: role,
          cabinetName: currentUser.cabinetName,
          cabinetRoom: currentUser.cabinetRoom,
          avatarUrl: currentUser.avatarUrl,
          createdAt: currentUser.createdAt,
        );
        await localDataSource.saveUser(updatedUser);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save selected role: $e'));
    }
  }

  @override
  Future<String?> getSavedRole() async {
    return await localDataSource.getRole();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {}
    await localDataSource.clearAuth();
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthFailure('No active session. Please log in.', 401));
      }

      // Query server via GET /auth/me for fresh role & permissions
      try {
        final remoteUser = await remoteDataSource.getMe();
        await localDataSource.saveUser(remoteUser);
        await localDataSource.saveRole(remoteUser.role);
        return Right(remoteUser.toEntity());
      } catch (_) {
        // Fallback to local cache if network is unavailable
        final cachedUser = await localDataSource.getUser();
        if (cachedUser != null) {
          return Right(cachedUser.toEntity());
        }
        return const Left(NetworkFailure('Could not connect to server and no cached profile found.'));
      }
    } on AuthException catch (e) {
      await localDataSource.clearAuth();
      return Left(AuthFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }
}
