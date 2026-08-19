import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/steriqore_shared.dart';
import '../models/label_model.dart';
import '../models/usage_model.dart';

/// Status pill badge for physical label conformity and sync states
class LabelStatusBadge extends StatelessWidget {
  final LabelStatus? labelStatus;
  final SyncStatus? syncStatus;
  final bool isNearExpiration;

  const LabelStatusBadge.label({
    super.key,
    required this.labelStatus,
    this.isNearExpiration = false,
  }) : syncStatus = null;

  const LabelStatusBadge.sync({
    super.key,
    required this.syncStatus,
  })  : labelStatus = null,
        isNearExpiration = false;

  @override
  Widget build(BuildContext context) {
    if (labelStatus != null) {
      return _buildLabelBadge(context);
    }
    if (syncStatus != null) {
      return _buildSyncBadge(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLabelBadge(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    if (isNearExpiration) {
      color = AppColors.warning;
      icon = Icons.warning_amber_rounded;
      text = 'Near Expiration';
    } else {
      switch (labelStatus ?? LabelStatus.unknown) {
        case LabelStatus.valid:
          color = AppColors.success;
          icon = Icons.check_circle_rounded;
          text = 'VALIDATED / READY';
          break;
        case LabelStatus.expired:
          color = AppColors.error;
          icon = Icons.dangerous_rounded;
          text = 'DLC EXPIRED';
          break;
        case LabelStatus.recalled:
          color = AppColors.error;
          icon = Icons.block_rounded;
          text = 'RECALLED / BLOCKED';
          break;
        case LabelStatus.alreadyUsed:
          color = AppColors.warning;
          icon = Icons.history_toggle_off_rounded;
          text = 'ALREADY USED';
          break;
        case LabelStatus.pendingValidation:
          color = AppColors.info;
          icon = Icons.hourglass_top_rounded;
          text = 'PENDING RELEASE';
          break;
        case LabelStatus.unknown:
          color = AppColors.textTertiary;
          icon = Icons.help_outline_rounded;
          text = 'UNVERIFIED';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: steriqoreFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncBadge(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    switch (syncStatus ?? SyncStatus.pending) {
      case SyncStatus.synced:
        color = AppColors.success;
        icon = Icons.cloud_done_rounded;
        text = 'Synced';
        break;
      case SyncStatus.syncing:
        color = AppColors.info;
        icon = Icons.sync_rounded;
        text = 'Syncing...';
        break;
      case SyncStatus.pending:
        color = AppColors.warning;
        icon = Icons.cloud_queue_rounded;
        text = 'Pending Sync';
        break;
      case SyncStatus.failed:
        color = AppColors.error;
        icon = Icons.sync_problem_rounded;
        text = 'Sync Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: steriqoreFont(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
