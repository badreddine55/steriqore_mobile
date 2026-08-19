import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../shared/dentistrack_shared.dart';
import '../home/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String _selectedRole = 'Practitioner';
  bool _agreedToCompliance = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final List<String> _roles = [
    'Practitioner',
    'Stock Assistant',
    'Administrator',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    if (password.length < 8) return 2;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(password);

    if (password.length >= 8 && hasUpper && hasDigit && hasSpecial) return 4;
    if (password.length >= 8 && (hasUpper || hasDigit)) return 3;
    return 2;
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full practitioner or staff name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid clinic email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'The confirmation password does not match.');
      return;
    }
    if (!_agreedToCompliance) {
      setState(() => _errorMessage = 'Please accept cabinet data compliance agreement.');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      name: name,
      email: email,
      password: password,
      deviceName: 'DentisTrack Mobile Client',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success && result.user != null) {
      setState(() => _successMessage = 'Account created successfully! Welcome, $name.');
      await Future.delayed(const Duration(milliseconds: 500));
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

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final strengthScore = _calculateStrength(password);
    final isSmall = Responsive.isSmallMobile(context);
    final cardPadding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 26);
    final outerPadding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

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
                      // Top Row: Back Button & Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DentisTrackIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          DentisTrackLogo(
                            size: isSmall ? 30 : 34,
                            showSubtitle: false,
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 14 : 18),

                      // Screen Titles
                      Text(
                        'Join your cabinet',
                        style: dentistrackFont(
                          fontSize: isSmall ? 22 : 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create your profile for dental inventory & sterilization tracking',
                        style: dentistrackFont(
                          fontSize: isSmall ? 13 : 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: isSmall ? 14 : 18),

                      // Status feedback
                      if (_errorMessage != null)
                        DentisTrackStatusBanner.error(message: _errorMessage!),
                      if (_successMessage != null)
                        DentisTrackStatusBanner.success(message: _successMessage!),

                      // Role Selector Chips
                      Text(
                        'Primary practice role',
                        style: dentistrackFont(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _roles.map((role) {
                          final isSelected = _selectedRole == role;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRole = role),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                margin: EdgeInsets.only(right: role == _roles.last ? 0 : 6),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.backgroundDefault,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    role,
                                    textAlign: TextAlign.center,
                                    style: dentistrackFont(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryInverse : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Full Name Field
                      DentisTrackTextField(
                        label: 'Full Name',
                        hint: 'Dr. Jane Doe',
                        controller: _nameController,
                        focusNode: _nameFocus,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),

                      // Email Address Field
                      DentisTrackTextField(
                        label: 'Practice Email Address',
                        hint: 'jane@dentalpractice.com',
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                      const SizedBox(height: 14),

                      // Password Field with live strength meter
                      DentisTrackPasswordField(
                        label: 'Create Password',
                        hint: 'Minimum 8 characters',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        onChanged: (_) => setState(() {}),
                      ),
                      DentisTrackPasswordStrengthBar(score: strengthScore),
                      const SizedBox(height: 14),

                      // Confirm Password Field
                      DentisTrackPasswordField(
                        label: 'Confirm Password',
                        hint: 'Repeat your password',
                        controller: _confirmController,
                        focusNode: _confirmFocus,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (confirm.isNotEmpty && password.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(
                                confirm == password ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 14,
                                color: confirm == password ? AppColors.success : AppColors.error,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  confirm == password ? 'Passwords match' : 'Passwords do not match',
                                  style: dentistrackFont(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: confirm == password ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Multi-tenant isolation & data agreement
                      DentisTrackCheckbox(
                        value: _agreedToCompliance,
                        onChanged: (val) => setState(() => _agreedToCompliance = val),
                        label: 'I accept practice audit logging & tenant isolation',
                        isExpanded: true,
                      ),
                      SizedBox(height: isSmall ? 18 : 22),

                      // Primary CTA Button
                      DentisTrackPrimaryButton(
                        label: 'Create Account',
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 18),

                      // Back to login link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Already registered? ',
                              style: dentistrackFont(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            DentisTrackLinkButton(
                              label: 'Sign In',
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ],
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