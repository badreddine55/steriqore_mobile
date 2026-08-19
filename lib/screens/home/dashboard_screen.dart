import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../roles/practitioner/practitioner_routes.dart';
import '../../services/auth_service.dart';
import '../../shared/dentistrack_shared.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeTab = 0;

  static const _navTabs = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Home'),
    (icon: Icons.qr_code_scanner_rounded, activeIcon: Icons.qr_code_scanner_rounded, label: 'Scan'),
    (icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Stock'),
    (icon: Icons.sanitizer_outlined, activeIcon: Icons.sanitizer_rounded, label: 'Cycles'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  String get _initials {
    final parts = widget.user.name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((w) => w.isNotEmpty ? w[0] : '').join();
    return letters.isNotEmpty ? letters.toUpperCase() : 'DR';
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 10),
            Text('Sign Out', style: dentistrackFont(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to end your session and sign out of STERIQORE?',
          style: dentistrackFont(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: dentistrackFont(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sign Out', style: dentistrackFont(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();
    if (!mounted) return;
    try {
      context.go('/login');
    } catch (_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Widget _buildHomeTab(BuildContext context, BoxConstraints constraints) {
    final isWide = constraints.maxWidth >= 640;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Greeting & Clinic Identity
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _initials,
                  style: dentistrackFont(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryInverse,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Practice Cabinet #104',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: dentistrackFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ONLINE',
                            style: dentistrackFont(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dentistrackFont(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // High-level KPIs & Compliance Metrics (Adaptive 2-col or 4-col)
        if (isWide)
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.sanitizer_rounded,
                  label: 'Sterilization',
                  value: '100%',
                  sub: 'All cycles validated',
                  accentColor: AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'DLC Alerts',
                  value: '2',
                  sub: '< 30 days remaining',
                  accentColor: AppColors.warning,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Scanned Today',
                  value: '28',
                  sub: 'Traceability lots',
                  accentColor: AppColors.accent,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.security_rounded,
                  label: 'Audit Integrity',
                  value: 'OK',
                  sub: 'Immutable trail',
                  accentColor: AppColors.primary,
                ),
              ),
            ],
          )
        else ...[
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.sanitizer_rounded,
                  label: 'Sterilization',
                  value: '100%',
                  sub: 'All validated',
                  accentColor: AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'DLC Alerts',
                  value: '2',
                  sub: '< 30 days left',
                  accentColor: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Scanned Today',
                  value: '28',
                  sub: 'Lots processed',
                  accentColor: AppColors.accent,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.security_rounded,
                  label: 'Audit Integrity',
                  value: 'OK',
                  sub: 'Immutable trail',
                  accentColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),

        // Live API Server Connection Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_done_rounded, size: 20, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connected Backend API',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dentistrackFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'API v1 ACTIVE',
                      style: dentistrackFont(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Endpoint', value: ApiConstants.baseUrl),
              const _DetailRow(label: 'Auth Protocol', value: 'Sanctum Bearer Token'),
              _DetailRow(label: 'Account Email', value: widget.user.email),
              _DetailRow(label: 'Registered On', value: widget.user.createdAt ?? 'Just now', isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Recent Traceability Activity
        Text(
          'RECENT TRACEABILITY LOGS',
          style: dentistrackFont(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            children: [
              _ActivityItem(
                icon: Icons.sanitizer_rounded,
                title: 'Autoclave Cycle #089 Validated',
                time: '12 min ago',
                subtitle: 'Opérateur: Dr. John · 134°C Conforme',
                color: AppColors.success,
              ),
              _ActivityItem(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Stock Exit · Lot #LOT-2026-89A',
                time: '1 hour ago',
                subtitle: 'Implant Titane 3.5mm · Scan Caméra',
                color: AppColors.accent,
              ),
              _ActivityItem(
                icon: Icons.warning_amber_rounded,
                title: 'DLC Alert · Composite Seringues',
                time: 'Today, 08:30 AM',
                subtitle: 'DLC: 25-08-2026 (< 10 jours)',
                color: AppColors.warning,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScanTab(BuildContext context, BoxConstraints constraints) {
    final scanHeight = (constraints.maxHeight * 0.45).clamp(240.0, 360.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Scan Medical Labels',
          style: dentistrackFont(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),
        Text(
          'Instant DataMatrix, QR Code & Barcode recognition',
          style: dentistrackFont(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Container(
          height: scanHeight,
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOverlay,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Align code within reticle to scan',
                    style: dentistrackFont(fontSize: 13, color: AppColors.textInverse),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DentisTrackPrimaryButton(
          label: 'Launch Camera Scanner',
          icon: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(PractitionerRoutes.scanner);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStockTab(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dental Inventory & Lots',
          style: dentistrackFont(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),
        Text(
          'Catalogue, stock movements, and batch DLCs',
          style: dentistrackFont(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        const _DetailCard(
          title: 'Stock Overview',
          rows: [
            _DetailItem(title: 'Total Active Products', val: '248 references'),
            _DetailItem(title: 'Critical Outages', val: '0 products'),
            _DetailItem(title: 'Batches with DLC < 30 days', val: '2 lots (Action needed)'),
          ],
        ),
        const SizedBox(height: 16),
        const _DetailCard(
          title: 'Quick Category Distribution',
          rows: [
            _DetailItem(title: 'Implants & Prosthetics', val: '94 units in stock'),
            _DetailItem(title: 'Endodontics & Hygiene', val: '112 units in stock'),
            _DetailItem(title: 'Sterilization Pouches', val: '42 packs ready'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCyclesTab(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sterilization Cycles',
          style: dentistrackFont(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        const SizedBox(height: 4),
        Text(
          'Autoclave cycle tracking, controls and conformity reports',
          style: dentistrackFont(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        const _DetailCard(
          title: 'Active Autoclave Devices',
          rows: [
            _DetailItem(title: 'Melag Vacuklav 40B', val: 'Ready · Cycle #090 pending'),
            _DetailItem(title: 'Sterilizer Lisa 500', val: 'Standby · Validated'),
          ],
        ),
        const SizedBox(height: 16),
        const _DetailCard(
          title: 'Daily Compliance Summary',
          rows: [
            _DetailItem(title: 'Helix Test (Daily)', val: 'Passed (08:00 AM)'),
            _DetailItem(title: 'Vacuum Test (Weekly)', val: 'Validated (-0.85 bar)'),
            _DetailItem(title: 'Cycle Temperature', val: '134°C / 18 min (Standard)'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfileTab(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Practice Profile & Security',
          style: dentistrackFont(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _initials,
                      style: dentistrackFont(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: dentistrackFont(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: dentistrackFont(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 10),
              _DetailRow(label: 'Account ID', value: '#${widget.user.id}'),
              const _DetailRow(label: 'Cabinet Status', value: 'Multi-Tenant Verified'),
              const _DetailRow(label: 'Audit Trail', value: 'Immutable Logging Active', isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DentisTrackSecondaryButton(
          label: 'Sign Out Account',
          icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
          onPressed: _handleLogout,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header with max width constraint
            ResponsiveContentContainer(
              maxWidth: Breakpoints.dashboardMaxWidth,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  const DentisTrackLogo(size: 32, showSubtitle: false),
                  const Spacer(),
                  DentisTrackIconButton(
                    icon: Icons.logout_rounded,
                    color: AppColors.error,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),

            // Main Scrollable Area with responsive constraints
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabs = [
                    _buildHomeTab(context, constraints),
                    _buildScanTab(context, constraints),
                    _buildStockTab(context, constraints),
                    _buildCyclesTab(context, constraints),
                    _buildProfileTab(context, constraints),
                  ];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ResponsiveContentContainer(
                      maxWidth: Breakpoints.dashboardMaxWidth,
                      child: tabs[_activeTab],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Bar with responsive container
            Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundDark,
              ),
              child: SafeArea(
                top: false,
                child: ResponsiveContentContainer(
                  maxWidth: 600,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: List.generate(_navTabs.length, (i) {
                      final tab = _navTabs[i];
                      final isActive = _activeTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = i),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive ? tab.activeIcon : tab.icon,
                                size: 22,
                                color: isActive ? Colors.white : Colors.white54,
                              ),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  tab.label,
                                  maxLines: 1,
                                  style: dentistrackFont(
                                    fontSize: 11,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                    color: isActive ? Colors.white : Colors.white54,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color accentColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: dentistrackFont(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: dentistrackFont(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: dentistrackFont(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: dentistrackFont(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: dentistrackFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) const Divider(color: AppColors.borderSubtle, height: 16),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String subtitle;
  final Color color;
  final bool isLast;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: dentistrackFont(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: dentistrackFont(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: dentistrackFont(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailItem> rows;

  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: dentistrackFont(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      r.title,
                      style: dentistrackFont(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Text(
                      r.val,
                      textAlign: TextAlign.right,
                      style: dentistrackFont(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String title;
  final String val;
  const _DetailItem({required this.title, required this.val});
}