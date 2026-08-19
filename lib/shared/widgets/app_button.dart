import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant {
  primary,
  primaryInverse,
  secondary,
  outline,
  ghost,
  destructive,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? iconWidget;
  final double? height;
  final double? width;
  final Color? textColor;
  final Color? borderColor;

  /// Primary: Black pill, white text (for light backgrounds)
  const AppButton.primary({
    super.key,
    String? text,
    String? label,
    this.onPressed,
    this.isLoading = false,
    Widget? icon,
    this.height = AppDimensions.buttonPrimaryHeight,
    this.width = double.infinity,
    this.textColor,
    this.borderColor,
  })  : label = text ?? label ?? '',
        iconWidget = icon,
        variant = AppButtonVariant.primary;

  /// Primary Inverse: White pill, black text, soft shadow (for dark/image backgrounds)
  const AppButton.primaryInverse({
    super.key,
    String? text,
    String? label,
    this.onPressed,
    this.isLoading = false,
    Widget? icon,
    this.height = AppDimensions.buttonPrimaryHeight,
    this.width = double.infinity,
    this.textColor,
    this.borderColor,
  })  : label = text ?? label ?? '',
        iconWidget = icon,
        variant = AppButtonVariant.primaryInverse;

  /// Secondary: Subtle gray / transparent button
  const AppButton.secondary({
    super.key,
    String? text,
    String? label,
    this.onPressed,
    this.isLoading = false,
    Widget? icon,
    this.height = AppDimensions.buttonSecondaryHeight,
    this.width = double.infinity,
    this.textColor,
    this.borderColor,
  })  : label = text ?? label ?? '',
        iconWidget = icon,
        variant = AppButtonVariant.secondary;

  /// Outline: Transparent, black or custom border
  AppButton.outline({
    super.key,
    String? text,
    String? label,
    IconData? icon,
    Widget? iconWidget,
    this.onPressed,
    this.isLoading = false,
    this.height = AppDimensions.buttonPrimaryHeight,
    this.width = double.infinity,
    this.textColor,
    this.borderColor,
  })  : label = text ?? label ?? '',
        iconWidget = iconWidget ?? (icon != null ? Icon(icon, size: 20) : null),
        variant = AppButtonVariant.outline;

  /// Ghost: Transparent background, text only
  const AppButton.ghost({
    super.key,
    String? text,
    String? label,
    this.textColor,
    this.onPressed,
    this.isLoading = false,
    Widget? icon,
    this.height = AppDimensions.buttonGhostHeight,
    this.width,
    this.borderColor,
  })  : label = text ?? label ?? '',
        iconWidget = icon,
        variant = AppButtonVariant.ghost;

  /// Destructive: Red button
  const AppButton.destructive({
    super.key,
    String? text,
    String? label,
    this.onPressed,
    this.isLoading = false,
    Widget? icon,
    this.height = AppDimensions.buttonPrimaryHeight,
    this.width = double.infinity,
    this.textColor,
    this.borderColor,
  })  : label = text ?? label ?? '',
        iconWidget = icon,
        variant = AppButtonVariant.destructive;

  /// Icon button: 44px circular or rounded icon button
  static Widget icon({
    Key? key,
    required IconData icon,
    Color? backgroundColor,
    Color? iconColor,
    VoidCallback? onPressed,
    double size = 44,
  }) {
    return Container(
      key: key,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0x26FFFFFF),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0x40FFFFFF),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;
    List<BoxShadow> shadows = const [];

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = onPressed == null ? AppColors.borderStrong : AppColors.primary;
        foregroundColor = onPressed == null ? AppColors.textTertiary : (textColor ?? AppColors.primaryInverse);
        break;

      case AppButtonVariant.primaryInverse:
        backgroundColor = onPressed == null ? const Color(0x99FFFFFF) : AppColors.primaryInverse;
        foregroundColor = onPressed == null ? AppColors.textTertiary : (textColor ?? AppColors.primary);
        shadows = const [
          BoxShadow(
            color: Color(0x26000000), // rgba(0,0,0,0.15)
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ];
        break;

      case AppButtonVariant.secondary:
        backgroundColor = AppColors.backgroundDefault;
        foregroundColor = onPressed == null ? AppColors.textTertiary : (textColor ?? AppColors.textPrimary);
        borderSide = BorderSide(
          color: borderColor ?? (onPressed == null ? AppColors.borderSubtle : AppColors.borderStrong),
          width: 1.5,
        );
        break;

      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = onPressed == null ? AppColors.textTertiary : (textColor ?? AppColors.textPrimary);
        borderSide = BorderSide(
          color: borderColor ?? (onPressed == null ? AppColors.borderSubtle : AppColors.primary),
          width: 1.5,
        );
        break;

      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = onPressed == null ? AppColors.textTertiary : (textColor ?? AppColors.accent);
        break;

      case AppButtonVariant.destructive:
        backgroundColor = onPressed == null ? AppColors.borderStrong : AppColors.error;
        foregroundColor = Colors.white;
        break;
    }

    final buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconWidget != null) ...[
                IconTheme(
                  data: IconThemeData(color: foregroundColor, size: 20),
                  child: iconWidget!,
                ),
                const SizedBox(width: AppDimensions.s8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (variant == AppButtonVariant.primary ||
                          variant == AppButtonVariant.primaryInverse ||
                          variant == AppButtonVariant.destructive
                          ? AppTypography.buttonLarge
                          : AppTypography.button)
                      .copyWith(color: foregroundColor),
                ),
              ),
            ],
          );

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        boxShadow: shadows,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
        ),
        child: buttonChild,
      ),
    );
  }
}
