import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/audit_entry.dart';
import '../entities/cabinet_settings.dart';
import '../entities/cabinet_user.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<CabinetUser>>> getUsers({
    String? search,
    String? role,
    bool? isActive,
  });

  Future<Either<Failure, CabinetUser>> getUserById(int id);

  Future<Either<Failure, CabinetUser>> createUser({
    required String name,
    required String email,
    String? phone,
    required String role,
    required String password,
    String? cabinetRoom,
    List<String>? permissions,
  });

  Future<Either<Failure, CabinetUser>> updateUser(
    int id, {
    String? name,
    String? email,
    String? phone,
    String? role,
    String? cabinetRoom,
    List<String>? permissions,
  });

  Future<Either<Failure, CabinetUser>> toggleUserStatus(int id, bool isActive);

  Future<Either<Failure, List<AuditEntry>>> getAuditTrail({
    String? search,
    String? action,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, CabinetSettings>> getCabinetSettings();

  Future<Either<Failure, CabinetSettings>> updateCabinetSettings(CabinetSettings settings);
}
