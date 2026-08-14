// dashboard_screen.dart
//
// Flutter port of the React "DashboardScreen" reference.
//
// Assumes a `user` object with `.name` and `.email` — swap `SteriqoreUser`
// below for your real User model if you already have one.

import 'package:flutter/material.dart';
import 'steriqore_shared.dart';

class SteriqoreUser {
  final String name;
  final String email;
  const SteriqoreUser({required this.name, required this.email});
}

class DashboardScreen extends StatefulWidget {
  final SteriqoreUser user;
  const DashboardScreen({
    super.key,
    this.user = const SteriqoreUser(name: 'Alex Dumas', email: 'test@example.com'),
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoggingOut = false;
  int _activeTab = 0;

  static const _tabs = [
    (icon: Icons.grid_view_rounded, label: 'Home'),
    (icon: Icons.show_chart_rounded, label: 'Activity'),
    (icon: Icons.shield_outlined, label: 'Security'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  String get _initials {
    final parts = widget.user.name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((w) => w.isNotEmpty ? w[0] : '').join();
    return letters.toUpperCase();
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isLoggingOut = false);
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (_) => const LoginScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  const SteriqoreLogo(size: 22),
                  const SizedBox(width: 10),
                  Text('Steriqore',
                      style: steriqoreFont(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                  const Spacer(),
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    showDot: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: Icons.logout_rounded,
                    isLoading: _isLoggingOut,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3B6FD4), Color(0xFF4F8EF7)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: SteriqoreColors.accent.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(_initials,
                              style: steriqoreFont(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello,',
                                  style: steriqoreFont(fontSize: 12, color: SteriqoreColors.textSecondary)),
                              Text(widget.user.name,
                                  style: steriqoreFont(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                            ],
                          ),
                        ),
                        _Pill(text: 'Active', color: SteriqoreColors.success),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Metrics
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.show_chart_rounded,
                            label: 'System Status',
                            value: '99.9%',
                            sub: 'Operational',
                            accent: SteriqoreColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.shield_outlined,
                            label: 'Security Score',
                            value: '98%',
                            sub: '2FA Enabled',
                            accent: SteriqoreColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.devices_rounded,
                            label: 'Active Sessions',
                            value: '2',
                            sub: 'Devices',
                            accent: SteriqoreColors.purple,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.key_rounded,
                            label: 'Passkeys',
                            value: '3',
                            sub: 'Registered',
                            accent: SteriqoreColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Backend connection card
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: SteriqoreColors.accent.withValues(alpha: 0.12),
                                  border: Border.all(color: SteriqoreColors.accent.withValues(alpha: 0.25)),
                                ),
                                child: const Icon(Icons.public_rounded, size: 15, color: SteriqoreColors.accent),
                              ),
                              const SizedBox(width: 9),
                              Text('Backend Connection',
                                  style: steriqoreFont(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                              const Spacer(),
                              _Pill(text: 'LIVE', color: SteriqoreColors.success, small: true),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ConnectionRow(label: 'Endpoint', value: 'api.steriqore.com/v1'),
                          _ConnectionRow(label: 'Auth Type', value: 'Sanctum Bearer Token'),
                          _ConnectionRow(label: 'Token', value: 'sk_live_xH7mKpQ2v...'),
                          _ConnectionRow(label: 'User', value: widget.user.email, isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recent activity
                    Text('RECENT ACTIVITY',
                        style: steriqoreFont(
                            fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: SteriqoreColors.textSecondary)),
                    const SizedBox(height: 10),
                    _Card(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _ActivityRow(
                            icon: Icons.smartphone_rounded,
                            title: 'Login from iPhone 15 Pro',
                            time: 'Today, 10:24 AM',
                            meta: 'Paris, FR',
                            color: SteriqoreColors.success,
                          ),
                          _ActivityRow(
                            icon: Icons.key_rounded,
                            title: "Passkey 'MacBook Pro' Created",
                            time: 'Yesterday, 4:15 PM',
                            meta: 'Touch ID',
                            color: SteriqoreColors.accent,
                          ),
                          _ActivityRow(
                            icon: Icons.shield_outlined,
                            title: '2FA Verification Passed',
                            time: '2 days ago, 9:00 AM',
                            meta: 'Authenticator App',
                            color: SteriqoreColors.purple,
                            isLast: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                child: Text('View all activity →',
                                    style: steriqoreFont(fontSize: 13, fontWeight: FontWeight.w600, color: SteriqoreColors.accent)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    OutlineButton(
                      borderColor: SteriqoreColors.error.withValues(alpha: 0.22),
                      textColor: SteriqoreColors.error,
                      onPressed: _handleLogout,
                      child: _isLoggingOut
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Spinner(color: SteriqoreColors.error), SizedBox(width: 10), Text('Signing out…')],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded, size: 16),
                                const SizedBox(width: 8),
                                Text('Sign Out', style: steriqoreFont(fontSize: 14, fontWeight: FontWeight.w600, color: SteriqoreColors.error)),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom tab bar
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
                color: SteriqoreColors.bg.withValues(alpha: 0.8),
              ),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final active = _activeTab == i;
                  final tab = _tabs[i];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tab.icon, size: 20, color: active ? SteriqoreColors.accent : const Color(0x59FFFFFF)),
                          const SizedBox(height: 4),
                          Text(tab.label,
                              style: steriqoreFont(
                                  fontSize: 10,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                  color: active ? SteriqoreColors.accent : const Color(0x59FFFFFF))),
                          if (active) ...[
                            const SizedBox(height: 4),
                            Container(width: 18, height: 2, decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), color: SteriqoreColors.accent)),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final bool isLoading;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            isLoading
                ? const Spinner()
                : Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.72)),
            if (showDot)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SteriqoreColors.error,
                    border: Border.all(color: SteriqoreColors.bg, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final bool small;
  const _Pill({required this.text, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(small ? 5 : 6),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(text, style: steriqoreFont(fontSize: small ? 10 : 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color accent;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: accent.withValues(alpha: 0.10),
              border: Border.all(color: accent.withValues(alpha: 0.30)),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: 12),
          Text(value, style: steriqoreFont(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
          const SizedBox(height: 4),
          Text(label, style: steriqoreFont(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9))),
          const SizedBox(height: 2),
          Text(sub, style: steriqoreFont(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: SteriqoreColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SteriqoreColors.cardBorder),
      ),
      child: child,
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _ConnectionRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: steriqoreFont(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.42), fontWeight: FontWeight.w500)),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: steriqoreFont(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.82), fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (!isLast) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.06))),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String meta;
  final Color color;
  final bool isLast;

  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.time,
    required this.meta,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: steriqoreFont(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$time · $meta', style: steriqoreFont(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white.withValues(alpha: 0.25)),
        ],
      ),
    );
  }
}