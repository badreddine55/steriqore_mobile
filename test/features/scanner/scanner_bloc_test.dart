import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/features/scanner/domain/entities/label.dart';
import 'package:steriqore_mobile/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:steriqore_mobile/features/scanner/domain/usecases/scan_label.dart';
import 'package:steriqore_mobile/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:steriqore_mobile/features/scanner/presentation/bloc/scanner_event.dart';
import 'package:steriqore_mobile/features/scanner/presentation/bloc/scanner_state.dart';

class FakeScannerRepository implements ScannerRepository {
  @override
  Future<Either<Failure, Label>> scanLabel(String rawCode) async {
    final upper = rawCode.toUpperCase();
    if (upper.contains('RECALLED') || upper.contains('03_RECALLED')) {
      return const Left(BlockingFailure(
        'Instrument is recalled and cannot be used.',
        statusCode: 410,
        recallReason: 'Biological indicator failed',
      ));
    }
    if (upper.contains('EXPIRED') || upper.contains('02_EXPIRED')) {
      return const Left(BlockingFailure(
        'Instrument has expired and cannot be used.',
        statusCode: 410,
      ));
    }
    return Right(Label(
      id: 101,
      code: rawCode,
      productName: 'Curette Gracey 1/2 Micro',
      reference: 'CUR-012',
      lotNumber: 'LOT-2026-89A',
      expirationDate: DateTime.now().add(const Duration(days: 180)),
    ));
  }

  @override
  Future<Either<Failure, Label>> getLabelDetails(String code) => scanLabel(code);

  @override
  Future<List<String>> getRecentScannedCodes() async => ['LOT-2026-89A'];

  @override
  Future<void> saveRecentCode(String code) async {}
}

void main() {
  late FakeScannerRepository fakeRepo;
  late ScanLabelUseCase scanLabelUseCase;
  late ScannerBloc scannerBloc;

  setUp(() {
    fakeRepo = FakeScannerRepository();
    scanLabelUseCase = ScanLabelUseCase(fakeRepo);
    scannerBloc = ScannerBloc(scanLabelUseCase: scanLabelUseCase);
  });

  tearDown(() {
    scannerBloc.close();
  });

  test('Initial state is ScannerInitial', () {
    expect(scannerBloc.state, equals(const ScannerInitial()));
  });

  test('ScannerInitRequested emits ScannerReady', () {
    expectLater(
      scannerBloc.stream,
      emitsInOrder([
        const ScannerReady(isTorchOn: false),
      ]),
    );

    scannerBloc.add(const ScannerInitRequested());
  });

  test('ScannerCodeDetected with valid code emits ScannerProcessing then ScannerSuccess', () {
    expectLater(
      scannerBloc.stream,
      emitsInOrder([
        const ScannerProcessing('01_VALID_INSTRUMENT'),
        isA<ScannerSuccess>().having((s) => s.label.code, 'code', '01_VALID_INSTRUMENT'),
      ]),
    );

    scannerBloc.add(const ScannerCodeDetected('01_VALID_INSTRUMENT'));
  });

  test('ScannerCodeDetected with recalled code triggers 410 Safety Gate (ScannerBlocked)', () {
    expectLater(
      scannerBloc.stream,
      emitsInOrder([
        const ScannerProcessing('03_RECALLED_INSTRUMENT'),
        isA<ScannerBlocked>()
            .having((s) => s.reason, 'reason', contains('recalled'))
            .having((s) => s.code, 'code', '03_RECALLED_INSTRUMENT'),
      ]),
    );

    scannerBloc.add(const ScannerCodeDetected('03_RECALLED_INSTRUMENT'));
  });
}
