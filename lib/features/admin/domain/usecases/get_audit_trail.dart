import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_entry.dart';
import '../repositories/admin_repository.dart';

class GetAuditTrailUseCase implements UseCase<List<AuditEntry>, GetAuditTrailParams> {
  final AdminRepository repository;

  GetAuditTrailUseCase(this.repository);

  @override
  Future<Either<Failure, List<AuditEntry>>> call(GetAuditTrailParams params) {
    return repository.getAuditTrail(
      search: params.search,
      action: params.action,
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetAuditTrailParams extends Equatable {
  final String? search;
  final String? action;
  final int? userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetAuditTrailParams({
    this.search,
    this.action,
    this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        search,
        action,
        userId,
        startDate,
        endDate,
      ];
}
