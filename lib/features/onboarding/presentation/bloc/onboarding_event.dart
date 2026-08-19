import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class OnboardingCompletedEvent extends OnboardingEvent {
  const OnboardingCompletedEvent();
}

class OnboardingSkippedEvent extends OnboardingEvent {
  const OnboardingSkippedEvent();
}
