import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/dashboard_stats.dart';

class StatsCardGrid extends StatelessWidget {
  final DashboardStats stats;

  const StatsCardGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Today's Scans",
                value: '${stats.todayScansCount}',
                icon: Icons.qr_code_scanner_rounded,
                iconColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppDimensions.s16),
            Expanded(
              child: _StatCard(
                title: 'Pending Sync',
                value: '${stats.pendingSyncCount}',
                icon: Icons.cloud_queue_rounded,
                iconColor: stats.pendingSyncCount > 0 ? AppColors.warning : AppColors.success,
                badgeText: stats.pendingSyncCount > 0 ? 'Offline Queue' : 'Synced',
                badgeColor: stats.pendingSyncCount > 0 ? AppColors.warning : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Active Alerts',
                value: '${stats.activeAlertsCount}',
                icon: Icons.warning_amber_rounded,
                iconColor: stats.activeAlertsCount > 0 ? AppColors.error : AppColors.success,
                badgeText: stats.activeAlertsCount > 0 ? '${stats.activeAlertsCount} Attention' : 'All Clear',
                badgeColor: stats.activeAlertsCount > 0 ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(width: AppDimensions.s16),
            Expanded(
              child: _StatCard(
                title: 'Last Cycle',
                value: stats.lastCycleTimestamp ?? 'Today',
                icon: Icons.sanitizer_rounded,
                iconColor: AppColors.success,
                isSmallValue: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? badgeText;
  final Color? badgeColor;
  final bool isSmallValue;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.badgeText,
    this.badgeColor,
    this.isSmallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.s8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColors.accent).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTypography.navLabel.copyWith(
                      color: badgeColor ?? AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isSmallValue
                ? AppTypography.data.copyWith(fontSize: 15)
                : AppTypography.dataLarge,
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
