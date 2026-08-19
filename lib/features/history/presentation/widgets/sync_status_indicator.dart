import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../usage/domain/entities/instrument_usage.dart';

class SyncStatusIndicator extends StatelessWidget {
  final UsageSyncStatus status;

  const SyncStatusIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case UsageSyncStatus.synced:
        color = AppColors.success;
        icon = Icons.cloud_done_rounded;
        label = 'Synced';
        break;
      case UsageSyncStatus.pending:
        color = AppColors.warning;
        icon = Icons.cloud_queue_rounded;
        label = 'Pending Sync';
        break;
      case UsageSyncStatus.syncing:
        color = AppColors.accent;
        icon = Icons.sync_rounded;
        label = 'Syncing...';
        break;
      case UsageSyncStatus.failed:
        color = AppColors.error;
        icon = Icons.cloud_off_rounded;
        label = 'Sync Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.navLabel.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
