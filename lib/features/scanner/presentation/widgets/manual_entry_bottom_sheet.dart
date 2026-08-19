import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class ManualEntryBottomSheet extends StatefulWidget {
  final List<String> recentCodes;
  final ValueChanged<String> onSubmit;

  const ManualEntryBottomSheet({
    super.key,
    this.recentCodes = const [],
    required this.onSubmit,
  });

  @override
  State<ManualEntryBottomSheet> createState() => _ManualEntryBottomSheetState();
}

class _ManualEntryBottomSheetState extends State<ManualEntryBottomSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.length < 5) {
      setState(() => _error = 'Code must be at least 5 characters');
      return;
    }
    if (code.length > 50) {
      setState(() => _error = 'Code must not exceed 50 characters');
      return;
    }
    Navigator.of(context).pop();
    widget.onSubmit(code);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            decoration: const BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radius2xl),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppDimensions.s12),
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Enter Code Manually', style: AppTypography.h3),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  'Enter the alphanumeric barcode or DataMatrix string printed on pouch:',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.s16),

                // Code Input
                AppTextField(
                  hint: 'e.g. LBL-2026-007834',
                  controller: _controller,
                  autofocus: true,
                  isMonospace: true,
                  prefixIcon: const Icon(Icons.qr_code_2_rounded, size: 22),
                  errorText: _error,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppDimensions.s20),

                // Primary Search Button
                AppButton.primary(
                  label: 'Search',
                  onPressed: _submit,
                ),

                // Recent Codes Quick Tap
                if (widget.recentCodes.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s20),
                  Text(
                    'RECENT CODES',
                    style: AppTypography.navLabel.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppDimensions.s8),
                  Wrap(
                    spacing: AppDimensions.s8,
                    runSpacing: AppDimensions.s8,
                    children: widget.recentCodes.take(5).map((code) {
                      return GestureDetector(
                        onTap: () {
                          _controller.text = code;
                          _submit();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            code,
                            style: AppTypography.caption.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
