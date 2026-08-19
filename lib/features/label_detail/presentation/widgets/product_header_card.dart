import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../scanner/domain/entities/label.dart';
import 'dlc_badge.dart';

class ProductHeaderCard extends StatelessWidget {
  final Label label;

  const ProductHeaderCard({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s20),
      borderRadius: AppDimensions.radius2xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DlcBadge(label: label),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  'ID #${label.id}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.productName,
                      style: AppTypography.h2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref: ${label.reference}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppDimensions.s12),

          _RowItem(
            label: 'Lot / Batch Number',
            value: label.lotNumber,
            isMonospace: true,
          ),
          _RowItem(
            label: 'Expiration Date (DLC)',
            value: DateFormatter.formatDate(label.expirationDate),
            valueColor: label.isExpiredByDate ? AppColors.error : AppColors.textPrimary,
          ),
          _RowItem(
            label: 'Remaining Shelf Life',
            value: label.isExpiredByDate
                ? 'Expired ${-label.remainingDays} days ago'
                : '${label.remainingDays} days remaining',
            valueColor: label.isExpiredByDate
                ? AppColors.error
                : (label.isNearExpiration ? AppColors.warning : AppColors.success),
          ),
          _RowItem(
            label: 'Package Code',
            value: label.code,
            isLast: true,
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
  final bool isMonospace;
  final bool isLast;

  const _RowItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.isMonospace = false,
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
              style: (isMonospace ? AppTypography.data : AppTypography.caption).copyWith(
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
