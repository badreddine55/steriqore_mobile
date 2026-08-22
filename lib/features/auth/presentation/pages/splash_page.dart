import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/first_launch_checker.dart';
import '../../domain/repositories/auth_repository.dart';

class SplashPage extends StatefulWidget {
  final FirstLaunchChecker? firstLaunchChecker;
  final AuthRepository? authRepository;

  const SplashPage({
    super.key,
    this.firstLaunchChecker,
    this.authRepository,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
    _checkDestination();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkDestination() async {
    // Show splash for at least 800ms
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final checker = widget.firstLaunchChecker ?? sl<FirstLaunchChecker>();
    final authRepo = widget.authRepository ?? sl<AuthRepository>();

    final isFirst = await checker.isFirstLaunch();
    final onboardingDone = await checker.isOnboardingCompleted();

    if (isFirst || !onboardingDone) {
      if (mounted) context.go('/onboarding');
      return;
    }

    final isLoggedIn = await authRepo.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) context.go('/login');
      return;
    }

    final userResult = await authRepo.getCurrentUser();
    final user = userResult.fold((_) => null, (u) => u);
    final role = user?.role.toLowerCase() ?? (await authRepo.getSavedRole())?.toLowerCase() ?? 'practitioner';
    final isAdmin = role == 'admin' || role == 'administrateur';

    if (mounted) {
      if (isAdmin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // Pure black #000000
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimal logo container with subtle glow
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sanitizer_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.s24),

                // Brand Headline
                Text(
                  'STERIQORE',
                  style: AppTypography.heroTitle.copyWith(
                    color: Colors.white,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),

                // Clinical Subtitle
                Text(
                  'DENTAL TRACEABILITY & STERILIZATION',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0x99FFFFFF), // 60% white
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
