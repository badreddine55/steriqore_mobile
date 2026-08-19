import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingLocalDataSource localDataSource;

  OnboardingBloc({required this.localDataSource})
      : super(const OnboardingState()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompletedEvent>(_onCompleted);
    on<OnboardingSkippedEvent>(_onSkipped);
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(currentPage: event.pageIndex));
  }

  Future<void> _onCompleted(
    OnboardingCompletedEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    await localDataSource.setOnboardingCompleted();
    emit(state.copyWith(isCompleted: true));
  }

  Future<void> _onSkipped(
    OnboardingSkippedEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    await localDataSource.setOnboardingCompleted();
    emit(state.copyWith(isSkipped: true));
  }
}
