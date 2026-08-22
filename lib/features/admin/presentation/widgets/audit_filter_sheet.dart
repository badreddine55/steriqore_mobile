import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';

class AuditFilterSheet extends StatelessWidget {
  final String selectedDateFilter;
  final String selectedActionFilter;
  final ValueChanged<String> onDateFilterSelected;
  final ValueChanged<String> onActionFilterSelected;
  final VoidCallback onReset;

  const AuditFilterSheet({
    super.key,
    required this.selectedDateFilter,
    required this.selectedActionFilter,
    required this.onDateFilterSelected,
    required this.onActionFilterSelected,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final dateOptions = [
      ('all', 'All Time'),
      ('today', 'Today'),
      ('week', 'Last 7 Days'),
      ('month', 'Last 30 Days'),
    ];

    final actionOptions = [
      ('all', 'All Actions'),
      ('RECORD_USAGE', 'Patient Usages'),
      ('VALIDATE_CYCLE', 'Autoclave Validations'),
      ('CREATE_USER', 'User Additions'),
      ('UPDATE_SETTINGS', 'Settings Changes'),
      ('DEACTIVATE_USER', 'User Deactivations'),
      ('WARNING', 'System Alerts'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AdminColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Audit Logs', style: AdminTypography.h3),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AdminColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Filter Section
          Text('TIMEFRAME', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dateOptions.map((opt) {
              final isSelected = selectedDateFilter == opt.$1;
              return GestureDetector(
                onTap: () => onDateFilterSelected(opt.$1),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AdminColors.primary : AdminColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AdminColors.primary : AdminColors.borderSubtle,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt.$2,
                      style: AdminTypography.caption.copyWith(
                        color: isSelected ? AdminColors.primaryInverse : AdminColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Action Filter Section
          Text('ACTION TYPE', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actionOptions.map((opt) {
              final isSelected = selectedActionFilter == opt.$1;
              return GestureDetector(
                onTap: () => onActionFilterSelected(opt.$1),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AdminColors.primary : AdminColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AdminColors.primary : AdminColors.borderSubtle,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt.$2,
                      style: AdminTypography.caption.copyWith(
                        color: isSelected ? AdminColors.primaryInverse : AdminColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.secondary,
                      side: const BorderSide(color: AdminColors.borderStrong),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 8px radius
                      ),
                    ),
                    onPressed: () {
                      onReset();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Reset Filters', style: AdminTypography.button),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: AdminColors.primaryInverse,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 8px radius
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Apply Filters', style: AdminTypography.button),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
