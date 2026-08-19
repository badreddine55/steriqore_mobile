import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../scanner/domain/entities/label.dart';
import '../entities/instrument_usage.dart';
import '../entities/patient.dart';
import '../repositories/usage_repository.dart';

class RecordUsageParams extends Equatable {
  final Label label;
  final Patient patient;
  final String practitionerId;
  final String practitionerName;
  final String? procedureType;
  final String? notes;
  final String? existingIdempotencyKey;

  const RecordUsageParams({
    required this.label,
    required this.patient,
    required this.practitionerId,
    required this.practitionerName,
    this.procedureType,
    this.notes,
    this.existingIdempotencyKey,
  });

  @override
  List<Object?> get props => [
        label,
        patient,
        practitionerId,
        practitionerName,
        procedureType,
        notes,
        existingIdempotencyKey,
      ];
}

class RecordUsageUseCase implements UseCase<InstrumentUsage, RecordUsageParams> {
  final UsageRepository repository;

  RecordUsageUseCase(this.repository);

  @override
  Future<Either<Failure, InstrumentUsage>> call(RecordUsageParams params) {
    return repository.recordUsage(
      label: params.label,
      patient: params.patient,
      practitionerId: params.practitionerId,
      practitionerName: params.practitionerName,
      procedureType: params.procedureType,
      notes: params.notes,
      existingIdempotencyKey: params.existingIdempotencyKey,
    );
  }
}
