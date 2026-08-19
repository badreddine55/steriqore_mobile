import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:steriqore_mobile/features/onboarding/data/models/onboarding_page_data.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/widgets/glassmorphism_pill.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/widgets/pagination_dots.dart';

class FakeOnboardingLocalDataSource implements OnboardingLocalDataSource {
  bool completed = false;

  @override
  Future<bool> isOnboardingCompleted() async => completed;

  @override
  Future<void> setOnboardingCompleted() async {
    completed = true;
  }
}

void main() {
  late FakeOnboardingLocalDataSource fakeDataSource;
  late OnboardingBloc onboardingBloc;

  setUp(() {
    fakeDataSource = FakeOnboardingLocalDataSource();
    onboardingBloc = OnboardingBloc(localDataSource: fakeDataSource);
  });

  tearDown(() {
    onboardingBloc.close();
  });

  Widget buildTestApp(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('OnboardingPage renders first page with buttons and controls', (tester) async {
    await tester.pumpWidget(buildTestApp(OnboardingPage(
      onboardingBloc: onboardingBloc,
      pages: OnboardingPageData.defaultPages,
    )));
    await tester.pump();

    // Verify first page content
    expect(find.byType(GlassmorphismPill), findsOneWidget);
    expect(find.text('Cabinet Central, Paris'), findsOneWidget);
    expect(find.text('Sterilization\n& Stock Tracking'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.byType(PaginationDots), findsOneWidget);
  });

  testWidgets('Swiping to last page renders Get Started button and I already have an account', (tester) async {
    await tester.pumpWidget(buildTestApp(OnboardingPage(
      onboardingBloc: onboardingBloc,
      pages: OnboardingPageData.defaultPages,
    )));
    await tester.pump();

    // Swipe 3 times to get to page 4
    await tester.drag(find.byType(PageView), const Offset(-450, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-450, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-450, 0));
    await tester.pumpAndSettle();

    expect(find.text('Compliance\nMade Simple'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });
}
