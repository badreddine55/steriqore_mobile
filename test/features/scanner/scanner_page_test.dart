import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/features/scanner/domain/entities/label.dart';
import 'package:steriqore_mobile/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:steriqore_mobile/features/scanner/domain/usecases/scan_label.dart';
import 'package:steriqore_mobile/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:steriqore_mobile/features/scanner/presentation/bloc/scanner_event.dart';
import 'package:steriqore_mobile/features/scanner/presentation/bloc/scanner_state.dart';
import 'package:steriqore_mobile/features/scanner/presentation/pages/scanner_page.dart';
import 'package:steriqore_mobile/features/scanner/presentation/widgets/scan_feedback_banner.dart';

class MockScannerRepo implements ScannerRepository {
  Either<Failure, Label>? nextResult;
  int scanCallCount = 0;

  @override
  Future<Either<Failure, Label>> scanLabel(String rawCode) async {
    scanCallCount++;
    if (nextResult != null) return nextResult!;
    return Right(Label(
      id: 1,
      code: rawCode,
      productName: 'Curette Gracey 1/2',
      reference: 'CUR-01',
      lotNumber: 'LOT-2026-89A',
      expirationDate: DateTime.now().add(const Duration(days: 180)),
    ));
  }

  @override
  Future<Either<Failure, Label>> getLabelDetails(String code) => scanLabel(code);

  @override
  Future<List<String>> getRecentScannedCodes() async => ['LBL-2026-001'];

  @override
  Future<void> saveRecentCode(String code) async {}
}

void main() {
  late MockScannerRepo mockRepo;
  late ScanLabelUseCase scanLabelUseCase;
  late ScannerBloc scannerBloc;

  setUp(() {
    mockRepo = MockScannerRepo();
    scanLabelUseCase = ScanLabelUseCase(mockRepo);
    scannerBloc = ScannerBloc(scanLabelUseCase: scanLabelUseCase);
  });

  tearDown(() {
    scannerBloc.close();
  });

  Widget buildTestApp(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('ScannerPage launches with no ProviderNotFoundException', (tester) async {
    await tester.pumpWidget(buildTestApp(ScannerPage(
      scannerBloc: scannerBloc,
    )));
    await tester.pump();

    expect(find.text('QR & DataMatrix'), findsOneWidget);
    expect(find.text('Enter Code Manually'), findsOneWidget);
  });

  testWidgets('ScannerPage displays 404 Not Found inline banner with dismiss', (tester) async {
    await tester.pumpWidget(buildTestApp(ScannerPage(
      scannerBloc: scannerBloc,
    )));
    await tester.pump();

    scannerBloc.emit(const ScannerLabelNotFound(
      code: 'INVALID-99',
      message: 'Invalid code — no such label',
    ));
    await tester.pump();

    expect(find.byType(ScanFeedbackBanner), findsOneWidget);
    expect(find.text('Package Not Found'), findsOneWidget);
    expect(find.text('404'), findsOneWidget);
    expect(find.text('Invalid code — no such label'), findsOneWidget);
    expect(find.text('INVALID-99'), findsOneWidget);

    // Dismiss banner
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(scannerBloc.state, isA<ScannerScanning>());
  });

  testWidgets('ScannerPage displays 409 Already Used warning banner', (tester) async {
    await tester.pumpWidget(buildTestApp(ScannerPage(
      scannerBloc: scannerBloc,
    )));
    await tester.pump();

    scannerBloc.emit(const ScannerAlreadyUsed(
      code: 'LOT-USED-01',
      message: 'This instrument was already recorded as used',
    ));
    await tester.pump();

    expect(find.text('Package Already Used'), findsOneWidget);
    expect(find.text('409'), findsOneWidget);
    expect(find.text('This instrument was already recorded as used'), findsOneWidget);
  });

  testWidgets('ScannerPage displays 429 Rate Limited banner with cooldown countdown', (tester) async {
    await tester.pumpWidget(buildTestApp(ScannerPage(
      scannerBloc: scannerBloc,
    )));
    await tester.pump();

    scannerBloc.emit(const ScannerRateLimited(
      cooldownSeconds: 5,
      message: 'Scanning paused. Please wait 5 seconds before next scan.',
    ));
    await tester.pump();

    expect(find.text('Scanning Rate Limit'), findsOneWidget);
    expect(find.text('429'), findsOneWidget);
    expect(find.text('Scanning paused. Please wait 5 seconds before next scan. (5s cooldown)'), findsOneWidget);
  });

  testWidgets('ScannerPage displays Offline banner for queued scans', (tester) async {
    await tester.pumpWidget(buildTestApp(ScannerPage(
      scannerBloc: scannerBloc,
    )));
    await tester.pump();

    scannerBloc.emit(const ScannerOffline(
      code: 'LBL-OFFLINE-01',
      message: 'Saved — will sync when online',
    ));
    await tester.pump();

    expect(find.text('Offline Mode Active'), findsOneWidget);
    expect(find.text('OUTBOX'), findsOneWidget);
    expect(find.text('Saved — will sync when online'), findsOneWidget);
  });

  testWidgets('ScannerPage displays 410 Blocking Dialog requiring explicit acknowledgment', (tester) async {
    await tester.pumpWidget(buildTestApp(ScannerPage(
      scannerBloc: scannerBloc,
    )));
    await tester.pump();

    scannerBloc.emit(const ScannerLabelBlocked(
      code: 'LOT-EXPIRED-99',
      reason: 'This instrument is expired and cannot be used.',
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SAFETY COMPLIANCE GATE (410)'), findsOneWidget);
    expect(find.text('Instrument Blocked'), findsOneWidget);
    expect(find.text('This instrument is expired and cannot be used.'), findsOneWidget);
    expect(find.text('Acknowledge & Scan Next'), findsOneWidget);

    // Tap Acknowledge & Scan Next
    await tester.tap(find.text('Acknowledge & Scan Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(scannerBloc.state, isA<ScannerScanning>());
  });

  testWidgets('ScannerBloc debounces rapid duplicate barcode events', (tester) async {
    mockRepo.nextResult = Right(Label(
      id: 1,
      code: 'LBL-01',
      productName: 'Curette Gracey 1/2',
      reference: 'CUR-01',
      lotNumber: 'LOT-2026-89A',
      expirationDate: DateTime.now().add(const Duration(days: 180)),
    ));

    scannerBloc.add(const ScannerCodeDetected('LBL-01'));
    scannerBloc.add(const ScannerCodeDetected('LBL-01'));
    scannerBloc.add(const ScannerCodeDetected('LBL-01'));

    await tester.pump(const Duration(milliseconds: 100));

    expect(mockRepo.scanCallCount, equals(1));
  });
}
