import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

class HistoryFilterChips extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;

  const HistoryFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      {'key': 'all', 'label': 'All Records'},
      {'key': 'today', 'label': 'Today'},
      {'key': 'week', 'label': 'This Week'},
      {'key': 'pending', 'label': 'Pending Sync'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
      child: Row(
        children: filters.map((f) {
          final isSelected = activeFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.s8),
            child: GestureDetector(
              onTap: () => onFilterSelected(f['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.elevated,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
