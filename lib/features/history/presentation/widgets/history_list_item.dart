import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/usage_history_entry.dart';
import 'sync_status_indicator.dart';

class HistoryListItem extends StatelessWidget {
  final UsageHistoryEntry entry;
  final VoidCallback onTap;

  const HistoryListItem({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        entry.patientName,
                        style: AppTypography.h4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${entry.dossierId})',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SyncStatusIndicator(status: entry.syncStatus),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),

          Text(
            entry.productName,
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lot: ${entry.lotNumber}',
                style: AppTypography.caption.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                DateFormatter.formatDateTime(entry.usedAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (entry.procedureType != null && entry.procedureType!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                entry.procedureType!,
                style: AppTypography.navLabel.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
