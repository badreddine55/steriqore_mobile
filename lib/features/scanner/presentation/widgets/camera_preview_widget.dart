import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraPreviewWidget extends StatelessWidget {
  final MobileScannerController controller;
  final ValueChanged<String> onCodeDetected;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.onCodeDetected,
  });

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: (capture) {
        final barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          final rawVal = barcode.rawValue;
          if (rawVal != null && rawVal.trim().isNotEmpty) {
            onCodeDetected(rawVal);
            break;
          }
        }
      },
    );
  }
}
