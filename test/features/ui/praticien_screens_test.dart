import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/core/theme/app_theme.dart';
import 'package:steriqore_mobile/features/auth/domain/entities/user.dart';
import 'package:steriqore_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/login.dart';
import 'package:steriqore_mobile/features/auth/domain/usecases/logout.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:steriqore_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:steriqore_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:steriqore_mobile/features/history/domain/entities/usage_history_entry.dart';
import 'package:steriqore_mobile/features/history/domain/repositories/history_repository.dart';
import 'package:steriqore_mobile/features/history/domain/usecases/get_practitioner_history.dart';
import 'package:steriqore_mobile/features/history/presentation/bloc/history_bloc.dart';
import 'package:steriqore_mobile/features/history/presentation/bloc/history_state.dart';
import 'package:steriqore_mobile/features/history/presentation/pages/history_page.dart';
import 'package:steriqore_mobile/features/home/domain/entities/dashboard_stats.dart';
import 'package:steriqore_mobile/features/home/domain/repositories/home_repository.dart';
import 'package:steriqore_mobile/features/home/domain/usecases/get_dashboard_stats.dart';
import 'package:steriqore_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:steriqore_mobile/features/home/presentation/pages/home_page.dart';
import 'package:steriqore_mobile/features/label_detail/domain/entities/cycle_item.dart';
import 'package:steriqore_mobile/features/label_detail/domain/entities/sterilization_cycle.dart';
import 'package:steriqore_mobile/features/label_detail/domain/repositories/label_detail_repository.dart';
import 'package:steriqore_mobile/features/label_detail/domain/usecases/get_cycle_details.dart';
import 'package:steriqore_mobile/features/label_detail/presentation/bloc/label_detail_bloc.dart';
import 'package:steriqore_mobile/features/label_detail/presentation/bloc/label_detail_state.dart';
import 'package:steriqore_mobile/features/label_detail/presentation/pages/label_detail_page.dart';
import 'package:steriqore_mobile/features/scanner/domain/entities/label.dart';
import 'package:steriqore_mobile/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:steriqore_mobile/features/scanner/domain/usecases/get_label_details.dart';
import 'package:steriqore_mobile/features/scanner/domain/usecases/scan_label.dart';
import 'package:steriqore_mobile/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:steriqore_mobile/features/usage/domain/entities/instrument_usage.dart';
import 'package:steriqore_mobile/features/usage/domain/entities/patient.dart';
import 'package:steriqore_mobile/features/usage/domain/repositories/usage_repository.dart';
import 'package:steriqore_mobile/features/usage/domain/usecases/get_patients.dart';
import 'package:steriqore_mobile/features/usage/domain/usecases/record_usage.dart';
import 'package:steriqore_mobile/features/usage/presentation/bloc/usage_bloc.dart';
import 'package:steriqore_mobile/features/usage/presentation/bloc/usage_state.dart';
import 'package:steriqore_mobile/features/usage/presentation/pages/patient_selection_page.dart';
import 'package:steriqore_mobile/features/usage/presentation/pages/usage_confirmation_page.dart';
import 'package:steriqore_mobile/features/usage/presentation/pages/usage_success_page.dart';

class MockAuthRepo implements AuthRepository {
  @override
  Future<Either<Failure, User>> getCurrentUser() async => const Right(User(id: 1, name: 'Dupont', email: 'dr.dupont@steriqore.com'));
  @override
  Future<bool> isLoggedIn() async => true;
  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async =>
      const Right(User(id: 1, name: 'Dupont', email: 'dr.dupont@steriqore.com'));
  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    String? phone,
    required String cabinetCode,
    required String password,
    required String confirmPassword,
    String role = 'practitioner',
  }) async =>
      const Right(User(id: 1, name: 'Dupont', email: 'dr.dupont@steriqore.com'));
  @override
  Future<Either<Failure, User>> loginWithBiometrics() async =>
      const Right(User(id: 1, name: 'Dupont', email: 'dr.dupont@steriqore.com'));
  @override
  Future<Either<Failure, void>> selectRole(String role) async => const Right(null);
  @override
  Future<String?> getSavedRole() async => 'practitioner';
  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
}

class MockHomeRepo implements HomeRepository {
  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async => const Right(DashboardStats(
        todayScansCount: 5,
        pendingSyncCount: 1,
        activeAlertsCount: 0,
        lastCycleTimestamp: 'Today, 08:30',
      ));
}

class MockScannerRepo implements ScannerRepository {
  @override
  Future<Either<Failure, Label>> scanLabel(String rawCode) async => Right(Label(
        id: 1,
        code: rawCode,
        productName: 'Curette Gracey 1/2',
        reference: 'CUR-01',
        lotNumber: 'LOT-2026-89A',
        expirationDate: DateTime.now().add(const Duration(days: 180)),
      ));
  @override
  Future<Either<Failure, Label>> getLabelDetails(String code) => scanLabel(code);
  @override
  Future<List<String>> getRecentScannedCodes() async => ['LOT-2026-89A'];
  @override
  Future<void> saveRecentCode(String code) async {}
}

