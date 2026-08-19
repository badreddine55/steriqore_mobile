import '../../../../core/utils/first_launch_checker.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final FirstLaunchChecker _firstLaunchChecker;

  OnboardingLocalDataSourceImpl({FirstLaunchChecker? firstLaunchChecker})
      : _firstLaunchChecker = firstLaunchChecker ?? FirstLaunchChecker();

  @override
  Future<bool> isOnboardingCompleted() async {
    return await _firstLaunchChecker.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _firstLaunchChecker.setOnboardingCompleted();
  }
}
