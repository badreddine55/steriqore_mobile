// register_screen.dart
//
// Flutter port of the React "RegisterScreen" reference.

import 'package:flutter/material.dart';
import 'steriqore_shared.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _success;

  int _strengthScore(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    if (password.length < 8) return 2;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
    if (hasUpper && hasDigit && hasSymbol) return 4;
    if (password.length >= 8 && (hasUpper || hasDigit)) return 3;
    return 2;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() => _error = null);

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    // --- Replace with your real AuthService call, e.g.:
    // final result = await AuthService.register(name: name, email: email, password: password);
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _success = 'Account created! Welcome, $name!';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (_) => DashboardScreen(user: result.user!)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final score = _strengthScore(password);
    const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    const barColors = [
      Colors.transparent,
      SteriqoreColors.error,
      SteriqoreColors.warning,
      SteriqoreColors.accent,
      SteriqoreColors.success,
    ];

    return AppBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BackButton2(onBack: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: SteriqoreColors.brand.withValues(alpha: 0.11),
                          border: Border.all(color: SteriqoreColors.brand.withValues(alpha: 0.22)),
                        ),
                        child: const SteriqoreLogo(size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text('Create an account',
                          style: steriqoreFont(fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text('Enter your details to get started',
                          style: steriqoreFont(fontSize: 13.5, color: SteriqoreColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                if (_error != null) ErrorBanner(msg: _error!),
                if (_success != null) SuccessBanner(msg: _success!),

                const FieldLabel('Full Name'),
                TextField(
                  controller: _nameController,
                  style: steriqoreFont(fontSize: 14.5, color: Colors.white),
                  cursorColor: SteriqoreColors.accent,
                  decoration: steriqoreFieldDecoration(hint: 'Jane Doe'),
                ),
                const SizedBox(height: 13),

                const FieldLabel('Email Address'),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: steriqoreFont(fontSize: 14.5, color: Colors.white),
                  cursorColor: SteriqoreColors.accent,
                  decoration: steriqoreFieldDecoration(hint: 'email@example.com'),
                ),
                const SizedBox(height: 13),

                const FieldLabel('Password'),
                PasswordInput(
                  controller: _passwordController,
                  hint: 'Password (min. 8 characters)',
                  onChanged: (_) => setState(() {}),
                ),
                if (password.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (i) {
                      final filled = i < score;
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: filled ? barColors[score] : Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 5),
                  Text(labels[score],
                      style: steriqoreFont(fontSize: 11.5, fontWeight: FontWeight.w600, color: barColors[score])),
                ],
                const SizedBox(height: 13),

                const FieldLabel('Confirm Password'),
                PasswordInput(
                  controller: _confirmController,
                  hint: 'Confirm password',
                  onChanged: (_) => setState(() {}),
                ),
                if (confirm.isNotEmpty && password.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    confirm == password ? 'Passwords match ✓' : 'Passwords do not match',
                    style: steriqoreFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: confirm == password ? SteriqoreColors.success : SteriqoreColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                PrimaryButton(label: 'Create Account', isLoading: _isLoading, onPressed: _handleRegister),
                const SizedBox(height: 24),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: steriqoreFont(fontSize: 14, color: SteriqoreColors.textSecondary)),
                      LinkButton(label: 'Log in', onPressed: () => Navigator.of(context).maybePop()),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Terms of Service · Privacy Policy',
                    style: steriqoreFont(fontSize: 11, color: SteriqoreColors.textFaint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}