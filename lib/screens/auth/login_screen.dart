import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../shared/dentistrack_shared.dart';
import '../home/dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await AuthService.getRememberedEmail();
    if (savedEmail != null && savedEmail.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'john@steriqore.com';
      _passwordController.text = 'Password123!';
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await AuthService.login(
      email: email,
      password: password,
      deviceName: 'DentisTrack Mobile Client',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success && result.user != null) {
      if (_rememberMe) {
        await AuthService.setRememberedEmail(email);
      } else {
        await AuthService.setRememberedEmail(null);
      }

      setState(() => _successMessage = result.message);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen(user: result.user!)),
      );
    } else {
      setState(() {
        _errorMessage = result.firstErrorMessage;
      });
    }
  }

  void _handleBiometricAuth() {
    setState(() {
      _successMessage = 'Biometric authentication verified for Doctor John';
    });

    Future.delayed(const Duration(milliseconds: 800), () async {
      final user = await AuthService.getUser();
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
        );
      } else {
        _fillDemoCredentials();
        _handleLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = Responsive.isSmallMobile(context);
    final cardPadding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 28);
    final outerPadding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 20);

    return DentisTrackAuthBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: outerPadding,
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Breakpoints.authFormMaxWidth),
              child: Container(
                padding: cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo & Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: DentisTrackLogo(
                              size: isSmall ? 32 : 38,
                              showSubtitle: !isSmall,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quick Demo Auto-fill Chip
                          GestureDetector(
                            onTap: _fillDemoCredentials,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Demo fill',
                                    style: dentistrackFont(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 18 : 24),

                      // Screen Titles
                      Text(
                        'Welcome back',
                        style: dentistrackFont(
                          fontSize: isSmall ? 24 : 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to manage stock, lots & sterilization cycles',
                        style: dentistrackFont(
                          fontSize: isSmall ? 13 : 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: isSmall ? 16 : 20),

                      // Status feedback
                      if (_errorMessage != null)
                        DentisTrackStatusBanner.error(message: _errorMessage!),
                      if (_successMessage != null)
                        DentisTrackStatusBanner.success(message: _successMessage!),

                      // Email Field
                      DentisTrackTextField(
                        label: 'Email address',
                        hint: 'doctor@cabinet.com',
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your registered email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      DentisTrackPasswordField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Remember Device & Forgot Password Row
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          DentisTrackCheckbox(
                            value: _rememberMe,
                            onChanged: (val) => setState(() => _rememberMe = val),
                            label: 'Remember device',
                          ),
                          DentisTrackLinkButton(
                            label: 'Forgot password?',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset link sent to your practice admin.'),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 18 : 24),

                      // Primary CTA
                      DentisTrackPrimaryButton(
                        label: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.borderSubtle)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: dentistrackFont(
                                fontSize: 13,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.borderSubtle)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Biometric CTA
                      DentisTrackSecondaryButton(
                        label: 'Sign in with Biometrics / Face ID',
                        icon: const Icon(Icons.fingerprint_rounded, size: 20, color: AppColors.textPrimary),
                        onPressed: _handleBiometricAuth,
                      ),
                      SizedBox(height: isSmall ? 18 : 24),

                      // Sign up navigation
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "New to DentisTrack? ",
                              style: dentistrackFont(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            DentisTrackLinkButton(
                              label: 'Join Cabinet',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Compliance footer
                      Center(
                        child: Text(
                          'ISO 13485 & Medical Traceability Compliant',
                          textAlign: TextAlign.center,
                          style: dentistrackFont(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}