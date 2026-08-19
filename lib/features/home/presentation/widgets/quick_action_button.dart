import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return AppCard(
        backgroundColor: AppColors.primary,
        borderColor: Colors.transparent,
        onTap: onTap,
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: AppDimensions.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h4.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
          ],
        ),
      );
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.s8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: AppDimensions.s12),
          Text(title, style: AppTypography.h4),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
