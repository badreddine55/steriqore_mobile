import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/instrument_usage.dart';

class UsageSuccessPage extends StatelessWidget {
  final InstrumentUsage usage;
  final bool isOffline;

  const UsageSuccessPage({
    super.key,
    required this.usage,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding,
                vertical: AppDimensions.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.s16),

                  // Animated/Highlighted Large Green Success Icon
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 52,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s20),

                  // Title & Subtitle
                  Text(
                    'Usage Recorded',
                    textAlign: TextAlign.center,
                    style: AppTypography.h1,
                  ),
                  const SizedBox(height: AppDimensions.s8),
                  Text(
                    isOffline
                        ? 'Saved to local outbox. Will synchronize automatically when online.'
                        : 'Traceability entry created and digitally recorded in clinic registry.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimensions.s24),

                  // Summary Info Card
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.s20),
                    borderRadius: AppDimensions.radius2xl,
                    child: Column(
                      children: [
                        _RowItem(
                          label: 'Patient',
                          value: usage.patientName,
                        ),
                        _RowItem(
                          label: 'Dossier ID',
                          value: usage.dossierId ?? 'DOS-2026',
                        ),
                        _RowItem(
                          label: 'Instrument',
                          value: usage.productName,
                        ),
                        _RowItem(
                          label: 'Lot Number',
                          value: usage.lotNumber,
                          isMonospace: true,
                        ),
                        _RowItem(
                          label: 'Recorded At',
                          value: DateFormatter.formatDateTime(usage.usedAt),
                        ),
                        _RowItem(
                          label: 'Sync Status',
                          value: isOffline ? 'Queued (Offline) ⏳' : 'Synced to Cloud ✓',
                          valueColor: isOffline ? AppColors.warning : AppColors.success,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.s32),

                  // Bottom Action Buttons
                  AppButton.primary(
                    label: 'Scan Another Instrument',
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                    onPressed: () => context.go('/scanner'),
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  AppButton.secondary(
                    label: 'Back to Dashboard',
                    onPressed: () => context.go('/home'),
                  ),
                  const SizedBox(height: AppDimensions.s16),
                ],
              ),
            ),
          ),
        ),
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
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
