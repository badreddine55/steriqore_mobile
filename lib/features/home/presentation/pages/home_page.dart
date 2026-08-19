import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/alert_summary_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_scans_list.dart';
import '../widgets/stats_card_grid.dart';

import '../../../../core/di/injection.dart';

class HomePage extends StatefulWidget {
  final HomeBloc? homeBloc;
  final AuthBloc? authBloc;

  const HomePage({super.key, this.homeBloc, this.authBloc});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = widget.homeBloc ?? context.read<HomeBloc>();
        bloc.add(const HomeLoadRequested());
      }
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.s8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppDimensions.s12),
            Text('Sign Out', style: AppTypography.h3),
          ],
        ),
        content: Text(
          'Are you sure you want to end your session and sign out of STERIQORE?',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              try {
                final authBloc = widget.authBloc ?? context.read<AuthBloc>();
                authBloc.add(const AuthLogoutRequested());
              } catch (_) {}
              try {
                context.go('/login');
              } catch (_) {}
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showManualEntrySheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s24),
          decoration: const BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radius2xl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enter Code Manually', style: AppTypography.h3),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s8),
              Text(
                'Enter the alphanumeric code printed on the sterilization pouch:',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppDimensions.s16),
              TextField(
                controller: controller,
                autofocus: true,
                style: AppTypography.data,
                decoration: const InputDecoration(
                  hintText: 'e.g. LBL-2026-007834',
                  prefixIcon: Icon(Icons.qr_code_2_rounded, size: 20),
                ),
              ),
              const SizedBox(height: AppDimensions.s20),
              ElevatedButton(
                onPressed: () {
                  final code = controller.text.trim();
                  if (code.isNotEmpty) {
                    Navigator.of(sheetCtx).pop();
                    context.push('/label/$code');
                  }
                },
                child: const Text('Search Label'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthState authState = const AuthInitial();
    try {
      authState = widget.authBloc?.state ?? context.watch<AuthBloc>().state;
    } catch (_) {}
    User? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    final body = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: AppDimensions.screenPadding,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                currentUser != null && currentUser.name.isNotEmpty
                    ? currentUser.name[0].toUpperCase()
                    : 'P',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${currentUser?.name ?? 'Practitioner'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.h4,
                  ),
                  Text(
                    '${currentUser?.cabinetName ?? 'Dental Practice'} · ${currentUser?.cabinetRoom ?? 'Cabinet #1'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: 'Sign Out',
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Quick Scan', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => context.push('/scanner'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeRefreshRequested());
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final stats = (state is HomeLoaded)
                  ? state.stats
                  : const DashboardStats(
                      todayScansCount: 8,
                      pendingSyncCount: 3,
                      activeAlertsCount: 1,
                      lastCycleTimestamp: 'N/A',
                      activeAlertMessages: [],
                    );

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Primary Hero Quick Action: Scan Package
                        QuickActionButton(
                          isPrimary: true,
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'Scan Instrument Package',
                          subtitle: 'Verify sterilization & record usage',
                          onTap: () => context.push('/scanner'),
                        ),
                        const SizedBox(height: AppDimensions.s20),

                        // Stats Card Grid (2x2)
                        StatsCardGrid(stats: stats),
                        const SizedBox(height: AppDimensions.s20),

                        // Secondary Quick Action Grid
                        Row(
                          children: [
                            Expanded(
                              child: QuickActionButton(
                                icon: Icons.keyboard_outlined,
                                title: 'Manual Code',
                                subtitle: 'Type package code',
                                onTap: _showManualEntrySheet,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s16),
                            Expanded(
                              child: QuickActionButton(
                                icon: Icons.history_rounded,
                                title: 'Usage History',
                                subtitle: 'View own scans',
                                onTap: () => context.push('/history'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s24),

                        // Compliance Alerts Card
                        Text('COMPLIANCE & ALERTS', style: AppTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppDimensions.s8),
                        AlertSummaryCard(alerts: stats.activeAlertMessages),
                        const SizedBox(height: AppDimensions.s24),

                        // Recent Scans Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('RECENT TRACEABILITY LOGS', style: AppTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                            GestureDetector(
                              onTap: () => context.push('/history'),
                              child: Text(
                                'View All',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s8),
                        RecentScansList(
                          items: const [
                            RecentScanItem(
                              productName: 'Implant Titane 3.5mm Grade V',
                              lotNumber: 'LOT-2026-89A',
                              patientName: 'Marie Dubois',
                              time: '12m ago',
                            ),
                            RecentScanItem(
                              productName: 'Curette Gracey 1/2 Micro',
                              lotNumber: 'LOT-2026-102',
                              patientName: 'Jean Moreau',
                              time: '1h ago',
                            ),
                            RecentScanItem(
                              productName: 'Miroir Dentaire Front Surface',
                              lotNumber: 'LOT-2026-44B',
                              patientName: 'Sophie Lefèvre',
                              time: '3h ago',
                            ),
                          ],
                          onItemTap: (item) {
                            context.push('/label/${item.lotNumber}');
                          },
                        ),
                        const SizedBox(height: AppDimensions.s64), // extra bottom padding for FAB
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    final wrapped = BlocListener<AuthBloc, AuthState>(
      bloc: widget.authBloc,
      listener: (context, state) {
        if (state is Unauthenticated) {
          try {
            context.go('/login');
          } catch (_) {}
        }
      },
      child: body,
    );

    if (widget.homeBloc != null && widget.authBloc != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: widget.homeBloc!),
          BlocProvider.value(value: widget.authBloc!),
        ],
        child: wrapped,
      );
    }

    if (widget.homeBloc != null) {
      return BlocProvider.value(
        value: widget.homeBloc!,
        child: wrapped,
      );
    }

    try {
      context.read<HomeBloc>();
      return wrapped;
    } catch (_) {}

    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const HomeLoadRequested()),
      child: wrapped,
    );
  }
}