class MockLabelDetailRepo implements LabelDetailRepository {
  @override
  Future<Either<Failure, SterilizationCycle>> getCycleDetails(String cycleId) async => Right(SterilizationCycle(
        id: 89,
        cycleNumber: 'CYC-2026-089',
        autoclaveName: 'Melag Vacuklav 40B',
        sterilizationDate: DateTime.now().subtract(const Duration(days: 2)),
      ));
  @override
  Future<Either<Failure, List<CycleItem>>> getCycleItems(String cycleId) async => const Right([]);
  @override
  Future<Either<Failure, List<String>>> getCycleAttachments(String cycleId) async => const Right([]);
}

class MockUsageRepo implements UsageRepository {
  @override
  Future<Either<Failure, List<Patient>>> getPatients({String? query}) async => const Right([
        Patient(
          id: 'PAT-001',
          firstName: 'Marie',
          lastName: 'Dubois',
          dossierId: 'DOS-2024-001',
          allergies: [PatientAllergy(name: 'Latex', severity: AllergySeverity.moderate)],
        ),
      ]);
  @override
  Future<Either<Failure, InstrumentUsage>> recordUsage({
    required Label label,
    required Patient patient,
    required String practitionerId,
    required String practitionerName,
    String? procedureType,
    String? notes,
    String? existingIdempotencyKey,
  }) async =>
      Right(InstrumentUsage(
        id: '1',
        idempotencyKey: 'UUID-01',
        labelId: '1',
        labelCode: label.code,
        productName: label.productName,
        lotNumber: label.lotNumber,
        patientId: patient.id,
        patientName: patient.fullName,
        dossierId: patient.dossierId,
        practitionerId: practitionerId,
        practitionerName: practitionerName,
        usedAt: DateTime.now(),
      ));
  @override
  Future<Either<Failure, List<InstrumentUsage>>> getUsageHistory() async => const Right([]);
  @override
  Future<Either<Failure, void>> retrySyncItem(InstrumentUsage usage) async => const Right(null);
}

class MockHistoryRepo implements HistoryRepository {
  @override
  Future<Either<Failure, List<UsageHistoryEntry>>> getPractitionerHistory({
    int page = 1,
    String? search,
    String? filterDate,
  }) async =>
      Right([
        UsageHistoryEntry(
          id: '1',
          idempotencyKey: 'UUID-1',
          labelCode: 'LBL-01',
          productName: 'Curette Gracey 1/2',
          lotNumber: 'LOT-2026-89A',
          patientName: 'Marie Dubois',
          dossierId: 'DOS-2024-001',
          usedAt: DateTime.now(),
        ),
      ]);
  @override
  Future<Either<Failure, void>> syncPendingEntries() async => const Right(null);
}

