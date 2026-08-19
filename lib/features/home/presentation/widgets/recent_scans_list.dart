import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class RecentScanItem {
  final String productName;
  final String lotNumber;
  final String patientName;
  final String time;
  final bool isValid;

  const RecentScanItem({
    required this.productName,
    required this.lotNumber,
    required this.patientName,
    required this.time,
    this.isValid = true,
  });
}

class RecentScansList extends StatelessWidget {
  final List<RecentScanItem> items;
  final void Function(RecentScanItem item)? onItemTap;

  const RecentScansList({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppDimensions.s24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.qr_code_2_rounded, size: 36, color: AppColors.textTertiary),
              const SizedBox(height: AppDimensions.s8),
              Text(
                'No scans recorded today',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.s12),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 220,
            child: AppCard(
              padding: const EdgeInsets.all(AppDimensions.s12),
              onTap: () => onItemTap?.call(item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: const Icon(Icons.sanitizer_rounded, size: 16, color: AppColors.accent),
                      ),
                      Text(
                        item.time,
                        style: AppTypography.navLabel.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Lot: ${item.lotNumber}',
                        maxLines: 1,
                        style: AppTypography.navLabel.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.navLabel.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
