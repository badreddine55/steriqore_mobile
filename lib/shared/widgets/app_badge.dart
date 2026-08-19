import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

enum AppBadgeVariant { success, warning, error, info, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;
  final bool isSmall;

  const AppBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.isSmall = false,
  }) : variant = AppBadgeVariant.success;

  const AppBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.isSmall = false,
  }) : variant = AppBadgeVariant.warning;

  const AppBadge.error({
    super.key,
    required this.label,
    this.icon,
    this.isSmall = false,
  }) : variant = AppBadgeVariant.error;

  const AppBadge.info({
    super.key,
    required this.label,
    this.icon,
    this.isSmall = false,
  }) : variant = AppBadgeVariant.info;

  const AppBadge.neutral({
    super.key,
    required this.label,
    this.icon,
    this.isSmall = false,
  }) : variant = AppBadgeVariant.neutral;

  @override
  Widget build(BuildContext context) {
    Color baseColor;

    switch (variant) {
      case AppBadgeVariant.success:
        baseColor = AppColors.success;
        break;
      case AppBadgeVariant.warning:
        baseColor = AppColors.warning;
        break;
      case AppBadgeVariant.error:
        baseColor = AppColors.error;
        break;
      case AppBadgeVariant.info:
        baseColor = AppColors.accent;
        break;
      case AppBadgeVariant.neutral:
        baseColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppDimensions.s8 : AppDimensions.s12,
        vertical: isSmall ? AppDimensions.s4 : 6,
      ),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: baseColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppDimensions.s4),
          ],
          Text(
            label,
            style: (isSmall ? AppTypography.navLabel : AppTypography.caption).copyWith(
              fontWeight: FontWeight.w700,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}
