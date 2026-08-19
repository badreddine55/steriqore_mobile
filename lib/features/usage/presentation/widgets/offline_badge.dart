import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class OfflineBadge extends StatelessWidget {
  final String text;

  const OfflineBadge({
    super.key,
    this.text = 'Offline mode — changes will sync automatically',
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s16, vertical: 10),
      backgroundColor: AppColors.warning.withValues(alpha: 0.12),
      borderColor: AppColors.warning.withValues(alpha: 0.35),
      borderRadius: AppDimensions.radiusMd,
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
