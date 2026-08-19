import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:steriqore_mobile/features/onboarding/presentation/bloc/onboarding_state.dart';

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
  late FakeOnboardingLocalDataSource fakeLocalDataSource;
  late OnboardingBloc onboardingBloc;

  setUp(() {
    fakeLocalDataSource = FakeOnboardingLocalDataSource();
    onboardingBloc = OnboardingBloc(localDataSource: fakeLocalDataSource);
  });

  tearDown(() {
    onboardingBloc.close();
  });

  test('Initial state has currentPage = 0 and isCompleted = false', () {
    expect(onboardingBloc.state.currentPage, equals(0));
    expect(onboardingBloc.state.isCompleted, isFalse);
    expect(onboardingBloc.state.isSkipped, isFalse);
  });

  test('Updates currentPage on OnboardingPageChanged event', () async {
    expectLater(
      onboardingBloc.stream,
      emits(const OnboardingState(currentPage: 2)),
    );

    onboardingBloc.add(const OnboardingPageChanged(2));
  });

  test('Sets isCompleted to true on OnboardingCompletedEvent and saves to datasource', () async {
    expectLater(
      onboardingBloc.stream,
      emits(const OnboardingState(currentPage: 0, isCompleted: true)),
    );

    onboardingBloc.add(const OnboardingCompletedEvent());
    await Future.delayed(const Duration(milliseconds: 50));

    expect(fakeLocalDataSource.completed, isTrue);
  });

  test('Sets isSkipped to true on OnboardingSkippedEvent and saves to datasource', () async {
    expectLater(
      onboardingBloc.stream,
      emits(const OnboardingState(currentPage: 0, isSkipped: true)),
    );

    onboardingBloc.add(const OnboardingSkippedEvent());
    await Future.delayed(const Duration(milliseconds: 50));

    expect(fakeLocalDataSource.completed, isTrue);
  });
}
