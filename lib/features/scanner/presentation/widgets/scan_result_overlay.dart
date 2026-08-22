import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/label.dart';

class ScanResultOverlay extends StatelessWidget {
  final Label label;
  final VoidCallback onDismiss;
  final VoidCallback? onUseInstrument;

  const ScanResultOverlay({
    super.key,
    required this.label,
    required this.onDismiss,
    this.onUseInstrument,
  });

  @override
  Widget build(BuildContext context) {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final bool isBlocked = label.isExpired || label.isRecalled || label.alreadyUsed;
    final Color statusColor = _getStatusColor(label);
    final IconData statusIcon = _getStatusIcon(label);
    final String statusTitle = _getStatusTitle(label);
    final String statusMessage = _getStatusMessage(label);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      color: Colors.black.withValues(alpha: 0.65),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Header with colored accent
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.s20),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppDimensions.radius2xl),
                              topRight: Radius.circular(AppDimensions.radius2xl),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  statusIcon,
                                  color: statusColor,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      statusTitle,
                                      style: AppTypography.h3.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      statusMessage,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        const Divider(
                          height: 1,
                          color: AppColors.borderSubtle,
                        ),

                        // Product Details
                        Padding(
                          padding: const EdgeInsets.all(AppDimensions.s20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name
                              Text(
                                label.productName,
                                style: AppTypography.h2,
                              ),
                              const SizedBox(height: AppDimensions.s14),

                              // Lot Number
                              _DetailRow(
                                icon: Icons.qr_code_outlined,
                                label: 'Lot / Batch Number',
                                value: label.lotNumber,
                                isMono: true,
                              ),
                              const SizedBox(height: AppDimensions.s12),

                              // DLC
                              _DetailRow(
                                icon: Icons.calendar_today_outlined,
                                label: 'Expiration (DLC)',
                                value: DateFormatter.formatDate(label.expirationDate),
                                valueColor: label.isExpired ? AppColors.error : AppColors.textPrimary,
                              ),
                              const SizedBox(height: AppDimensions.s12),

                              // Sterilization Cycle
                              if (label.cycleId != null) ...[
                                _DetailRow(
                                  icon: Icons.local_hospital_outlined,
                                  label: 'Autoclave Cycle',
                                  value: 'CYC-${label.cycleId}',
                                  isMono: true,
                                ),
                                const SizedBox(height: AppDimensions.s12),
                              ],

                              // Package code
                              _DetailRow(
                                icon: Icons.tag_rounded,
                                label: 'Pouch Alphanumeric Code',
                                value: label.code,
                                isMono: true,
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.s20,
                            0,
                            AppDimensions.s20,
                            AppDimensions.s20,
                          ),
                          child: Column(
                            children: [
                              if (!isBlocked && onUseInstrument != null) ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: AppDimensions.buttonPrimaryHeight,
                                  child: ElevatedButton(
                                    onPressed: onUseInstrument,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.primaryInverse,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.buttonPrimaryHeight / 2,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Use on Patient',
                                      style: AppTypography.buttonLarge,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s12),
                              ],
                              if (isBlocked) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppDimensions.s16),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd,
                                    ),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.block_rounded,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppDimensions.s12),
                                      Expanded(
                                        child: Text(
                                          'This instrument cannot be used. ${label.blockReason ?? "Please return pouch to sterilization bay."}',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s16),
                              ],
                              SizedBox(
                                width: double.infinity,
                                height: AppDimensions.buttonSecondaryHeight,
                                child: TextButton(
                                  onPressed: onDismiss,
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.buttonSecondaryHeight / 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    isBlocked ? 'Scan Another Package' : 'Close',
                                    style: AppTypography.button.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(Label label) {
    if (label.isExpired) return AppColors.error;
    if (label.isRecalled) return AppColors.error;
    if (label.alreadyUsed) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStatusIcon(Label label) {
    if (label.isExpired) return Icons.error_outline_rounded;
    if (label.isRecalled) return Icons.warning_amber_rounded;
    if (label.alreadyUsed) return Icons.info_outline_rounded;
    return Icons.check_circle_outline_rounded;
  }

  String _getStatusTitle(Label label) {
    if (label.isExpired) return 'Instrument Expired';
    if (label.isRecalled) return 'Instrument Recalled';
    if (label.alreadyUsed) return 'Already Used';
    return 'Instrument Valid';
  }

  String _getStatusMessage(Label label) {
    if (label.isExpired) {
      return 'This instrument has exceeded its sterilization validity date and cannot be used.';
    }
    if (label.isRecalled) {
      return 'This instrument lot has been recalled for safety reasons.';
    }
    if (label.alreadyUsed) {
      return 'This instrument has already been recorded as used on a patient.';
    }
    return 'Sterilization cycle validated and biological test conform. Safe for clinical use.';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMono;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: (isMono ? AppTypography.data : AppTypography.body).copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
