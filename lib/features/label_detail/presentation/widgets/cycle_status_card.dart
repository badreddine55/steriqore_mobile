import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class CycleStatusCard extends StatelessWidget {
  final bool isValidated;
  final String statusText;

  const CycleStatusCard({
    super.key,
    required this.isValidated,
    this.statusText = 'Autoclave cycle completed with biological and physical conformity.',
  });

  @override
  Widget build(BuildContext context) {
    final color = isValidated ? AppColors.success : AppColors.error;
    final icon = isValidated ? Icons.verified_user_rounded : Icons.gpp_bad_rounded;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      backgroundColor: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.25),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              statusText,
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
}
