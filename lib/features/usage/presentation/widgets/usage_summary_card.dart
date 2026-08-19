import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../scanner/domain/entities/label.dart';
import '../../domain/entities/patient.dart';
import 'patient_allergy_chip.dart';

class UsageSummaryCard extends StatelessWidget {
  final Label label;
  final Patient patient;
  final String practitionerName;
  final DateTime timestamp;

  const UsageSummaryCard({
    super.key,
    required this.label,
    required this.patient,
    required this.practitionerName,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s20),
      borderRadius: AppDimensions.radius2xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Instrument
          Text(
            'INSTRUMENT PACKAGE',
            style: AppTypography.navLabel.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            label.productName,
            style: AppTypography.h3,
          ),
          const SizedBox(height: 2),
          Text(
            'Lot: ${label.lotNumber} · Ref: ${label.reference}',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.s16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppDimensions.s12),

          // Section: Patient
          Text(
            'PATIENT RECIPIENT',
            style: AppTypography.navLabel.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : 'P',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.fullName, style: AppTypography.h4),
                    Text(
                      'Dossier: ${patient.dossierId}',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (patient.allergies.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: patient.allergies.map((a) => PatientAllergyChip(allergy: a)).toList(),
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppDimensions.s12),

          // Section: Audit Practitioner & Timestamp
          _DetailLine(label: 'Attending Practitioner', value: practitionerName),
          _DetailLine(label: 'Session Timestamp', value: DateFormatter.formatDateTime(timestamp)),
          const SizedBox(height: AppDimensions.s8),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(AppDimensions.s12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    'This action will be recorded in the audit trail and cannot be undone.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
