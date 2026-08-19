import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;
  final void Function(String email, String password) onSubmit;

  const LoginForm({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.fieldErrors = const {},
    required this.onSubmit,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dr.dupont@steriqore.com');
  final _passwordController = TextEditingController(text: 'secret123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.s24,
        AppDimensions.screenPadding,
        AppDimensions.s32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius2xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s16),

            // Header Title
            Text('Welcome back', style: AppTypography.h1),
            const SizedBox(height: AppDimensions.s4),
            Text(
              'Sign in to access your sterilization traceability logs',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.s24),

            // General Error Banner
            if (widget.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                    const SizedBox(width: AppDimensions.s8),
                    Expanded(
                      child: Text(
                        widget.errorMessage!,
                        style: AppTypography.caption.copyWith(
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

            // Email Input
            AppTextField(
              label: 'Email Address',
              hint: 'doctor@cabinet.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
              validator: Validators.validateEmail,
              errorText: widget.fieldErrors['email']?.first,
            ),
            const SizedBox(height: AppDimensions.s16),

            // Password Input
            AppTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              validator: Validators.validatePassword,
              errorText: widget.fieldErrors['password']?.first,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: AppDimensions.s24),

            // Primary Button "Continue"
            AppButton.primary(
              label: 'Continue',
              isLoading: widget.isLoading,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: AppDimensions.s12),

            // Forgot Password Ghost Button
            AppButton.ghost(
              label: 'Forgot Password?',
              onPressed: () {
                // Info prompt
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please contact your dental practice clinic administrator.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
