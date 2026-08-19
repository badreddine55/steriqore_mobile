import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../shared/steriqore_shared.dart';
import '../../../../screens/auth/login_screen.dart';
import '../../models/usage_model.dart';
import '../../offline/sync_service.dart';
import '../../practitioner_routes.dart';
import '../../repositories/usage_repository.dart';
import '../../widgets/usage_history_tile.dart';

class PractitionerDashboardScreen extends StatefulWidget {
  final UserModel user;

  const PractitionerDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<PractitionerDashboardScreen> createState() => _PractitionerDashboardScreenState();
}

class _PractitionerDashboardScreenState extends State<PractitionerDashboardScreen> {
  final SyncService _syncService = SyncService();
  final UsageRepository _usageRepo = UsageRepository();

  List<UsageModel> _recentUsages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final usages = await _usageRepo.getUsageHistory();
      if (mounted) {
        setState(() {
          _recentUsages = usages.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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
            Text('Sign Out', style: steriqoreFont(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to end your session and sign out of STERIQORE?',
          style: steriqoreFont(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: steriqoreFont(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sign Out', style: steriqoreFont(fontWeight: FontWeight.w700, color: Colors.white)),
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.keyboard_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'Manual Code Entry',
              style: steriqoreFont(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the package barcode or DataMatrix string for unreadable labels:',
              style: steriqoreFont(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: steriqoreFont(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'e.g. LOT-2026-89A-001',
                prefixIcon: Icon(Icons.qr_code_2_rounded, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: steriqoreFont(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed(
                  PractitionerRoutes.labelDetail,
                  arguments: {'code': code},
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Lookup Label', style: steriqoreFont(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            ResponsiveContentContainer(
              maxWidth: Breakpoints.dashboardMaxWidth,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  const DentisTrackLogo(size: 34, showSubtitle: false),
                  const Spacer(),
                  // Outbox Sync Status Badge Button
                  ValueListenableBuilder<int>(
                    valueListenable: _syncService.pendingCount,
                    builder: (context, pending, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _syncService.isSyncing,
                        builder: (context, syncing, _) {
                          return GestureDetector(
                            onTap: () async {
                              final count = await _syncService.syncNow();
                              if (context.mounted && count > 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Synchronized $count usage records.')),
                                );
                                _loadDashboardData();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: pending > 0
                                    ? AppColors.warning.withValues(alpha: 0.14)
                                    : AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: pending > 0
                                      ? AppColors.warning.withValues(alpha: 0.35)
                                      : AppColors.success.withValues(alpha: 0.30),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (syncing)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    Icon(
                                      pending > 0 ? Icons.cloud_queue_rounded : Icons.cloud_done_rounded,
                                      size: 16,
                                      color: pending > 0 ? AppColors.warning : AppColors.success,
                                    ),
                                  const SizedBox(width: 6),
                                  Text(
                                    pending > 0 ? '$pending Pending Sync' : 'Synced',
                                    style: steriqoreFont(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: pending > 0 ? AppColors.warning : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Logout Button
                  DentisTrackIconButton(
                    icon: Icons.logout_rounded,
                    color: AppColors.error,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _syncService.syncNow();
                  await _loadDashboardData();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ResponsiveContentContainer(
                    maxWidth: Breakpoints.dashboardMaxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Practitioner Welcome Profile Card
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
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  widget.user.name.isNotEmpty
                                      ? widget.user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                                      : 'DR',
                                  style: steriqoreFont(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'PRACTITIONER ROLE',
                                            style: steriqoreFont(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.4,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Cabinet #104',
                                          style: steriqoreFont(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.user.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: steriqoreFont(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Main Action Hero: Scan Instrument Package
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(PractitionerRoutes.scanner);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF18181B), Color(0xFF09090B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(alpha: 0.45),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Scan Instrument Package',
                                        style: steriqoreFont(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Verify sterilization DLC & record patient usage',
                                        style: steriqoreFont(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Secondary Quick Actions Grid
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.keyboard_outlined,
                                title: 'Manual Entry',
                                subtitle: 'Fallback code input',
                                onTap: _showManualEntryDialog,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.history_rounded,
                                title: 'Usage History',
                                subtitle: 'Filter by patient',
                                onTap: () {
                                  Navigator.of(context).pushNamed(PractitionerRoutes.usageHistory);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Active Safety & Compliance Alerts
                        Text(
                          'PRACTICE TRACEABILITY ALERTS',
                          style: steriqoreFont(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 22, color: AppColors.warning),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '2 instrument packages near DLC (< 30 days). Ensure first-in-first-out protocol.',
                                  style: steriqoreFont(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Recent Traceability Timeline
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RECENT PATIENT USAGE LOGS',
                              style: steriqoreFont(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(PractitionerRoutes.usageHistory);
                              },
                              child: Text(
                                'View All',
                                style: steriqoreFont(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (_isLoading)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ))
                        else if (_recentUsages.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundElevated,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'No recent usage records yet. Start by scanning a package!',
                              textAlign: TextAlign.center,
                              style: steriqoreFont(fontSize: 13.5, color: AppColors.textSecondary),
                            ),
                          )
                        else
                          ..._recentUsages.map(
                            (u) => UsageHistoryTile(
                              usage: u,
                              onRetrySync: () async {
                                await _syncService.syncNow();
                                _loadDashboardData();
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: steriqoreFont(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: steriqoreFont(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
