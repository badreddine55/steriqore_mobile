import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/manual_entry_bottom_sheet.dart';
import '../widgets/scan_feedback_banner.dart';
import '../widgets/scan_overlay_widget.dart';
import '../widgets/torch_button.dart';

class ScannerPage extends StatefulWidget {
  final ScannerBloc? scannerBloc;
  final MobileScannerController? cameraController;

  const ScannerPage({
    super.key,
    this.scannerBloc,
    this.cameraController,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final MobileScannerController _controller;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.cameraController ??
        MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
          formats: const [
            BarcodeFormat.dataMatrix,
            BarcodeFormat.qrCode,
            BarcodeFormat.code128,
            BarcodeFormat.ean13,
          ],
        );
  }

  @override
  void dispose() {
    if (widget.cameraController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggleTorch(BuildContext context) async {
    final bloc = context.read<ScannerBloc>();
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(() => _isTorchOn = !_isTorchOn);
    bloc.add(const ScannerTorchToggled());
  }

  void _showManualEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ManualEntryBottomSheet(
        recentCodes: const ['LBL-2026-001', 'LOT-2026-89A', 'LBL-2026-007834'],
        onSubmit: (code) {
          context.read<ScannerBloc>().add(ScannerManualCodeSubmitted(code));
        },
      ),
    );
  }

  void _showBlockingDialog(BuildContext context, String reason, String code, String? recallReason) {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.s24),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.gpp_bad_rounded, color: AppColors.error, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'SAFETY COMPLIANCE GATE (410)',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Instrument Blocked',
                              style: AppTypography.h3.copyWith(letterSpacing: -0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.s16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.20)),
                    ),
                    child: Text(
                      reason,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (recallReason != null && recallReason.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reason: $recallReason',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.s12),
                  Text(
                    'This pouch cannot be used on patients. Please return it to the sterilization bay for reprocessing.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  Row(
                    children: [
                      Text(
                        'Package Code: ',
                        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          code,
                          style: AppTypography.data.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.s24),
                  AppButton.primary(
                    label: 'Acknowledge & Scan Next',
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      context.read<ScannerBloc>().add(const ScannerAcknowledgeBlockRequested());
                    },
                  ),
                  const SizedBox(height: AppDimensions.s8),
                  AppButton.ghost(
                    label: 'View Traceability Dossier',
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      context.read<ScannerBloc>().add(const ScannerAcknowledgeBlockRequested());
                      context.push('/label/$code');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocConsumer<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerLabelFound) {
          try {
            HapticFeedback.mediumImpact();
          } catch (_) {}
          context.push('/label/${state.label.code}');
        } else if (state is ScannerLabelBlocked) {
          _showBlockingDialog(context, state.reason, state.code, state.recallReason);
        } else if (state is ScannerSessionExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          context.go('/login');
        }
      },
      builder: (context, state) {
        if (state is ScannerPermissionDeniedState) {
          return _buildPermissionDeniedView(context);
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Camera Live Feed (Always visible underneath)
              CameraPreviewWidget(
                controller: _controller,
                onCodeDetected: (code) {
                  context.read<ScannerBloc>().add(ScannerCodeDetected(code));
                },
              ),

              // Corner Brackets & Dark Vignette Overlay
              const ScanOverlayWidget(
                cutOutSize: 280,
                hintText: 'Align DataMatrix or QR code within frame',
              ),

              // Top Bar (Back button + Format Chip + Feedback Banner)
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.s16,
                        vertical: AppDimensions.s8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                                  onPressed: () => context.pop(),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.qr_code_2_rounded, size: 15, color: AppColors.accent),
                                    const SizedBox(width: 7),
                                    Text(
                                      'QR & DataMatrix',
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 48), // Balances the back button
                            ],
                          ),

                          // Inline Feedback Banners (404, 409, 429, Offline, Error)
                          ScanFeedbackBanner(
                            state: state,
                            onDismiss: () {
                              context.read<ScannerBloc>().add(const ScannerDismissBannerRequested());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Processing Pill (Active verification over live camera)
              if (state is ScannerProcessing)
                Positioned(
                  left: 24,
                  right: 24,
                  top: MediaQuery.of(context).size.height * 0.42,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.30),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Verifying: ${state.code}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom Actions (Manual Entry & Torch)
              Positioned(
                left: AppDimensions.s20,
                right: AppDimensions.s20,
                bottom: AppDimensions.s32,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Manual Code Entry Outline Pill
                          GestureDetector(
                            onTap: () => _showManualEntrySheet(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.s16,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.keyboard_outlined, size: 18, color: Colors.white),
                                  const SizedBox(width: AppDimensions.s8),
                                  Text(
                                    'Enter Code Manually',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Torch Toggle
                          TorchButton(
                            isTorchOn: _isTorchOn,
                            onToggle: () => _toggleTorch(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // 1. Direct explicit widget bloc injection
    if (widget.scannerBloc != null) {
      return BlocProvider.value(
        value: widget.scannerBloc!,
        child: body,
      );
    }

    // 2. Existing BlocProvider in ancestor widget tree (e.g. from MultiBlocProvider in main.dart)
    try {
      context.read<ScannerBloc>();
      return body;
    } catch (_) {}

    // 3. Fallback Service Locator creation
    return BlocProvider(
      create: (_) => sl<ScannerBloc>()..add(const ScannerInitRequested()),
      child: body,
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Camera Access Required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.s20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.no_photography_rounded, size: 48, color: AppColors.error),
              ),
              const SizedBox(height: AppDimensions.s20),
              Text('Camera Permission Denied', style: AppTypography.h2),
              const SizedBox(height: AppDimensions.s8),
              Text(
                'Camera access is needed to scan sterilization labels on instrument pouches.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppDimensions.s24),
              AppButton.primary(
                label: 'Enter Code Manually',
                onPressed: () => _showManualEntrySheet(context),
              ),
              const SizedBox(height: AppDimensions.s12),
              AppButton.secondary(
                label: 'Retry Permission',
                onPressed: () {
                  context.read<ScannerBloc>().add(const ScannerInitRequested());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
