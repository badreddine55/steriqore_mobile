import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class BlockingAlertWidget extends StatelessWidget {
  final String title;
  final String message;
  final bool isBlocked; // Red 410 gate vs Orange 409 warning

  const BlockingAlertWidget.blocked({
    super.key,
    this.title = 'CRITICAL SAFETY GATE: INSTRUMENT BLOCKED',
    required this.message,
  }) : isBlocked = true;

  const BlockingAlertWidget.warning({
    super.key,
    this.title = 'USAGE NOTICE (409)',
    required this.message,
  }) : isBlocked = false;

  @override
  Widget build(BuildContext context) {
    final color = isBlocked ? AppColors.error : AppColors.warning;
    final icon = isBlocked ? Icons.gpp_bad_rounded : Icons.warning_amber_rounded;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      backgroundColor: color.withValues(alpha: 0.10),
      borderColor: color.withValues(alpha: 0.35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.s8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isBlocked) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Use on patient is strictly locked for regulatory patient safety.',
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