void main() {
  late AuthBloc authBloc;
  late HomeBloc homeBloc;
  late ScannerBloc scannerBloc;
  late LabelDetailBloc labelDetailBloc;
  late UsageBloc usageBloc;
  late HistoryBloc historyBloc;

  setUp(() {
    final authRepo = MockAuthRepo();
    authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepo),
      logoutUseCase: LogoutUseCase(authRepo),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepo),
    )..emit(const Authenticated(User(id: 1, name: 'Dr. Dupont', email: 'doctor@cabinet.fr', role: 'practitioner')));

    final homeRepo = MockHomeRepo();
    homeBloc = HomeBloc(getDashboardStatsUseCase: GetDashboardStatsUseCase(homeRepo));

    final scannerRepo = MockScannerRepo();
    scannerBloc = ScannerBloc(scanLabelUseCase: ScanLabelUseCase(scannerRepo));

    final labelDetailRepo = MockLabelDetailRepo();
    labelDetailBloc = LabelDetailBloc(
      getLabelDetailsUseCase: GetLabelDetailsUseCase(scannerRepo),
      getCycleDetailsUseCase: GetCycleDetailsUseCase(labelDetailRepo),
    );

    final usageRepo = MockUsageRepo();
    usageBloc = UsageBloc(
      getPatientsUseCase: GetPatientsUseCase(usageRepo),
      recordUsageUseCase: RecordUsageUseCase(usageRepo),
    );

    final historyRepo = MockHistoryRepo();
    historyBloc = HistoryBloc(getPractitionerHistoryUseCase: GetPractitionerHistoryUseCase(historyRepo));
  });

  Widget buildTestApp(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: homeBloc),
        BlocProvider.value(value: scannerBloc),
        BlocProvider.value(value: labelDetailBloc),
        BlocProvider.value(value: usageBloc),
        BlocProvider.value(value: historyBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  testWidgets('LoginPage renders correctly', (tester) async {
    await tester.pumpWidget(buildTestApp(const LoginPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('HomePage renders dashboard stats and scan actions', (tester) async {
    await tester.pumpWidget(buildTestApp(const HomePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Scan Instrument Package'), findsOneWidget);
    expect(find.text("Today's Scans"), findsOneWidget);
    expect(find.text('Pending Sync'), findsOneWidget);
  });

  testWidgets('HomePage tapping logout opens confirmation dialog and triggers logout', (tester) async {
    await tester.pumpWidget(buildTestApp(HomePage(
      authBloc: authBloc,
      homeBloc: homeBloc,
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap logout button
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Sign Out'), findsWidgets);
    expect(find.text('Are you sure you want to end your session and sign out of STERIQORE?'), findsOneWidget);

    // Tap confirm Sign Out
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('LabelDetailPage renders verified product information', (tester) async {
    labelDetailBloc.emit(LabelDetailLoaded(
      label: Label(
        id: 1,
        code: 'LOT-2026-89A',
        productName: 'Curette Gracey 1/2',
        reference: 'CUR-01',
        lotNumber: 'LOT-2026-89A',
        expirationDate: DateTime.now().add(const Duration(days: 180)),
      ),
      cycle: null,
      isBlocked: false,
    ));

    await tester.pumpWidget(buildTestApp(LabelDetailPage(
      code: 'LOT-2026-89A',
      labelDetailBloc: labelDetailBloc,
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Traceability Verification'), findsOneWidget);
    expect(find.text('Curette Gracey 1/2'), findsOneWidget);
    expect(find.text('Use on Patient'), findsOneWidget);
  });

  testWidgets('PatientSelectionPage displays patient search and list', (tester) async {
    final testLabel = Label(
      id: 1,
      code: 'LBL-01',
      productName: 'Curette Gracey 1/2',
      reference: 'CUR-01',
      lotNumber: 'LOT-2026-89A',
      expirationDate: DateTime.now().add(const Duration(days: 180)),
    );

    usageBloc.emit(const UsageState(
      status: UsageFormStatus.patientsLoaded,
      patients: [
        Patient(
          id: 'PAT-001',
          firstName: 'Marie',
          lastName: 'Dubois',
          dossierId: 'DOS-2024-001',
          allergies: [PatientAllergy(name: 'Latex')],
        ),
      ],
    ));

    await tester.pumpWidget(buildTestApp(PatientSelectionPage(
      label: testLabel,
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Select Patient'), findsOneWidget);
    expect(find.text('Marie Dubois'), findsOneWidget);
    expect(find.text('Latex'), findsOneWidget);
  });

  testWidgets('UsageConfirmationPage renders complete audit trail summary', (tester) async {
    final testLabel = Label(
      id: 1,
      code: 'LBL-01',
      productName: 'Curette Gracey 1/2',
      reference: 'CUR-01',
      lotNumber: 'LOT-2026-89A',
      expirationDate: DateTime.now().add(const Duration(days: 180)),
    );

    const testPatient = Patient(
      id: 'PAT-001',
      firstName: 'Marie',
      lastName: 'Dubois',
      dossierId: 'DOS-2024-001',
    );

    await tester.pumpWidget(buildTestApp(UsageConfirmationPage(
      label: testLabel,
      patient: testPatient,
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Confirm Usage Record'), findsOneWidget);
    expect(find.text('Confirm & Sign Traceability'), findsOneWidget);
    expect(find.text('Marie Dubois'), findsOneWidget);
    expect(find.text('Curette Gracey 1/2'), findsOneWidget);
  });

  testWidgets('UsageSuccessPage displays confirmation and next actions', (tester) async {
    final testUsage = InstrumentUsage(
      id: '1',
      idempotencyKey: 'UUID-01',
      labelId: '1',
      labelCode: 'LBL-01',
      productName: 'Curette Gracey 1/2',
      lotNumber: 'LOT-2026-89A',
      patientId: 'PAT-001',
      patientName: 'Marie Dubois',
      dossierId: 'DOS-2024-001',
      practitionerId: '1',
      practitionerName: 'Dr. Practitioner',
      usedAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestApp(UsageSuccessPage(usage: testUsage)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Usage Recorded'), findsOneWidget);
    expect(find.text('Scan Another Instrument'), findsOneWidget);
    expect(find.text('Back to Dashboard'), findsOneWidget);
    expect(find.text('Marie Dubois'), findsOneWidget);
  });

  testWidgets('HistoryPage renders usage logs and filter chips', (tester) async {
    final testEntry = UsageHistoryEntry(
      id: '1',
      idempotencyKey: 'UUID-1',
      labelCode: 'LBL-01',
      productName: 'Curette Gracey 1/2',
      lotNumber: 'LOT-2026-89A',
      patientName: 'Marie Dubois',
      dossierId: 'DOS-2024-001',
      usedAt: DateTime.now(),
    );

    historyBloc.emit(HistoryState(
      status: HistoryStatus.loaded,
      items: [testEntry],
      activeFilter: 'all',
    ));

    await tester.pumpWidget(buildTestApp(const HistoryPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Traceability History'), findsOneWidget);
    expect(find.text('All Records'), findsOneWidget);
    expect(find.text('Pending Sync'), findsOneWidget);
    expect(find.text('Marie Dubois'), findsOneWidget);
  });
}
