import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../../scanner/domain/entities/label.dart';
import '../../domain/entities/instrument_usage.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/usage_repository.dart';
import '../datasources/usage_local_datasource.dart';
import '../datasources/usage_remote_datasource.dart';
import '../models/usage_request_model.dart';
import '../models/usage_response_model.dart';

class UsageRepositoryImpl implements UsageRepository {
  final UsageRemoteDataSource remoteDataSource;
  final UsageLocalDataSource localDataSource;

  UsageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Patient>>> getPatients({String? query}) async {
    try {
      final patients = await remoteDataSource.getPatients(query: query);
      await localDataSource.cachePatients(patients);
      return Right(patients.map((e) => e.toEntity()).toList());
    } catch (_) {
      final cached = await localDataSource.getCachedPatients();
      if (cached.isNotEmpty) {
        return Right(cached.map((e) => e.toEntity()).toList());
      }
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, InstrumentUsage>> recordUsage({
    required Label label,
    required Patient patient,
    required String practitionerId,
    required String practitionerName,
    String? procedureType,
    String? notes,
    String? existingIdempotencyKey,
  }) async {
    if (label.isBlocked) {
      return Left(BlockingFailure(
        label.status == LabelStatusType.recalled
            ? 'SAFETY BLOCK: Recalled instrument cannot be recorded.'
            : 'SAFETY BLOCK: Expired instrument cannot be used on patient.',
        statusCode: 410,
        recallReason: label.recallReason,
      ));
    }

    final key = existingIdempotencyKey ?? IdempotencyKeyGenerator.generate();
    final now = DateTime.now();

    final localRecord = UsageResponseModel(
      id: key,
      idempotencyKey: key,
      labelId: label.id.toString(),
      labelCode: label.code,
      productName: label.productName,
      lotNumber: label.lotNumber,
      patientId: patient.id,
      patientName: patient.fullName,
      dossierId: patient.dossierId,
      patientAllergies: patient.allergies.map((a) => a.name).toList(),
      practitionerId: practitionerId,
      practitionerName: practitionerName,
      usedAt: now,
      syncStatus: UsageSyncStatus.pending,
      procedureType: procedureType,
      notes: notes,
    );

    // Save to local offline outbox first (never lose clinical audit data)
    await localDataSource.addToPendingQueue(localRecord);

    try {
      final request = UsageRequestModel(
        patientId: patient.id,
        practitionerId: practitionerId,
        usedAt: DateFormatter.formatIso(now),
        idempotencyKey: key,
        procedureType: procedureType,
        notes: notes,
      );

      final response = await remoteDataSource.recordUsage(
        labelId: label.id.toString(),
        request: request,
      );

      final syncedRecord = UsageResponseModel(
        id: response.id,
        idempotencyKey: key,
        labelId: label.id.toString(),
        labelCode: label.code,
        productName: label.productName,
        lotNumber: label.lotNumber,
        patientId: patient.id,
        patientName: patient.fullName,
        dossierId: patient.dossierId,
        patientAllergies: patient.allergies.map((a) => a.name).toList(),
        practitionerId: practitionerId,
        practitionerName: practitionerName,
        usedAt: now,
        syncStatus: UsageSyncStatus.synced,
        procedureType: procedureType,
        notes: notes,
      );

      await localDataSource.updateUsage(syncedRecord);
      return Right(syncedRecord.toEntity());
    } on BlockingException catch (e) {
      final failedRecord = UsageResponseModel(
        id: key,
        idempotencyKey: key,
        labelId: label.id.toString(),
        labelCode: label.code,
        productName: label.productName,
        lotNumber: label.lotNumber,
        patientId: patient.id,
        patientName: patient.fullName,
        dossierId: patient.dossierId,
        patientAllergies: patient.allergies.map((a) => a.name).toList(),
        practitionerId: practitionerId,
        practitionerName: practitionerName,
        usedAt: now,
        syncStatus: e.statusCode == 409 ? UsageSyncStatus.synced : UsageSyncStatus.failed,
        errorMessage: e.message,
        procedureType: procedureType,
        notes: notes,
      );
      await localDataSource.updateUsage(failedRecord);

      if (e.statusCode == 409) {
        return Right(failedRecord.toEntity());
      }
      return Left(BlockingFailure(e.message, statusCode: e.statusCode, recallReason: e.recallReason));
    } catch (_) {
      // Offline / Network error: Saved to queue with pending status
      return Right(localRecord.toEntity());
    }
  }

  @override
  Future<Either<Failure, List<InstrumentUsage>>> getUsageHistory() async {
    try {
      final all = await localDataSource.getAllHistory();
      if (all.isEmpty) {
        // Return starter records
        final sample = [
          UsageResponseModel(
            id: '1',
            idempotencyKey: 'UUID-001',
            labelId: '101',
            labelCode: 'LOT-2026-89A-001',
            productName: 'Curette Gracey 1/2 Micro',
            lotNumber: 'LOT-2026-89A',
            patientId: 'PAT-001',
            patientName: 'Marie Dubois',
            dossierId: 'DOS-2024-001',
            practitionerId: '1',
            practitionerName: 'Dr. Practitioner',
            usedAt: DateTime.now().subtract(const Duration(minutes: 15)),
            syncStatus: UsageSyncStatus.synced,
          ),
          UsageResponseModel(
            id: '2',
            idempotencyKey: 'UUID-002',
            labelId: '104',
            labelCode: 'LOT-2026-99B-004',
            productName: 'Implant Titane 3.5mm Grade V',
            lotNumber: 'LOT-2026-99B',
            patientId: 'PAT-002',
            patientName: 'Jean Moreau',
            dossierId: 'DOS-2024-045',
            practitionerId: '1',
            practitionerName: 'Dr. Practitioner',
            usedAt: DateTime.now().subtract(const Duration(hours: 1)),
            syncStatus: UsageSyncStatus.synced,
          ),
        ];
        for (final item in sample) {
          await localDataSource.updateUsage(item);
        }
        return Right(sample.map((e) => e.toEntity()).toList());
      }
      return Right(all.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> retrySyncItem(InstrumentUsage usage) async {
    try {
      final request = UsageRequestModel(
        patientId: usage.patientId,
        practitionerId: usage.practitionerId,
        usedAt: DateFormatter.formatIso(usage.usedAt),
        idempotencyKey: usage.idempotencyKey,
        procedureType: usage.procedureType,
        notes: usage.notes,
      );

      await remoteDataSource.recordUsage(
        labelId: usage.labelId,
        request: request,
      );

      final updated = UsageResponseModel(
        id: usage.id,
        idempotencyKey: usage.idempotencyKey,
        labelId: usage.labelId,
        labelCode: usage.labelCode,
        productName: usage.productName,
        lotNumber: usage.lotNumber,
        patientId: usage.patientId,
        patientName: usage.patientName,
        dossierId: usage.dossierId,
        patientAllergies: usage.patientAllergies,
        practitionerId: usage.practitionerId,
        practitionerName: usage.practitionerName,
        usedAt: usage.usedAt,
        syncStatus: UsageSyncStatus.synced,
        procedureType: usage.procedureType,
        notes: usage.notes,
      );

      await localDataSource.updateUsage(updated);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
