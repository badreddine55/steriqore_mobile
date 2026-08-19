import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isPassword;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final dynamic prefixIcon; // Can be IconData or Widget
  final dynamic suffixIcon; // Can be IconData or Widget
  final VoidCallback? onSuffixTap;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool isMonospace;
  final int maxLines;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.isMonospace = false,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword || widget.obscureText;
  }

  Widget? _buildPrefix() {
    if (widget.prefixIcon == null) return null;
    if (widget.prefixIcon is IconData) {
      return Icon(
        widget.prefixIcon as IconData,
        size: 20,
        color: const Color(0xFF8E8E93),
      );
    }
    if (widget.prefixIcon is Widget) {
      return widget.prefixIcon as Widget;
    }
    return null;
  }

  Widget? _buildSuffix() {
    if (widget.isPassword || widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF8E8E93),
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    if (widget.suffixIcon == null) return null;
    if (widget.suffixIcon is IconData) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon as IconData,
          size: 20,
          color: const Color(0xFF8E8E93),
        ),
        onPressed: widget.onSuffixTap,
      );
    }
    if (widget.suffixIcon is Widget) {
      if (widget.onSuffixTap != null) {
        return GestureDetector(
          onTap: widget.onSuffixTap,
          child: widget.suffixIcon as Widget,
        );
      }
      return widget.suffixIcon as Widget;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          maxLines: widget.maxLines,
          style: widget.isMonospace
              ? AppTypography.data
              : AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
            errorText: widget.errorText,
            errorStyle: AppTypography.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: _buildPrefix(),
            suffixIcon: _buildSuffix(),
            filled: true,
            fillColor: AppColors.backgroundDefault,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
