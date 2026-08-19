import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/patient.dart';
import 'patient_allergy_chip.dart';

class PatientListItem extends StatelessWidget {
  final Patient patient;
  final bool isSelected;
  final VoidCallback onTap;

  const PatientListItem({
    super.key,
    required this.patient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.s16),
      borderColor: isSelected ? AppColors.primary : AppColors.borderSubtle,
      backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.03) : AppColors.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isSelected ? AppColors.primary : AppColors.background,
                child: Text(
                  patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : 'P',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: AppTypography.h4,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dossier: ${patient.dossierId}${patient.cabinetRoom != null ? ' · ${patient.cabinetRoom}' : ''}',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                )
              else
                const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
            ],
          ),

          if (patient.allergies.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: patient.allergies.map((a) => PatientAllergyChip(allergy: a)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
