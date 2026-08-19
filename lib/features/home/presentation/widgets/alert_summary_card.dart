import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class AlertSummaryCard extends StatelessWidget {
  final List<String> alerts;

  const AlertSummaryCard({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppDimensions.s16),
        backgroundColor: AppColors.success.withValues(alpha: 0.06),
        borderColor: AppColors.success.withValues(alpha: 0.2),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 22),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Text(
                'All sterilization parameters & DLC in compliance.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      backgroundColor: AppColors.warning.withValues(alpha: 0.08),
      borderColor: AppColors.warning.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: AppDimensions.s8),
              Text(
                'Traceability Compliance Notice',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          ...alerts.map(
            (msg) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      msg,
                      style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
