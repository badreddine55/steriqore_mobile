import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.title = 'An error occurred',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.s16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppDimensions.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.s24),
              AppButton.secondary(
                label: 'Retry',
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: onRetry,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
