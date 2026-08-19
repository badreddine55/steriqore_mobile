import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/models/user_model.dart';
import 'package:steriqore_mobile/screens/auth/login_screen.dart';
import 'package:steriqore_mobile/screens/auth/register_screen.dart';
import 'package:steriqore_mobile/screens/home/dashboard_screen.dart';

void main() {
  final testUser = UserModel(
    id: 101,
    name: 'Dr. Sarah Connor-Alexander',
    email: 'sarah.connor@clinique-dentaire-paris.fr',
    createdAt: '2026-08-15',
  );

  final testResolutions = <String, Size>{
    'Small Mobile (iPhone SE 1)': const Size(320, 568),
    'Standard Mobile (iPhone 8)': const Size(375, 667),
    'Modern Mobile (iPhone 14)': const Size(390, 844),
    'Large Mobile (iPhone 14 Pro Max)': const Size(430, 932),
    'Mobile Landscape': const Size(844, 390),
    'Tablet Portrait (iPad)': const Size(768, 1024),
    'Tablet Landscape (iPad)': const Size(1024, 768),
    'Desktop / Web': const Size(1440, 900),
  };

  group('Responsive Layout Tests - Login Screen', () {
    for (final entry in testResolutions.entries) {
      testWidgets('LoginScreen renders with no overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: LoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Welcome back'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Responsive Layout Tests - Register Screen', () {
    for (final entry in testResolutions.entries) {
      testWidgets('RegisterScreen renders with no overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: RegisterScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Join your cabinet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Responsive Layout Tests - Dashboard Screen', () {
    for (final entry in testResolutions.entries) {
      testWidgets('DashboardScreen renders all tabs with no overflow on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: DashboardScreen(user: testUser),
          ),
        );
        await tester.pumpAndSettle();

        // Check Home tab
        expect(find.text(testUser.name), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Switch to Scan Tab
        await tester.tap(find.text('Scan'));
        await tester.pumpAndSettle();
        expect(find.text('Scan Medical Labels'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Switch to Stock Tab
        await tester.tap(find.text('Stock'));
        await tester.pumpAndSettle();
        expect(find.text('Dental Inventory & Lots'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Switch to Cycles Tab
        await tester.tap(find.text('Cycles'));
        await tester.pumpAndSettle();
        expect(find.text('Sterilization Cycles'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Switch to Profile Tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Practice Profile & Security'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
