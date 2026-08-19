import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../scanner/domain/entities/label.dart';
import '../entities/instrument_usage.dart';
import '../entities/patient.dart';

abstract class UsageRepository {
  Future<Either<Failure, List<Patient>>> getPatients({String? query});
  Future<Either<Failure, InstrumentUsage>> recordUsage({
    required Label label,
    required Patient patient,
    required String practitionerId,
    required String practitionerName,
    String? procedureType,
    String? notes,
    String? existingIdempotencyKey,
  });
  Future<Either<Failure, List<InstrumentUsage>>> getUsageHistory();
  Future<Either<Failure, void>> retrySyncItem(InstrumentUsage usage);
}
