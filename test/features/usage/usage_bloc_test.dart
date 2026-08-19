import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/features/scanner/domain/entities/label.dart';
import 'package:steriqore_mobile/features/usage/domain/entities/instrument_usage.dart';
import 'package:steriqore_mobile/features/usage/domain/entities/patient.dart';
import 'package:steriqore_mobile/features/usage/domain/repositories/usage_repository.dart';
import 'package:steriqore_mobile/features/usage/domain/usecases/get_patients.dart';
import 'package:steriqore_mobile/features/usage/domain/usecases/record_usage.dart';
import 'package:steriqore_mobile/features/usage/presentation/bloc/usage_bloc.dart';
import 'package:steriqore_mobile/features/usage/presentation/bloc/usage_event.dart';
import 'package:steriqore_mobile/features/usage/presentation/bloc/usage_state.dart';

class FakeUsageRepository implements UsageRepository {
  @override
  Future<Either<Failure, List<Patient>>> getPatients({String? query}) async {
    return const Right([
      Patient(
        id: 'PAT-001',
        firstName: 'Marie',
        lastName: 'Dubois',
        dossierId: 'DOS-2024-001',
        allergies: [PatientAllergy(name: 'Latex', severity: AllergySeverity.moderate)],
      ),
    ]);
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
      return const Left(BlockingFailure('Instrument is expired/recalled.', statusCode: 410));
    }

    return Right(InstrumentUsage(
      id: 'REC-1',
      idempotencyKey: existingIdempotencyKey ?? 'UUID-1234',
      labelId: label.id.toString(),
      labelCode: label.code,
      productName: label.productName,
      lotNumber: label.lotNumber,
      patientId: patient.id,
      patientName: patient.fullName,
      dossierId: patient.dossierId,
      practitionerId: practitionerId,
      practitionerName: practitionerName,
      usedAt: DateTime.now(),
      syncStatus: UsageSyncStatus.synced,
    ));
  }

  @override
  Future<Either<Failure, List<InstrumentUsage>>> getUsageHistory() async => const Right([]);

  @override
  Future<Either<Failure, void>> retrySyncItem(InstrumentUsage usage) async => const Right(null);
}

void main() {
  late FakeUsageRepository fakeRepo;
  late GetPatientsUseCase getPatientsUseCase;
  late RecordUsageUseCase recordUsageUseCase;
  late UsageBloc usageBloc;

  setUp(() {
    fakeRepo = FakeUsageRepository();
    getPatientsUseCase = GetPatientsUseCase(fakeRepo);
    recordUsageUseCase = RecordUsageUseCase(fakeRepo);
    usageBloc = UsageBloc(
      getPatientsUseCase: getPatientsUseCase,
      recordUsageUseCase: recordUsageUseCase,
    );
  });

  tearDown(() {
    usageBloc.close();
  });

  test('Loads patients on UsageLoadPatientsRequested', () {
    expectLater(
      usageBloc.stream,
      emitsInOrder([
        isA<UsageState>().having((s) => s.status, 'status', UsageFormStatus.loadingPatients),
        isA<UsageState>()
            .having((s) => s.status, 'status', UsageFormStatus.patientsLoaded)
            .having((s) => s.patients.length, 'patients', 1),
      ]),
    );

    usageBloc.add(const UsageLoadPatientsRequested());
  });

  test('Requires patient before submission', () {
    final validLabel = Label(
      id: 1,
      code: 'LBL-01',
      productName: 'Curette Gracey',
      reference: 'REF-1',
      lotNumber: 'LOT-1',
      expirationDate: DateTime.now().add(const Duration(days: 100)),
    );

    expectLater(
      usageBloc.stream,
      emitsInOrder([
        isA<UsageState>()
            .having((s) => s.status, 'status', UsageFormStatus.failure)
            .having((s) => s.errorMessage, 'error', contains('patient must be selected')),
      ]),
    );

    usageBloc.add(UsageSubmitRequested(
      label: validLabel,
      practitionerId: '1',
      practitionerName: 'Dr. Dupont',
    ));
  });

  test('Records usage successfully when patient is selected', () async {
    final patient = const Patient(
      id: 'PAT-001',
      firstName: 'Marie',
      lastName: 'Dubois',
      dossierId: 'DOS-2024-001',
    );

    final validLabel = Label(
      id: 1,
      code: 'LBL-01',
      productName: 'Curette Gracey',
      reference: 'REF-1',
      lotNumber: 'LOT-1',
      expirationDate: DateTime.now().add(const Duration(days: 100)),
    );

    usageBloc.add(UsagePatientSelectedEvent(patient));
    await Future.delayed(Duration.zero);

    expectLater(
      usageBloc.stream,
      emitsInOrder([
        isA<UsageState>().having((s) => s.status, 'status', UsageFormStatus.submitting),
        isA<UsageState>()
            .having((s) => s.status, 'status', UsageFormStatus.success)
            .having((s) => s.recordedUsage?.patientName, 'patientName', 'Marie Dubois'),
      ]),
    );

    usageBloc.add(UsageSubmitRequested(
      label: validLabel,
      practitionerId: '1',
      practitionerName: 'Dr. Dupont',
    ));
  });
}
