import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoggingOut = false;
  String? _tokenPreview;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await AuthService.getToken();
    if (mounted && token != null) {
      setState(() {
        _tokenPreview = token.length > 20 ? '${token.substring(0, 16)}...' : token;
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    await AuthService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161615) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDark ? const Color(0xFFEDEDEC) : const Color(0xFF18181B);
    final textMuted = isDark ? const Color(0xFFA1A09A) : const Color(0xFF706F6C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const AppLogo(size: 32),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              color: isDark ? const Color(0xFFEDEDEC) : const Color(0xFF18181B),
            ),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Greeting Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                      child: Text(
                        widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.email,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // API Connection Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.api_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Backend Connection',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Endpoint', ApiConstants.baseUrl, textPrimary, textMuted),
                    const Divider(height: 20),
                    _buildInfoRow('Auth Type', 'Sanctum Bearer Token', textPrimary, textMuted),
                    const Divider(height: 20),
                    _buildInfoRow('Token', _tokenPreview ?? 'Loading...', textPrimary, textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Logout Action
              CustomButton(
                text: 'Sign Out',
                isOutlined: true,
                isLoading: _isLoggingOut,
                icon: const Icon(Icons.logout, size: 18),
                onPressed: _handleLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color primary, Color muted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.instrumentSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}
