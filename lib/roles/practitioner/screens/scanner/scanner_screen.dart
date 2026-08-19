import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/steriqore_shared.dart';
import '../../blocs/scanner/scanner_bloc.dart';
import '../../blocs/scanner/scanner_event.dart';
import '../../blocs/scanner/scanner_state.dart';
import '../../practitioner_routes.dart';
import '../../widgets/scan_reticle_overlay.dart';
import '../../widgets/torch_toggle_button.dart';

class ScannerScreen extends StatefulWidget {
  final ScannerBloc? scannerBloc;
  final MobileScannerController? cameraController;

  const ScannerScreen({
    super.key,
    this.scannerBloc,
    this.cameraController,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late final MobileScannerController _cameraController;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraController = widget.cameraController ??
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
    WidgetsBinding.instance.removeObserver(this);
    if (widget.cameraController == null) {
      _cameraController.dispose();
    }
    _manualInputController.dispose();
    super.dispose();
  }

  void _toggleTorch(BuildContext context) async {
    final bloc = context.read<ScannerBloc>();
    await _cameraController.toggleTorch();
    if (!mounted) return;
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    bloc.add(const ScannerTorchToggled());
  }

  void _showManualEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manual Code Entry',
                        style: steriqoreFont(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the alphanumeric code printed on the sterilization pouch:',
                    style: steriqoreFont(fontSize: 13.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _manualInputController,
                    autofocus: true,
                    style: steriqoreFont(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'e.g. LOT-2026-89A-001',
                      prefixIcon: Icon(Icons.qr_code_2_rounded, size: 22),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DentisTrackPrimaryButton(
                    label: 'Verify Label',
                    onPressed: () {
                      final code = _manualInputController.text.trim();
                      if (code.isNotEmpty) {
                        Navigator.of(sheetCtx).pop();
                        context.read<ScannerBloc>().add(ScannerManualCodeSubmitted(code));
                      }
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
    final content = BlocConsumer<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerSuccess) {
          Navigator.of(context).pushReplacementNamed(
            PractitionerRoutes.labelDetail,
            arguments: {'code': state.label.code, 'label': state.label},
          );
        } else if (state is ScannerBlocked) {
          Navigator.of(context).pushReplacementNamed(
            PractitionerRoutes.labelDetail,
            arguments: {'code': state.label.code, 'label': state.label},
          );
        } else if (state is ScannerAlreadyUsed) {
          if (state.label != null) {
            Navigator.of(context).pushReplacementNamed(
              PractitionerRoutes.labelDetail,
              arguments: {'code': state.label!.code, 'label': state.label},
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.warning),
            );
          }
        } else if (state is ScannerNotFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid code: No label found matching "${state.code}".'),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<ScannerBloc>().add(const ScannerReset());
        } else if (state is ScannerRateLimited) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Too many scans. Please wait ${state.retryAfterSeconds}s.'),
              backgroundColor: AppColors.secondary,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ScannerPermissionError) {
          return _buildPermissionDeniedView(context);
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Camera View
              MobileScanner(
                controller: _cameraController,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final rawVal = barcode.rawValue;
                    if (rawVal != null && rawVal.trim().isNotEmpty) {
                      context.read<ScannerBloc>().add(ScannerBarcodeDetected(rawVal));
                      break;
                    }
                  }
                },
              ),

              // Animated Corner Reticle Overlay
              const ScanReticleOverlay(
                cutOutSize: 240,
                hintText: 'Align DataMatrix or QR code within frame',
              ),

              // Top Floating Action Bar
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DentisTrackIconButton(
                            icon: Icons.arrow_back_rounded,
                            color: Colors.white,
                            backgroundColor: Colors.black.withValues(alpha: 0.50),
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Text(
                                  'DataMatrix & QR Active',
                                  style: steriqoreFont(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Processing Spinner Overlay
              if (state is ScannerProcessing)
                Container(
                  color: Colors.black.withValues(alpha: 0.65),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Verifying label compliance...',
                            style: steriqoreFont(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Code: ${state.code}',
                            style: steriqoreFont(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Bottom Floating Controls
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Manual Code Entry Fallback Pill
                          GestureDetector(
                            onTap: () => _showManualEntrySheet(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.keyboard_outlined, size: 20, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Manual Entry',
                                    style: steriqoreFont(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Torch Flashlight Toggle
                          TorchToggleButton(
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

    if (widget.scannerBloc != null) {
      return BlocProvider.value(
        value: widget.scannerBloc!,
        child: content,
      );
    }

    return BlocProvider(
      create: (_) => ScannerBloc()..add(const ScannerInitialized()),
      child: content,
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      appBar: AppBar(
        title: Text('Scanner Access Required', style: steriqoreFont(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.no_photography_rounded, size: 54, color: AppColors.error),
              ),
              const SizedBox(height: 24),
              Text(
                'Camera Permission Denied',
                textAlign: TextAlign.center,
                style: steriqoreFont(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Camera access is required to scan sterilization package barcodes and DataMatrix labels on instruments.',
                textAlign: TextAlign.center,
                style: steriqoreFont(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              DentisTrackPrimaryButton(
                label: 'Enter Code Manually',
                icon: const Icon(Icons.keyboard_outlined, size: 20, color: Colors.white),
                onPressed: () => _showManualEntrySheet(context),
              ),
              const SizedBox(height: 12),
              DentisTrackSecondaryButton(
                label: 'Retry Camera Access',
                onPressed: () {
                  context.read<ScannerBloc>().add(const ScannerInitialized());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
