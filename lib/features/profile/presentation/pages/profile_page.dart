import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../../shared/widgets/role_based_bottom_nav.dart';
import '../../../admin/presentation/widgets/role_badge.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AdminColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AdminColors.borderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AdminColors.error, size: 20),
            SizedBox(width: 10),
            Text('Sign Out', style: AdminTypography.h3),
          ],
        ),
        content: Text(
          'Are you sure you want to end your active session in STERIQORE?',
          style: AdminTypography.body.copyWith(color: AdminColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: AdminTypography.button.copyWith(color: AdminColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    final user = context.select((AuthBloc b) => b.state.user) ??
        const User(
          id: 1,
          name: 'Dr. Practitioner',
          email: 'doctor@cabinet.fr',
          role: 'practitioner',
          cabinetName: 'Cabinet Central',
          cabinetRoom: 'Fauteuil 1',
        );

    final permissions = user.permissions.isNotEmpty
        ? user.permissions
        : (user.isAdmin
            ? ['all', 'users_manage', 'audit_read', 'settings_write', 'stock_write', 'cycles_write', 'scan_write']
            : (user.isAssistant
                ? ['stock_read', 'stock_write', 'cycles_write', 'scan_write', 'usage_write']
                : ['scan_read', 'usage_write', 'history_read', 'patients_read']));

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AdminColors.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('My Profile & Rights', style: AdminTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AdminColors.error, size: 20),
            tooltip: 'Sign Out',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentRoute: '/profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AdminColors.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AdminColors.primaryInverse,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: AdminTypography.h3),
                          const SizedBox(height: 2),
                          Text(user.email, style: AdminTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
                          const SizedBox(height: 8),
                          RoleBadge(role: user.role),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Practice & Clinic Details
              Text('CLINICAL ASSIGNMENT', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _ProfileRow(label: 'Practice Name', value: user.cabinetName ?? 'Cabinet Central Paris'),
                    const Divider(height: 20, color: AdminColors.borderSubtle),
                    _ProfileRow(label: 'Assigned Chair / Bay', value: user.cabinetRoom ?? 'Fauteuil 1 - Chirurgie'),
                    const Divider(height: 20, color: AdminColors.borderSubtle),
                    _ProfileRow(label: 'Cabinet Code', value: user.cabinetId ?? 'CAB-2026-001', isMono: true),
                    const Divider(height: 20, color: AdminColors.borderSubtle),
                    _ProfileRow(label: 'User ID Ref', value: user.codeId ?? 'USR-2026-${user.id.toString().padLeft(3, '0')}', isMono: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Permissions & Access Gating
              Text('ACTIVE ROLE PERMISSIONS', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissions granted via server authority (GET /auth/me):',
                      style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: permissions.map((p) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AdminColors.borderSubtle),
                          ),
                          child: Text(
                            p,
                            style: AdminTypography.monospace.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // End session CTA
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.error,
                    side: const BorderSide(color: AdminColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign Out from Device', style: AdminTypography.button),
                  onPressed: () => _showLogoutDialog(context),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;

  const _ProfileRow({
    required this.label,
    required this.value,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AdminTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
        Text(
          value,
          style: (isMono ? AdminTypography.monospace : AdminTypography.bodySmall).copyWith(
            fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
