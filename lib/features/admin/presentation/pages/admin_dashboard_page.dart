import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_audit_bloc.dart';
import '../bloc/admin_audit_event.dart';
import '../bloc/admin_audit_state.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/audit_timeline_tile.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminUsersBloc>().add(const AdminLoadUsersRequested());
        context.read<AdminAuditBloc>().add(const AdminLoadAuditRequested());
      }
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AdminColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AdminColors.borderSubtle),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AdminColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Sign Out', style: AdminTypography.h3),
          ],
        ),
        content: Text(
          'End administrator supervision session and completely sign out of STERIQORE?',
          style: AdminTypography.bodySmall.copyWith(color: AdminColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: AdminTypography.button.copyWith(
                color: AdminColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: AdminColors.primaryInverse,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/login');
            },
            child: const Text('Sign Out', style: AdminTypography.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUser = (authState is Authenticated) ? authState.user : null;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AdminColors.borderSubtle, height: 1),
        ),
        titleSpacing: 20,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AdminColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.shield_outlined, color: AdminColors.primaryInverse, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          currentUser?.name ?? 'Practice Administrator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AdminTypography.h4,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AdminColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: AdminColors.primaryInverse,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${currentUser?.cabinetName ?? 'Cabinet Central'} · Clinical Supervision',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20, color: AdminColors.secondary),
              tooltip: 'Sign Out',
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AdminColors.accent,
          onRefresh: () async {
            context.read<AdminUsersBloc>().add(const AdminRefreshUsersRequested());
            context.read<AdminAuditBloc>().add(const AdminRefreshAuditRequested());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Admin Banner Hero
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AdminColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_outline_rounded, size: 12, color: AdminColors.primaryInverse),
                                    const SizedBox(width: 4),
                                    Text(
                                      'TENANT AUDIT ACTIVE',
                                      style: AdminTypography.caption.copyWith(
                                        color: AdminColors.primaryInverse,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.verified_outlined, color: AdminColors.accentLight, size: 18),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Cabinet Administration',
                            style: AdminTypography.h2.copyWith(color: AdminColors.primaryInverse),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage practitioner rights, monitor compliance logs, and supervise clinical serialization in real time.',
                            style: AdminTypography.bodySmall.copyWith(
                              color: AdminColors.primaryInverse.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // KPI Stats Cards (2x2 Grid)
                    BlocBuilder<AdminUsersBloc, AdminUsersState>(
                      builder: (context, userState) {
                        return BlocBuilder<AdminAuditBloc, AdminAuditState>(
                          builder: (context, auditState) {
                            return GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.3,
                              children: [
                                AdminStatCard(
                                  icon: Icons.people_alt_outlined,
                                  label: 'Staff Users',
                                  value: '${userState.totalCount}',
                                  subtitle: '${userState.activeCount} active in cabinet',
                                  accentColor: AdminColors.primary,
                                  onTap: () => context.push('/admin/users'),
                                ),
                                AdminStatCard(
                                  icon: Icons.medical_services_outlined,
                                  label: 'Practitioners',
                                  value: '${userState.practitionerCount}',
                                  subtitle: 'Authorized to record',
                                  accentColor: AdminColors.success,
                                  onTap: () => context.push('/admin/users'),
                                ),
                                AdminStatCard(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Stock Managers',
                                  value: '${userState.assistantCount}',
                                  subtitle: 'Sterilization & lots',
                                  accentColor: AdminColors.accent,
                                  onTap: () => context.push('/admin/users'),
                                ),
                                AdminStatCard(
                                  icon: Icons.history_edu_outlined,
                                  label: 'Audit Records',
                                  value: '${auditState.entries.length}',
                                  subtitle: 'Live compliance trail',
                                  accentColor: AdminColors.warning,
                                  onTap: () => context.push('/admin/audit'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Management Modules
                    Text('MANAGEMENT MODULES', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),

                    _ModuleCard(
                      icon: Icons.person_add_outlined,
                      title: 'User Management',
                      subtitle: 'Add practitioners, assign cabinet stations, and configure access',
                      badgeText: 'USERS',
                      badgeColor: AdminColors.primary,
                      onTap: () => context.push('/admin/users'),
                    ),
                    const SizedBox(height: 10),

                    _ModuleCard(
                      icon: Icons.history_rounded,
                      title: 'Audit & Compliance Trail',
                      subtitle: 'Inspect immutable records: patient usage, autoclave validations, IPs',
                      badgeText: 'AUDIT',
                      badgeColor: AdminColors.warning,
                      onTap: () => context.push('/admin/audit'),
                    ),
                    const SizedBox(height: 10),

                    _ModuleCard(
                      icon: Icons.tune_rounded,
                      title: 'Practice & Safety Settings',
                      subtitle: 'Configure DLC thresholds, autoclave units, biometric requirements',
                      badgeText: 'CONFIG',
                      badgeColor: AdminColors.accent,
                      onTap: () => context.push('/admin/settings'),
                    ),
                    const SizedBox(height: 28),

                    // Recent Audit Logs preview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LATEST AUDIT EVENTS', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        GestureDetector(
                          onTap: () => context.push('/admin/audit'),
                          child: Text(
                            'View All',
                            style: AdminTypography.caption.copyWith(
                              color: AdminColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    BlocBuilder<AdminAuditBloc, AdminAuditState>(
                      builder: (context, state) {
                        final previewEntries = state.entries.take(3).toList();
                        if (previewEntries.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AdminColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AdminColors.borderSubtle),
                            ),
                            child: Center(
                              child: Text(
                                'No audit events recorded yet.',
                                style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: previewEntries.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = previewEntries[index];
                            return AuditTimelineTile(
                              entry: entry,
                              onTap: () => context.push('/admin/audit'),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12), // 12px radius
        border: Border.all(color: AdminColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: badgeColor, size: 20),
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
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AdminTypography.h4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText,
                              style: AdminTypography.caption.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AdminTypography.caption.copyWith(
                          color: AdminColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AdminColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
