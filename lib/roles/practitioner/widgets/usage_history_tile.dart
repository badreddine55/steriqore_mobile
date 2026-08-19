import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/steriqore_shared.dart';
import '../models/usage_model.dart';
import 'label_status_badge.dart';

/// Clinical history tile displaying recorded patient traceability event
class UsageHistoryTile extends StatelessWidget {
  final UsageModel usage;
  final VoidCallback? onTap;
  final VoidCallback? onRetrySync;

  const UsageHistoryTile({
    super.key,
    required this.usage,
    this.onTap,
    this.onRetrySync,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && dt.day == now.day) {
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: usage.syncStatus == SyncStatus.failed
              ? AppColors.error.withValues(alpha: 0.4)
              : AppColors.borderSubtle,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Product Name & Sync Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sanitizer_rounded, size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usage.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: steriqoreFont(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lot: ${usage.lotNumber} · Ref: ${usage.reference.isNotEmpty ? usage.reference : usage.labelCode}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: steriqoreFont(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    LabelStatusBadge.sync(syncStatus: usage.syncStatus),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.borderSubtle, height: 1),
                const SizedBox(height: 10),

                // Bottom Row: Patient Name & Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          usage.patientName,
                          style: steriqoreFont(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(usage.usedAt),
                          style: steriqoreFont(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Error Retry Banner if Sync Failed
                if (usage.syncStatus == SyncStatus.failed) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            usage.errorMessage ?? 'Sync failed. Retry queued.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: steriqoreFont(fontSize: 11.5, color: AppColors.error),
                          ),
                        ),
                        if (onRetrySync != null)
                          GestureDetector(
                            onTap: onRetrySync,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                'Retry Now',
                                style: steriqoreFont(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
