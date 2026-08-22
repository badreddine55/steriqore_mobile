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

class LoginPage extends StatefulWidget {
  final AuthBloc? authBloc;

  const LoginPage({
    super.key,
    this.authBloc,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'doctor@cabinet.fr');
  final _passwordController = TextEditingController(text: 'secret123');

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmailRealtime(String val) {
    setState(() {
      _emailError = Validators.validateEmail(val);
    });
  }

  void _validatePasswordRealtime(String val) {
    setState(() {
      _passwordError = Validators.validatePassword(val);
    });
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailErr = Validators.validateEmail(email);
    final passErr = Validators.validatePassword(password);

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    if (emailErr == null && passErr == null) {
      final bloc = widget.authBloc ?? context.read<AuthBloc>();
      bloc.add(AuthLoginSubmitted(email: email, password: password));
    }
  }

  void _handleBiometricLogin() {
    final bloc = widget.authBloc ?? context.read<AuthBloc>();
    bloc.add(const AuthBiometricLoginRequested());
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
          if (state is Authenticated || state is AuthRegistered) {
            context.go('/home');
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

          final effectiveEmailError = _emailError ?? backendFieldErrors['email']?.first;
          final effectivePasswordError = _passwordError ?? backendFieldErrors['password']?.first;

          return AuthBackground(
            child: Stack(
              children: [
                // Layer 3: Scrollable content (form)
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.35), // Push form to bottom 65%

                        // Bottom sheet form container
                        AuthFormSheet(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text('Welcome back', style: AppTypography.h1),
                                const SizedBox(height: AppDimensions.s8),
                                Text(
                                  'Sign in to your dental practice',
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

                                // Email Field
                                AppTextField(
                                  label: 'Email',
                                  hint: 'doctor@cabinet.fr',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  errorText: effectiveEmailError,
                                  onChanged: _validateEmailRealtime,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppDimensions.s16),

                                // Password Field
                                AppTextField(
                                  label: 'Password',
                                  hint: '••••••••',
                                  controller: _passwordController,
                                  obscureText: true,
                                  isPassword: true,
                                  prefixIcon: Icons.lock_outline,
                                  errorText: effectivePasswordError,
                                  onChanged: _validatePasswordRealtime,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleLogin(),
                                ),
                                const SizedBox(height: AppDimensions.s12),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AppButton.ghost(
                                    text: 'Forgot Password?',
                                    textColor: AppColors.accent,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please contact your dental practice administrator to reset credentials.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s24),

                                // Sign In Button
                                AppButton.primary(
                                  text: 'Sign In',
                                  label: 'Sign In',
                                  isLoading: isLoading,
                                  onPressed: _handleLogin,
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

                                // Biometric button (Face ID / Touch ID)
                                AppButton.outline(
                                  text: 'Sign in with Biometrics',
                                  icon: Icons.fingerprint,
                                  isLoading: isLoading,
                                  onPressed: _handleBiometricLogin,
                                ),
                                const SizedBox(height: AppDimensions.s24),

                                // Clinical notice footer
                                Center(
                                  child: Text(
                                    'Accounts are provisioned by your Clinic Administrator',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
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

                // Layer 4: Back button (top-left)
                Positioned(
                  top: statusBarHeight + 16,
                  left: 16,
                  child: AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    backgroundColor: const Color(0x26FFFFFF), // glassmorphism
                    iconColor: Colors.white,
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/onboarding');
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
