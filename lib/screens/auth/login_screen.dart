// login_screen.dart
//
// Flutter port of the React "LoginScreen" reference. Wire `AuthService.login`
// and `DashboardScreen` up to your existing services/screens (signatures
// assumed below match the ones already used in your project).

import 'package:flutter/material.dart';
import 'steriqore_shared.dart';

// Adjust these imports to match your project structure:
// import '../../services/auth_service.dart';
// import '../home/dashboard_screen.dart';
// import 'register_screen.dart';

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

  bool _rememberMe = false;
  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _emailController.text = 'test@example.com';
      _passwordController.text = 'password';
      _error = null;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    // --- Replace with your real AuthService call, e.g.:
    // final result = await AuthService.login(
    //   email: _emailController.text.trim(),
    //   password: _passwordController.text,
    //   deviceName: 'Flutter Mobile App',
    // );
    await Future.delayed(const Duration(milliseconds: 1200));
    final ok = _emailController.text.trim() == 'test@example.com' &&
        _passwordController.text == 'password';

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      setState(() => _success = 'Welcome back, Alex!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => DashboardScreen(user: result.user!)),
      // );
    } else {
      setState(() => _error = 'These credentials do not match our records.');
    }
  }

  void _handleBiometric() {
    setState(() => _success = 'Biometric authentication initiated…');
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _success = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo + heading
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: SteriqoreColors.brand.withValues(alpha: 0.12),
                            border: Border.all(color: SteriqoreColors.brand.withValues(alpha: 0.24)),
                            boxShadow: [
                              BoxShadow(
                                color: SteriqoreColors.brand.withValues(alpha: 0.16),
                                blurRadius: 28,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const SteriqoreLogo(size: 30),
                        ),
                        const SizedBox(height: 18),
                        Text('Welcome back',
                            style: steriqoreFont(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
                        const SizedBox(height: 7),
                        Text('Sign in to your Steriqore account',
                            style: steriqoreFont(fontSize: 14, color: SteriqoreColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Demo chip
                  Center(
                    child: GestureDetector(
                      onTap: _fillDemo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                        decoration: BoxDecoration(
                          color: SteriqoreColors.brand.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: SteriqoreColors.brand.withValues(alpha: 0.26)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFFF6B55)),
                            const SizedBox(width: 6),
                            Text('Auto-fill test account',
                                style: steriqoreFont(
                                    fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFFF6B55))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  if (_error != null) ErrorBanner(msg: _error!),
                  if (_success != null) SuccessBanner(msg: _success!),

                  const FieldLabel('Email Address'),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    style: steriqoreFont(fontSize: 14.5, color: Colors.white),
                    cursorColor: SteriqoreColors.accent,
                    decoration: steriqoreFieldDecoration(hint: 'user@example.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your email';
                      if (!v.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  const FieldLabel('Password'),
                  PasswordInput(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RememberCheckbox(
                        checked: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v),
                        label: 'Remember device',
                      ),
                      LinkButton(label: 'Forgot password?', onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 22),

                  PrimaryButton(label: 'Sign in', isLoading: _isLoading, onPressed: _handleLogin),

                  const OrDivider(),

                  OutlineButton(
                    onPressed: _handleBiometric,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text('Sign in with Biometrics', style: steriqoreFont(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: steriqoreFont(fontSize: 14, color: SteriqoreColors.textSecondary)),
                        LinkButton(
                          label: 'Sign up',
                          onPressed: () {
                            // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                        ),
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
      ),
    );
  }
}