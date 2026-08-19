import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/label_detail/presentation/pages/label_detail_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/scanner/domain/entities/label.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/usage/domain/entities/instrument_usage.dart';
import '../../features/usage/domain/entities/patient.dart';
import '../../features/usage/presentation/pages/patient_selection_page.dart';
import '../../features/usage/presentation/pages/usage_confirmation_page.dart';
import '../../features/usage/presentation/pages/usage_success_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/scanner',
      name: 'scanner',
      builder: (context, state) => const ScannerPage(),
    ),
    GoRoute(
      path: '/label/:code',
      name: 'label-detail',
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? 'LBL-01';
        return LabelDetailPage(code: code);
      },
    ),
    GoRoute(
      path: '/usage/patient-select',
      name: 'usage-patient-select',
      builder: (context, state) {
        final label = state.extra as Label? ??
            Label(
              id: 1,
              code: 'LBL-01',
              productName: 'Dental Instrument',
              reference: 'REF-01',
              lotNumber: 'LOT-01',
              expirationDate: DateTime.now().add(const Duration(days: 180)),
            );
        return PatientSelectionPage(label: label);
      },
    ),
    GoRoute(
      path: '/usage/confirm',
      name: 'usage-confirm',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final label = extra['label'] as Label? ??
            Label(
              id: 1,
              code: 'LBL-01',
              productName: 'Dental Instrument',
              reference: 'REF-01',
              lotNumber: 'LOT-01',
              expirationDate: DateTime.now().add(const Duration(days: 180)),
            );
        final patient = extra['patient'] as Patient? ??
            const Patient(
              id: 'PAT-001',
              firstName: 'Marie',
              lastName: 'Dubois',
              dossierId: 'DOS-2024-001',
            );
        return UsageConfirmationPage(label: label, patient: patient);
      },
    ),
    GoRoute(
      path: '/usage/success',
      name: 'usage-success',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final usage = extra['usage'] as InstrumentUsage? ??
            InstrumentUsage(
              id: '1',
              idempotencyKey: 'UUID-DEFAULT',
              labelId: '1',
              labelCode: 'LBL-01',
              productName: 'Dental Instrument',
              lotNumber: 'LOT-01',
              patientId: 'PAT-001',
              patientName: 'Marie Dubois',
              dossierId: 'DOS-2024-001',
              practitionerId: '1',
              practitionerName: 'Dr. Practitioner',
              usedAt: DateTime.now(),
            );
        final isOffline = extra['isOffline'] as bool? ?? false;
        return UsageSuccessPage(usage: usage, isOffline: isOffline);
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);
