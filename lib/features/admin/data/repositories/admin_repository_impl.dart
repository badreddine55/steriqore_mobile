import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/entities/cabinet_settings.dart';
import '../../domain/entities/cabinet_user.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CabinetUser>>> getUsers({
    String? search,
    String? role,
    bool? isActive,
  }) async {
    try {
      final models = await remoteDataSource.getUsers(
        search: search,
        role: role,
        isActive: isActive,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CabinetUser>> getUserById(int id) async {
    try {
      final model = await remoteDataSource.getUserById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CabinetUser>> createUser({
    required String name,
    required String email,
    String? phone,
    required String role,
    required String password,
    String? cabinetRoom,
    List<String>? permissions,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'password': password,
        'cabinet_room': cabinetRoom,
        'permissions': permissions ?? [],
      };
      final model = await remoteDataSource.createUser(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CabinetUser>> updateUser(
    int id, {
    String? name,
    String? email,
    String? phone,
    String? role,
    String? cabinetRoom,
    List<String>? permissions,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (role != null) data['role'] = role;
      if (cabinetRoom != null) data['cabinet_room'] = cabinetRoom;
      if (permissions != null) data['permissions'] = permissions;

      final model = await remoteDataSource.updateUser(id, data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CabinetUser>> toggleUserStatus(int id, bool isActive) async {
    try {
      final model = await remoteDataSource.toggleUserStatus(id, isActive);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuditEntry>>> getAuditTrail({
    String? search,
    String? action,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await remoteDataSource.getAuditTrail(
        search: search,
        action: action,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CabinetSettings>> getCabinetSettings() async {
    try {
      final model = await remoteDataSource.getCabinetSettings();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CabinetSettings>> updateCabinetSettings(CabinetSettings settings) async {
    try {
      final data = {
        'cabinet_name': settings.cabinetName,
        'cabinet_code': settings.cabinetCode,
        'address': settings.address,
        'phone': settings.phone,
        'email': settings.email,
        'dlc_threshold_days': settings.dlcThresholdDays,
        'low_stock_threshold': settings.lowStockThreshold,
        'enable_biometrics': settings.enableBiometrics,
        'auto_sync_enabled': settings.autoSyncEnabled,
        'primary_autoclave_id': settings.primaryAutoclaveId,
      };
      final model = await remoteDataSource.updateCabinetSettings(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
