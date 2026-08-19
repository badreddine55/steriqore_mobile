import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'models/label_model.dart';
import 'screens/history/usage_history_screen.dart';
import 'screens/home/practitioner_dashboard_screen.dart';
import 'screens/label/label_detail_screen.dart';
import 'screens/scanner/scanner_screen.dart';
import 'screens/usage/usage_confirmation_screen.dart';

/// Isolated route definitions for the Practitioner Role
class PractitionerRoutes {
  PractitionerRoutes._();

  static const String dashboard = '/practitioner/dashboard';
  static const String scanner = '/practitioner/scanner';
  static const String labelDetail = '/practitioner/label';
  static const String usageConfirmation = '/practitioner/usage/confirm';
  static const String usageHistory = '/practitioner/usage/history';

  /// Generates routes specifically for the Practitioner workflow
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        final user = settings.arguments as UserModel? ??
            UserModel(id: 1, name: 'Dr. Practitioner', email: 'doctor@cabinet.com');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PractitionerDashboardScreen(user: user),
        );

      case scanner:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ScannerScreen(),
        );

      case labelDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final code = args['code'] as String? ?? 'UNKNOWN';
        final label = args['label'] as LabelModel?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LabelDetailScreen(code: code, initialLabel: label),
        );

      case usageConfirmation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final label = args['label'] as LabelModel? ??
            LabelModel(
              id: 1,
              code: 'DEMO-LOT',
              productName: 'Dental Device',
              reference: 'REF-001',
              lotNumber: 'LOT-DEMO',
              expirationDate: DateTime.now().add(const Duration(days: 120)),
              status: LabelStatus.valid,
            );
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UsageConfirmationScreen(label: label),
        );

      case usageHistory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const UsageHistoryScreen(),
        );

      default:
        return null;
    }
  }
}
