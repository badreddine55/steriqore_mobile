import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
export '../core/utils/responsive.dart';

// ---------------------------------------------------------------------------
// Typography Helpers
// ---------------------------------------------------------------------------

TextStyle dentistrackFont({
  double fontSize = 15,
  FontWeight fontWeight = FontWeight.w400,
  double letterSpacing = -0.1,
  Color color = AppColors.textPrimary,
  double height = 1.35,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    color: color,
    height: height,
  );
}

// ---------------------------------------------------------------------------
// Background Wrapper with Dental Photography & Clinical Gradient Scrim
// ---------------------------------------------------------------------------

class DentisTrackAuthBackground extends StatelessWidget {
  final Widget child;

  const DentisTrackAuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base dark fallback color
        Container(color: const Color(0xFF0A0F14)),

        // High-resolution dental equipment photo
        Image.asset(
          'assets/images/dentistrack_auth_bg.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Elegant fallback gradient if asset not yet bundled
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                ),
              ),
            );
          },
        ),

        // Multi-stage cinematic clinical scrim overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.35, 0.70, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.40),
                Colors.black.withValues(alpha: 0.75),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),

        // Foreground content
        Scaffold(
          backgroundColor: Colors.transparent,
          body: child,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Brand Logo
// ---------------------------------------------------------------------------

class DentisTrackLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final bool isInverse;

  const DentisTrackLogo({
    super.key,
    this.size = 48,
    this.showSubtitle = false,
    this.isInverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isInverse ? AppColors.textInverse : AppColors.textPrimary;
    final subColor = isInverse ? Colors.white70 : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.verified_user_rounded,
            size: size * 0.56,
            color: AppColors.primaryInverse,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Dentis',
                      style: dentistrackFont(
                        fontSize: size * 0.46,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: titleColor,
                      ),
                    ),
                    TextSpan(
                      text: 'Track',
                      style: dentistrackFont(
                        fontSize: size * 0.46,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showSubtitle)
                Text(
                  'HEALTHCARE · DENTAL TRACEABILITY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: dentistrackFont(
                    fontSize: (size * 0.20).clamp(8.0, 11.0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: subColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Primary Pill Button (54px height, 27px radius, black fill)
// ---------------------------------------------------------------------------

class DentisTrackPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? height;
  final double? width;

  const DentisTrackPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height,
    this.width,
  });

  @override
  State<DentisTrackPrimaryButton> createState() => _DentisTrackPrimaryButtonState();
}

class _DentisTrackPrimaryButtonState extends State<DentisTrackPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final btnHeight = widget.height ?? 54.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed && !isDisabled ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: btnHeight,
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.borderSubtle
                : (_isPressed ? AppColors.secondary : AppColors.primary),
            borderRadius: BorderRadius.circular(btnHeight / 2),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.18),
                      blurRadius: _isPressed ? 6 : 14,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ],
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: dentistrackFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: isDisabled ? AppColors.textTertiary : AppColors.primaryInverse,
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
}

// ---------------------------------------------------------------------------
// Secondary Button (48px height, 24px radius, #F2F2F7 fill)
// ---------------------------------------------------------------------------

class DentisTrackSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? height;
  final double? width;

  const DentisTrackSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height,
    this.width,
  });

  @override
  State<DentisTrackSecondaryButton> createState() => _DentisTrackSecondaryButtonState();
}

class _DentisTrackSecondaryButtonState extends State<DentisTrackSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final btnHeight = widget.height ?? 48.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: btnHeight,
          width: widget.width,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.borderSubtle : AppColors.backgroundDefault,
            borderRadius: BorderRadius.circular(btnHeight / 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: dentistrackFont(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: AppColors.textPrimary,
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
}

// ---------------------------------------------------------------------------
// Outline Button (48px height, 24px radius, 1.5px black border)
// ---------------------------------------------------------------------------

class DentisTrackOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final double? width;

  const DentisTrackOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
    this.height,
    this.width,
  });

  @override
  State<DentisTrackOutlineButton> createState() => _DentisTrackOutlineButtonState();
}

