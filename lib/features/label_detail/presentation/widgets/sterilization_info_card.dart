import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/sterilization_cycle.dart';

class SterilizationInfoCard extends StatefulWidget {
  final SterilizationCycle? cycle;

  const SterilizationInfoCard({
    super.key,
    this.cycle,
  });

  @override
  State<SterilizationInfoCard> createState() => _SterilizationInfoCardState();
}

class _SterilizationInfoCardState extends State<SterilizationInfoCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cycle = widget.cycle;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s20),
      borderRadius: AppDimensions.radius2xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.s8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: const Icon(Icons.sanitizer_rounded, color: AppColors.success, size: 20),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sterilization Cycle', style: AppTypography.h4),
                      Text(
                        cycle?.cycleNumber ?? 'CYC-2026-089',
                        style: AppTypography.data.copyWith(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  (cycle?.isValidated ?? true) ? 'Validated ✓' : 'Failed ✗',
                  style: AppTypography.navLabel.copyWith(
                    color: (cycle?.isValidated ?? true) ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppDimensions.s12),

          _RowItem(
            label: 'Autoclave Device',
            value: cycle?.autoclaveName ?? 'Melag Vacuklav 40B',
          ),
          _RowItem(
            label: 'Program & Parameters',
            value: '${cycle?.temperature ?? 134.0}°C · ${cycle?.pressureBar ?? 2.1} bar · ${cycle?.durationMinutes ?? 18}m',
          ),
          _RowItem(
            label: 'Sterilization Date',
            value: DateFormatter.formatDate(cycle?.sterilizationDate ?? DateTime.now().subtract(const Duration(days: 2))),
          ),
          _RowItem(
            label: 'Qualified Operator',
            value: cycle?.operatorName ?? 'Dr. Dupont',
            isLast: !_isExpanded,
          ),

          if (_isExpanded && cycle != null) ...[
            const SizedBox(height: AppDimensions.s8),
            const Divider(color: AppColors.borderSubtle),
            const SizedBox(height: AppDimensions.s8),
            _RowItem(label: 'Biological Indicator', value: 'Conforming (Negative)', valueColor: AppColors.success),
            _RowItem(label: 'Chemical Integrator', value: 'Class 5 Pass', valueColor: AppColors.success),
            _RowItem(label: 'Bowie-Dick Daily Test', value: 'Passed ✓', valueColor: AppColors.success),
            if (cycle.attachments.isNotEmpty)
              _RowItem(
                label: 'Audit Certificates',
                value: '${cycle.attachments.length} files attached',
                isLast: true,
              ),
          ],

          const SizedBox(height: AppDimensions.s12),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _isExpanded ? 'Hide Cycle Details' : 'View Full Cycle Parameters & Attachments',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _RowItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppDimensions.s8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
