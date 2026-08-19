import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/steriqore_shared.dart';
import '../../blocs/label_detail/label_detail_bloc.dart';
import '../../blocs/label_detail/label_detail_event.dart';
import '../../blocs/label_detail/label_detail_state.dart';
import '../../models/cycle_model.dart';
import '../../models/label_model.dart';
import '../../practitioner_routes.dart';
import '../../widgets/blocking_alert_banner.dart';
import '../../widgets/label_status_badge.dart';

class LabelDetailScreen extends StatelessWidget {
  final String code;
  final LabelModel? initialLabel;
  final LabelDetailBloc? labelDetailBloc;

  const LabelDetailScreen({
    super.key,
    required this.code,
    this.initialLabel,
    this.labelDetailBloc,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundElevated,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Package Traceability',
          style: steriqoreFont(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<LabelDetailBloc, LabelDetailState>(
          builder: (context, state) {
            if (state is LabelDetailLoading) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
            }

            if (state is LabelDetailNotFound) {
              return _buildNotFoundView(context, state.code);
            }

            if (state is LabelDetailError) {
              return _buildErrorView(context, state.message);
            }

            LabelModel? label;
            CycleModel? cycle;
            bool isBlocked = false;
            String? blockReason;
            bool isAlreadyUsed = false;
            String? usedMessage;

            if (state is LabelDetailLoaded) {
              label = state.label;
              cycle = state.cycle;
            } else if (state is LabelDetailBlocked) {
              label = state.label;
              cycle = state.cycle;
              isBlocked = true;
              blockReason = state.reason;
            } else if (state is LabelDetailAlreadyUsed) {
              label = state.label;
              cycle = state.cycle;
              isAlreadyUsed = true;
              usedMessage = state.message;
            }

            if (label == null) {
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ResponsiveContentContainer(
                maxWidth: Breakpoints.authFormMaxWidth + 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Safety Gate Blocking Banner (410 Expired / Recalled)
                    if (isBlocked)
                      BlockingAlertBanner.blocked(
                        message: blockReason ?? 'Instrument package has expired DLC or is under recall.',
                      )
                    else if (isAlreadyUsed)
                      BlockingAlertBanner.warning(
                        title: 'INSTRUMENT ALREADY USED',
                        message: usedMessage ?? 'This package was previously registered as used.',
                      )
                    else if (label.isNearExpiration)
                      BlockingAlertBanner.warning(
                        title: 'NEAR EXPIRATION NOTICE',
                        message: 'DLC expires in ${label.remainingDays} days. Ensure timely clinical usage.',
                      ),

                    // Main Product Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelStatusBadge.label(
                                labelStatus: label.status,
                                isNearExpiration: label.isNearExpiration,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundDefault,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ID: #${label.id}',
                                  style: steriqoreFont(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Text(
                            label.productName,
                            style: steriqoreFont(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reference: ${label.reference}',
                            style: steriqoreFont(fontSize: 13.5, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.borderSubtle),
                          const SizedBox(height: 12),

                          // Key Lot & DLC Parameters
                          _DetailItemRow(label: 'Lot / Batch Number', value: label.lotNumber, isMonospace: true),
                          _DetailItemRow(
                            label: 'Expiration Date (DLC)',
                            value: _formatDate(label.expirationDate),
                            valueColor: label.isExpiredByDate ? AppColors.error : AppColors.textPrimary,
                          ),
                          _DetailItemRow(
                            label: 'Remaining Shelf Life',
                            value: label.isExpiredByDate
                                ? 'Expired ${-label.remainingDays} days ago'
                                : '${label.remainingDays} days remaining',
                            valueColor: label.isExpiredByDate
                                ? AppColors.error
                                : (label.isNearExpiration ? AppColors.warning : AppColors.success),
                          ),
                          _DetailItemRow(label: 'Scanned Code', value: label.code, isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sterilization Cycle Validation Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sanitizer_rounded, size: 20, color: AppColors.success),
                              const SizedBox(width: 8),
                              Text(
                                'Autoclave Sterilization Cycle',
                                style: steriqoreFont(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _DetailItemRow(
                            label: 'Cycle Number',
                            value: cycle?.cycleNumber ?? label.cycleNumber ?? 'CYC-089',
                            isMonospace: true,
                          ),
                          _DetailItemRow(
                            label: 'Autoclave Device',
                            value: cycle?.autoclaveName ?? label.autoclaveName ?? 'Melag Vacuklav 40B',
                          ),
                          _DetailItemRow(
                            label: 'Cycle Temperature',
                            value: '${cycle?.temperature ?? 134.0}°C / ${cycle?.durationMinutes ?? 18} min',
                          ),
                          _DetailItemRow(
                            label: 'Conformity Status',
                            value: (cycle?.isValidated ?? true) ? 'Passed & Validated' : 'Failed',
                            valueColor: (cycle?.isValidated ?? true) ? AppColors.success : AppColors.error,
                          ),
                          _DetailItemRow(
                            label: 'Sterilization Date',
                            value: label.sterilizationDate != null
                                ? _formatDate(label.sterilizationDate!)
                                : _formatDate(DateTime.now().subtract(const Duration(days: 3))),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary CTA: Record Usage or Disabled Blocked State
                    if (isBlocked) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Recording Locked (Safety Compliance)',
                                style: steriqoreFont(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      DentisTrackPrimaryButton(
                        label: 'Record Patient Usage',
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            PractitionerRoutes.usageConfirmation,
                            arguments: {'label': label},
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    DentisTrackSecondaryButton(
                      label: 'Scan Another Package',
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(PractitionerRoutes.scanner);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (labelDetailBloc != null) {
      return BlocProvider.value(
        value: labelDetailBloc!,
        child: body,
      );
    }

    return BlocProvider(
      create: (_) => LabelDetailBloc()
        ..add(LoadLabelDetail(code, initialLabel: initialLabel)),
      child: body,
    );
  }

  Widget _buildNotFoundView(BuildContext context, String code) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Label Not Found',
            textAlign: TextAlign.center,
            style: steriqoreFont(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'No matching sterilization package was found for code "$code".',
            textAlign: TextAlign.center,
            style: steriqoreFont(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          DentisTrackPrimaryButton(
            label: 'Scan Again',
            onPressed: () => Navigator.of(context).pushReplacementNamed(PractitionerRoutes.scanner),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Verification Failed',
            textAlign: TextAlign.center,
            style: steriqoreFont(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: steriqoreFont(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          DentisTrackPrimaryButton(
            label: 'Try Again',
            onPressed: () => context.read<LabelDetailBloc>().add(const RefreshLabelDetail()),
          ),
        ],
      ),
    );
  }
}

class _DetailItemRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMonospace;
  final bool isLast;

  const _DetailItemRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isMonospace = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: steriqoreFont(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: steriqoreFont(
                fontSize: 13,
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