class _DentisTrackOutlineButtonState extends State<DentisTrackOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.borderColor ?? AppColors.primary;
    final text = widget.textColor ?? AppColors.textPrimary;
    final btnHeight = widget.height ?? 48.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: btnHeight,
          width: widget.width,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isPressed ? Colors.black.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(btnHeight / 2),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: dentistrackFont(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: text,
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
}

// ---------------------------------------------------------------------------
// Text / Link Button
// ---------------------------------------------------------------------------

class DentisTrackLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const DentisTrackLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          label,
          style: dentistrackFont(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.accent,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text Field (52px height, 14px radius, #F2F2F7 background)
// ---------------------------------------------------------------------------

class DentisTrackTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool autoFocus;
  final FocusNode? focusNode;

  const DentisTrackTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.autoFocus = false,
    this.focusNode,
  });

  @override
  State<DentisTrackTextField> createState() => _DentisTrackTextFieldState();
}

class _DentisTrackTextFieldState extends State<DentisTrackTextField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final nowHas = widget.controller.text.isNotEmpty;
    if (nowHas != _hasText) {
      setState(() => _hasText = nowHas);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: dentistrackFont(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          autofocus: widget.autoFocus,
          style: dentistrackFont(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: _hasText
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, size: 18, color: AppColors.borderStrong),
                    onPressed: () => widget.controller.clear(),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Password Input with Visibility Eye Toggle
// ---------------------------------------------------------------------------

class DentisTrackPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const DentisTrackPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<DentisTrackPasswordField> createState() => _DentisTrackPasswordFieldState();
}

class _DentisTrackPasswordFieldState extends State<DentisTrackPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: dentistrackFont(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscure,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: dentistrackFont(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Password Strength Meter
// ---------------------------------------------------------------------------

class DentisTrackPasswordStrengthBar extends StatelessWidget {
  final int score; // 0..4

  const DentisTrackPasswordStrengthBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    if (score == 0) return const SizedBox.shrink();

    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      Colors.transparent,
      AppColors.error,
      AppColors.warning,
      AppColors.accent,
      AppColors.success,
    ];

    final color = colors[score];
    final label = labels[score];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              final filled = i < score;
              return Expanded(
                child: Container(
                  height: 3.5,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: filled ? color : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Security: $label',
                style: dentistrackFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Flexible(
                child: Text(
                  'Min 8 chars, numbers & symbols',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: dentistrackFont(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Checkbox (24x24px, 6px radius, black fill on check)
// ---------------------------------------------------------------------------

class DentisTrackCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool isExpanded;

  const DentisTrackCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.borderStrong,
          width: 1.5,
        ),
      ),
      child: value
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );

    final textWidget = Text(
      label,
      style: dentistrackFont(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: isExpanded
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                box,
                const SizedBox(width: 10),
                Expanded(child: textWidget),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                box,
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.loose,
                  child: textWidget,
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Clinical Status Banners
// ---------------------------------------------------------------------------

class DentisTrackStatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final bool isWarning;

  const DentisTrackStatusBanner.error({
    super.key,
    required this.message,
  })  : isError = true,
        isWarning = false;

  const DentisTrackStatusBanner.success({
    super.key,
    required this.message,
  })  : isError = false,
        isWarning = false;

  const DentisTrackStatusBanner.warning({
    super.key,
    required this.message,
  })  : isError = false,
        isWarning = true;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? AppColors.error
        : (isWarning ? AppColors.warning : AppColors.success);
    final icon = isError
        ? Icons.error_outline_rounded
        : (isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: dentistrackFont(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circular Touch Icon Button
// ---------------------------------------------------------------------------

class DentisTrackIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;

  const DentisTrackIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Icon(
          icon,
          size: 22,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
