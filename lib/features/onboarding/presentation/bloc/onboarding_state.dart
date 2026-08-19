import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final bool isCompleted;
  final bool isSkipped;

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
    this.isSkipped = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleted,
    bool? isSkipped,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  @override
  List<Object?> get props => [currentPage, isCompleted, isSkipped];
}
