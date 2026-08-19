import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steriqore_mobile/models/user_model.dart';
import 'package:steriqore_mobile/roles/practitioner/blocs/label_detail/label_detail_bloc.dart';
import 'package:steriqore_mobile/roles/practitioner/blocs/label_detail/label_detail_state.dart';
import 'package:steriqore_mobile/roles/practitioner/blocs/scanner/scanner_bloc.dart';
import 'package:steriqore_mobile/roles/practitioner/blocs/scanner/scanner_event.dart';
import 'package:steriqore_mobile/roles/practitioner/blocs/usage/usage_bloc.dart';
import 'package:steriqore_mobile/roles/practitioner/blocs/usage/usage_event.dart';
import 'package:steriqore_mobile/roles/practitioner/models/label_model.dart';
import 'package:steriqore_mobile/roles/practitioner/models/patient_model.dart';
import 'package:steriqore_mobile/roles/practitioner/models/usage_model.dart';
import 'package:steriqore_mobile/roles/practitioner/offline/scan_outbox.dart';
import 'package:steriqore_mobile/roles/practitioner/screens/history/usage_history_screen.dart';
import 'package:steriqore_mobile/roles/practitioner/screens/home/practitioner_dashboard_screen.dart';
import 'package:steriqore_mobile/roles/practitioner/screens/label/label_detail_screen.dart';
import 'package:steriqore_mobile/roles/practitioner/screens/scanner/scanner_screen.dart';
import 'package:steriqore_mobile/roles/practitioner/screens/usage/usage_confirmation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final testUser = UserModel(
    id: 1,
    name: 'Dr. John Watson',
    email: 'dr.watson@steriqore.com',
  );

  final validLabel = LabelModel(
    id: 10,
    code: 'LOT-2026-89A-001',
    productName: 'Implant Titane 3.5mm Grade V',
    reference: 'IMP-TIT-35',
    lotNumber: 'LOT-2026-89A',
    expirationDate: DateTime.now().add(const Duration(days: 180)),
    status: LabelStatus.valid,
    cycleId: 89,
    cycleNumber: 'CYC-089',
    autoclaveName: 'Melag Vacuklav 40B',
    sterilizationDate: DateTime.now().subtract(const Duration(days: 2)),
  );

  final blockedLabel = LabelModel(
    id: 11,
    code: 'LOT-2025-RECALL-99',
    productName: 'Endodontic Files Pack 25mm',
    reference: 'ENDO-25MM',
    lotNumber: 'LOT-2025-99',
    expirationDate: DateTime.now().subtract(const Duration(days: 10)), // Expired DLC
    status: LabelStatus.recalled,
    recallReason: 'Manufacturer recall: Micro-crack defect detected in batch #99',
  );

  final testPatient = const PatientModel(
    id: 50,
    identifier: 'PAT-2026-089',
    firstName: 'Sophie',
    lastName: 'Laurent',
    allergies: ['Penicillin'],
    cabinetRoom: 'Fauteuil 1',
  );

  group('Practitioner Role - Scanner Screen Tests', () {
    testWidgets('Scanner screen renders and triggers manual entry modal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScannerScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Manual Entry'), findsOneWidget);
      expect(find.text('DataMatrix & QR Active'), findsOneWidget);

      // Tap Manual Entry button
      await tester.tap(find.text('Manual Entry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Manual Code Entry'), findsOneWidget);
      expect(find.text('Verify Label'), findsOneWidget);
    });

    testWidgets('Scanner shows permission error view on permission denied event', (tester) async {
      final scannerBloc = ScannerBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: ScannerScreen(scannerBloc: scannerBloc),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      scannerBloc.add(const ScannerPermissionDenied());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Camera Permission Denied'), findsOneWidget);
      expect(find.text('Enter Code Manually'), findsOneWidget);
      expect(find.text('Retry Camera Access'), findsOneWidget);
    });
  });

  group('Practitioner Role - Label Detail & Compliance Block Tests', () {
    testWidgets('Valid label displays conformity pass and active patient record CTA', (tester) async {
      final labelDetailBloc = LabelDetailBloc();
      labelDetailBloc.emit(LabelDetailLoaded(label: validLabel, isOffline: false));

      await tester.pumpWidget(
        MaterialApp(
          home: LabelDetailScreen(
            code: validLabel.code,
            initialLabel: validLabel,
            labelDetailBloc: labelDetailBloc,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Implant Titane 3.5mm Grade V'), findsOneWidget);
      expect(find.text('VALIDATED / READY'), findsOneWidget);
      expect(find.text('Record Patient Usage'), findsOneWidget);
    });

    testWidgets('410 Blocked/Expired label renders safety banner and locks recording CTA', (tester) async {
      final labelDetailBloc = LabelDetailBloc();
      labelDetailBloc.emit(LabelDetailBlocked(label: blockedLabel, reason: 'Safety Block'));

      await tester.pumpWidget(
        MaterialApp(
          home: LabelDetailScreen(
            code: blockedLabel.code,
            initialLabel: blockedLabel,
            labelDetailBloc: labelDetailBloc,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Safety Block Banner is present
      expect(find.text('CRITICAL COMPLIANCE GATE: INSTRUMENT BLOCKED'), findsOneWidget);
      expect(find.text('RECALLED / BLOCKED'), findsOneWidget);

      // Verify CTA is strictly locked
      expect(find.text('Recording Locked (Safety Compliance)'), findsOneWidget);
      expect(find.text('Record Patient Usage'), findsNothing);
    });
  });

  group('Practitioner Role - Usage Confirmation & Mandatory Patient Tests', () {
    testWidgets('Submit button is disabled until a patient is picked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UsageConfirmationScreen(label: validLabel),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Select a Patient to Confirm'), findsOneWidget);
      expect(find.text('ASSIGN TO PATIENT (REQUIRED)'), findsOneWidget);

      // Verify patient picker initial state
      expect(find.text('Select Patient (Mandatory)'), findsOneWidget);
    });

    testWidgets('Selecting patient enables submit button with audit summary', (tester) async {
      final usageBloc = UsageBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: UsageConfirmationScreen(
            label: validLabel,
            usageBloc: usageBloc,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Select patient in bloc
      usageBloc.add(UsagePatientSelected(testPatient));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Confirm & Record Usage'), findsOneWidget);
      expect(find.text(testPatient.fullName), findsOneWidget);
      expect(find.text('Dossier: ${testPatient.identifier}'), findsOneWidget);
    });
  });

  group('Practitioner Role - Offline Outbox & Idempotency Tests', () {
    testWidgets('ScanOutbox saves pending usage item with client-side UUID key', (tester) async {
      final usage = UsageModel(
        idempotencyKey: 'UUID-TEST-9988-7766',
        labelId: validLabel.id,
        labelCode: validLabel.code,
        productName: validLabel.productName,
        lotNumber: validLabel.lotNumber,
        patientId: testPatient.id,
        patientName: testPatient.fullName,
        practitionerId: testUser.id,
        practitionerName: testUser.name,
        usedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await ScanOutbox.addToQueue(usage);

      final queue = await ScanOutbox.getAllQueue();
      expect(queue.length, 1);
      expect(queue.first.idempotencyKey, 'UUID-TEST-9988-7766');
      expect(queue.first.syncStatus, SyncStatus.pending);

      // Update status to synced
      await ScanOutbox.updateItem(usage.copyWith(syncStatus: SyncStatus.synced));
      final pending = await ScanOutbox.getPendingQueue();
      expect(pending.length, 0);
    });
  });

  group('Practitioner Role - Dashboard & History Navigation', () {
    testWidgets('Practitioner dashboard renders welcome and action cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PractitionerDashboardScreen(user: testUser),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(testUser.name), findsOneWidget);
      expect(find.text('PRACTITIONER ROLE'), findsOneWidget);
      expect(find.text('Scan Instrument Package'), findsOneWidget);
      expect(find.text('Manual Entry'), findsOneWidget);
      expect(find.text('Usage History'), findsOneWidget);
    });

    testWidgets('Usage history screen renders search and filter chips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UsageHistoryScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Usage Traceability History'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
    });
  });
}
