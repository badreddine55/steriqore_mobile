import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/models/onboarding_page_data.dart';
import 'glassmorphism_pill.dart';
import 'pagination_dots.dart';

class OnboardingPageViewItem extends StatelessWidget {
  final OnboardingPageData pageData;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;
  final ValueChanged<int>? onDotTapped;

  const OnboardingPageViewItem({
    super.key,
    required this.pageData,
    required this.pageIndex,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
    required this.onLogin,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = pageIndex == totalPages - 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Background image
        Positioned.fill(
          child: Image.asset(
            pageData.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
        ),

        // Layer 2: High contrast gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xF2000000), // 95% black
                  Color(0x99000000), // 60% black
                  Color(0x26000000), // 15% black
                  Color(0x00000000), // 0% black
                ],
                stops: [0.0, 0.45, 0.70, 1.0],
              ),
            ),
          ),
        ),

        // Layer 3: Foreground Content with clean Flex/Spacer layout
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (pageData.showLocationPill || pageData.locationText != null)
                      GlassmorphismPill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              pageData.locationText ?? 'Cabinet Central, Paris',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (!isLastPage)
                      TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Skip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),

                const Spacer(),

                // Bottom Content
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PaginationDots(
                          count: totalPages,
                          currentIndex: pageIndex,
                          onDotTapped: onDotTapped,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          pageData.title,
                          style: AppTypography.heroTitle.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          pageData.subtitle,
                          style: AppTypography.bodyLarge.copyWith(
                            color: const Color(0xBFFFFFFF),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (isLastPage)
                          AppButton.primaryInverse(
                            text: 'Get Started',
                            onPressed: onGetStarted,
                          )
                        else
                          AppButton.primaryInverse(
                            text: 'Continue',
                            onPressed: onNext,
                          ),
                        const SizedBox(height: 10),
                        Center(
                          child: AppButton.ghost(
                            text: 'I already have an account',
                            textColor: Colors.white,
                            onPressed: onLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
