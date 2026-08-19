import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../scanner/domain/entities/label.dart';

class DlcBadge extends StatelessWidget {
  final Label label;

  const DlcBadge({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    if (label.status == LabelStatusType.recalled) {
      color = AppColors.error;
      icon = Icons.block_rounded;
      text = 'RECALLED / BLOCKED';
    } else if (label.isExpiredByDate || label.status == LabelStatusType.expired) {
      color = AppColors.error;
      icon = Icons.dangerous_rounded;
      text = 'DLC EXPIRED';
    } else if (label.status == LabelStatusType.alreadyUsed) {
      color = AppColors.warning;
      icon = Icons.history_toggle_off_rounded;
      text = 'ALREADY USED';
    } else if (label.isNearExpiration) {
      color = AppColors.warning;
      icon = Icons.warning_amber_rounded;
      text = 'DLC < 30 DAYS (${label.remainingDays}d)';
    } else {
      color = AppColors.success;
      icon = Icons.check_circle_rounded;
      text = 'VALIDATED / DLC CONFORME';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppDimensions.s4),
          Text(
            text,
            style: AppTypography.navLabel.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
