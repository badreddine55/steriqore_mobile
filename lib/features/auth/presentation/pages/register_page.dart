import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_form_sheet.dart';

class RegisterPage extends StatefulWidget {
  final AuthBloc? authBloc;

  const RegisterPage({
    super.key,
    this.authBloc,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cabinetCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _cabinetCodeError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cabinetCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateCabinetCode(String? value) {
    if (value == null || value.trim().length < 4) {
      return 'Cabinet code must be at least 4 characters';
    }
    return null;
  }

  String? _validatePasswordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasUppercase || !hasDigit) {
      return 'Must include at least 1 uppercase letter and 1 number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final cabinetCode = _cabinetCodeController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final nameErr = _validateName(name);
    final emailErr = Validators.validateEmail(email);
    final cabinetErr = _validateCabinetCode(cabinetCode);
    final passErr = _validatePasswordStrength(password);
    final confirmErr = _validateConfirmPassword(confirmPassword);

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _cabinetCodeError = cabinetErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
    });

    if (nameErr == null &&
        emailErr == null &&
        cabinetErr == null &&
        passErr == null &&
        confirmErr == null) {
      final bloc = widget.authBloc ?? context.read<AuthBloc>();
      bloc.add(AuthRegisterSubmitted(
        name: name,
        email: email,
        phone: phone.isNotEmpty ? phone : null,
        cabinetCode: cabinetCode,
        password: password,
        confirmPassword: confirmPassword,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.user.isAdmin) {
              context.go('/admin/dashboard');
            } else {
              context.go('/home');
            }
          } else if (state is AuthRegistered) {
            if (state.user.isAdmin) {
              context.go('/admin/dashboard');
            } else {
              context.go('/home');
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          String? generalError;
          Map<String, List<String>> backendFieldErrors = const {};

          if (state is AuthFailureState) {
            generalError = state.message;
            backendFieldErrors = state.errors;
          }

          final effectiveNameError = _nameError ?? backendFieldErrors['name']?.first;
          final effectiveEmailError = _emailError ?? backendFieldErrors['email']?.first;
          final effectiveCabinetError = _cabinetCodeError ??
              backendFieldErrors['cabinet_code']?.first ??
              backendFieldErrors['practice_code']?.first;
          final effectivePassError = _passwordError ?? backendFieldErrors['password']?.first;
          final effectiveConfirmError = _confirmPasswordError ?? backendFieldErrors['password_confirmation']?.first;

          return AuthBackground(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.20), // Push form into bottom area

                        // Bottom sheet form container
                        AuthFormSheet(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text('Create Account', style: AppTypography.h1),
                                const SizedBox(height: AppDimensions.s8),
                                Text(
                                  'Join your dental practice team',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s32),

                                // General error message banner if any
                                if (generalError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorBg,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: AppColors.error.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          size: 18,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(width: AppDimensions.s8),
                                        Expanded(
                                          child: Text(
                                            generalError,
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

                                // 1. Full Name
                                AppTextField(
                                  label: 'Full Name',
                                  hint: 'Dr. Sarah Dupont',
                                  controller: _nameController,
                                  prefixIcon: Icons.person_outline_rounded,
                                  errorText: effectiveNameError,
                                  onChanged: (val) {
                                    setState(() => _nameError = _validateName(val));
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppDimensions.s16),

                                // 2. Email
                                AppTextField(
                                  label: 'Email',
                                  hint: 'doctor@cabinet.fr',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  errorText: effectiveEmailError,
                                  onChanged: (val) {
                                    setState(() => _emailError = Validators.validateEmail(val));
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppDimensions.s16),

                                // 3. Phone (optional)
                                AppTextField(
                                  label: 'Phone (Optional)',
                                  hint: '+33 6 12 34 56 78',
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  prefixIcon: Icons.phone_outlined,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppDimensions.s16),

                                // 4. Cabinet Code
                                AppTextField(
                                  label: 'Cabinet Code',
                                  hint: 'Your practice code (e.g. CAB-PARIS-01)',
                                  controller: _cabinetCodeController,
                                  prefixIcon: Icons.business_outlined,
                                  errorText: effectiveCabinetError,
                                  onChanged: (val) {
                                    setState(() => _cabinetCodeError = _validateCabinetCode(val));
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppDimensions.s16),

                                // 5. Password
                                AppTextField(
                                  label: 'Password',
                                  hint: '••••••••',
                                  controller: _passwordController,
                                  obscureText: true,
                                  isPassword: true,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  errorText: effectivePassError,
                                  onChanged: (val) {
                                    setState(() => _passwordError = _validatePasswordStrength(val));
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppDimensions.s16),

                                // 6. Confirm Password
                                AppTextField(
                                  label: 'Confirm Password',
                                  hint: '••••••••',
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  isPassword: true,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  errorText: effectiveConfirmError,
                                  onChanged: (val) {
                                    setState(() => _confirmPasswordError = _validateConfirmPassword(val));
                                  },
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleSubmit(),
                                ),
                                const SizedBox(height: AppDimensions.s24),

                                // Primary Button: "Create Account"
                                AppButton.primary(
                                  text: 'Create Account',
                                  label: 'Create Account',
                                  isLoading: isLoading,
                                  onPressed: _handleSubmit,
                                ),
                                const SizedBox(height: AppDimensions.s24),

                                // Divider with "or"
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(color: AppColors.borderSubtle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'or',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(color: AppColors.borderSubtle),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.s24),

                                // Outline Button: "Register with Invitation Link"
                                AppButton.outline(
                                  text: 'Register with Invitation Link',
                                  icon: Icons.link_rounded,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Paste your invitation link or scan clinic invite QR code.'),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: AppDimensions.s24),

                                // Bottom link: "Already have an account? Sign In"
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: Text(
                                        'Sign In',
                                        style: AppTypography.body.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.s24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Back button (top-left)
                Positioned(
                  top: statusBarHeight + 16,
                  left: 16,
                  child: AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    backgroundColor: const Color(0x26FFFFFF),
                    iconColor: Colors.white,
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
