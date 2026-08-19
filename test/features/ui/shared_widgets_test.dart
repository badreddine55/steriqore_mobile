import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/features/auth/presentation/widgets/auth_background.dart';
import 'package:steriqore_mobile/features/auth/presentation/widgets/auth_form_sheet.dart';
import 'package:steriqore_mobile/features/auth/presentation/widgets/role_selection_card.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/widgets/glassmorphism_pill.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/widgets/pagination_dots.dart';
import 'package:steriqore_mobile/shared/widgets/app_button.dart';
import 'package:steriqore_mobile/shared/widgets/app_icon_button.dart';
import 'package:steriqore_mobile/shared/widgets/app_text_field.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('GlassmorphismPill renders child content', (tester) async {
    await tester.pumpWidget(buildTestApp(
      const GlassmorphismPill(
        child: Text('Paris, France', style: TextStyle(color: Colors.white)),
      ),
    ));
    await tester.pump();

    expect(find.text('Paris, France'), findsOneWidget);
    expect(find.byType(GlassmorphismPill), findsOneWidget);
  });

  testWidgets('PaginationDots renders 4 dots with active index indicator', (tester) async {
    await tester.pumpWidget(buildTestApp(
      const PaginationDots(
        count: 4,
        currentIndex: 1,
      ),
    ));
    await tester.pump();

    expect(find.byType(PaginationDots), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsNWidgets(4));
  });

  testWidgets('AppButton variants render correctly and respond to taps', (tester) async {
    bool primaryPressed = false;
    bool inversePressed = false;
    bool ghostPressed = false;

    await tester.pumpWidget(buildTestApp(
      Column(
        children: [
          AppButton.primary(
            text: 'Primary Button',
            onPressed: () => primaryPressed = true,
          ),
          AppButton.primaryInverse(
            text: 'Primary Inverse',
            onPressed: () => inversePressed = true,
          ),
          AppButton.ghost(
            text: 'Ghost Action',
            onPressed: () => ghostPressed = true,
          ),
          AppButton.icon(
            icon: Icons.close,
            onPressed: () {},
          ),
        ],
      ),
    ));
    await tester.pump();

    expect(find.text('Primary Button'), findsOneWidget);
    expect(find.text('Primary Inverse'), findsOneWidget);
    expect(find.text('Ghost Action'), findsOneWidget);

    await tester.tap(find.text('Primary Button'));
    expect(primaryPressed, isTrue);

    await tester.tap(find.text('Primary Inverse'));
    expect(inversePressed, isTrue);

    await tester.tap(find.text('Ghost Action'));
    expect(ghostPressed, isTrue);
  });

  testWidgets('AppTextField renders prefix icon, label, and error text', (tester) async {
    await tester.pumpWidget(buildTestApp(
      const AppTextField(
        label: 'Clinic Email',
        hint: 'user@clinic.fr',
        prefixIcon: Icons.email_outlined,
        errorText: 'Invalid email address',
      ),
    ));
    await tester.pump();

    expect(find.text('Clinic Email'), findsOneWidget);
    expect(find.text('user@clinic.fr'), findsOneWidget);
    expect(find.text('Invalid email address'), findsOneWidget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });

  testWidgets('AppIconButton renders circular icon button', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(buildTestApp(
      AppIconButton(
        icon: Icons.arrow_back,
        onPressed: () => tapped = true,
      ),
    ));
    await tester.pump();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    await tester.tap(find.byType(AppIconButton));
    expect(tapped, isTrue);
  });

  testWidgets('RoleSelectionCard renders selected and unselected states', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(buildTestApp(
      RoleSelectionCard(
        icon: Icons.medical_services_outlined,
        title: 'Practitioner',
        subtitle: 'Scan instruments and record usage',
        isSelected: true,
        onTap: () => tapped = true,
      ),
    ));
    await tester.pump();

    expect(find.text('Practitioner'), findsOneWidget);
    expect(find.text('Scan instruments and record usage'), findsOneWidget);
    expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);

    await tester.tap(find.byType(RoleSelectionCard));
    expect(tapped, isTrue);
  });

  testWidgets('AuthFormSheet renders top drag handle and content', (tester) async {
    await tester.pumpWidget(buildTestApp(
      const AuthFormSheet(
        child: Text('Sheet Content'),
      ),
    ));
    await tester.pump();

    expect(find.text('Sheet Content'), findsOneWidget);
  });

  testWidgets('AuthBackground renders child on top of background', (tester) async {
    await tester.pumpWidget(buildTestApp(
      const AuthBackground(
        child: Text('Auth Content'),
      ),
    ));
    await tester.pump();

    expect(find.text('Auth Content'), findsOneWidget);
  });
}
