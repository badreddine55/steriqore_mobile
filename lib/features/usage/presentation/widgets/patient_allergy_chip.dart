import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/patient.dart';

class PatientAllergyChip extends StatelessWidget {
  final PatientAllergy allergy;

  const PatientAllergyChip({
    super.key,
    required this.allergy,
  });

  @override
  Widget build(BuildContext context) {
    final isSevere = allergy.severity == AllergySeverity.severe;
    final color = isSevere ? AppColors.error : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${allergy.name}${isSevere ? ' (Severe)' : ''}',
            style: AppTypography.navLabel.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
