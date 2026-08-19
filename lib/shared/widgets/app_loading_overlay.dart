import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

class AppLoadingOverlay extends StatelessWidget {
  final String? message;

  const AppLoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s24),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppDimensions.s16),
                Text(
                  message!,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
