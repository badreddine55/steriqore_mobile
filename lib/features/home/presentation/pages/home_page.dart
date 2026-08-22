import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/role_based_bottom_nav.dart';
import '../../../admin/presentation/widgets/role_badge.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
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

class HomePage extends StatefulWidget {
  final HomeBloc? homeBloc;
  final AuthBloc? authBloc;

  const HomePage({super.key, this.homeBloc, this.authBloc});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<RecentScanItem> _recentUsages = [];
  int _staffCount = 0;
  int _auditEventsCount = 0;
  int _stockCatalogCount = 0;
  int _cyclesCount = 0;
  int _lowStockCount = 0;
  String _latestCycleRef = 'N/A';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = widget.homeBloc ?? context.read<HomeBloc>();
        bloc.add(const HomeLoadRequested());
        _fetchLiveOverviewData();
      }
    });
  }

  Future<void> _fetchLiveOverviewData() async {
    try {
      final dio = sl<DioClient>();

      // 1. Fetch Usages for Recent Scans
      try {
        final usagesRes = await dio.get(ApiConstants.usages);
        final dynamic uData = usagesRes.data;
        List<dynamic> uList = [];
        if (uData is List) {
          uList = uData;
        } else if (uData is Map && uData['data'] is List) {
          uList = uData['data'] as List;
        }

        final parsedUsages = uList.whereType<Map<String, dynamic>>().map((u) {
          final patName = u['patient_name'] ?? u['patient']?['first_name'] ?? 'Patient';
          final prodName = u['product_name'] ?? u['label']?['product_name'] ?? 'Dental Instrument';
          final lot = u['lot_number'] ?? u['label']?['lot_number'] ?? 'LOT';
          final timeStr = u['used_at'] ?? u['created_at'];
          DateTime? dt;
          if (timeStr != null) dt = DateTime.tryParse(timeStr.toString());

          return RecentScanItem(
            productName: prodName.toString(),
            lotNumber: lot.toString(),
            patientName: patName.toString(),
            time: dt != null ? DateFormatter.formatRelative(dt) : 'Recent',
          );
        }).toList();

        if (mounted) {
          setState(() {
            _recentUsages = parsedUsages.take(5).toList();
            _auditEventsCount = uList.length;
          });
        }
      } catch (_) {}

      // 2. Fetch Users count for Admin KPI
      try {
        final usersRes = await dio.get('/users');
        final dynamic uData = usersRes.data;
        List<dynamic> list = [];
        if (uData is List) {
          list = uData;
        } else if (uData is Map && uData['data'] is List) {
          list = uData['data'] as List;
        }
        if (mounted) {
          setState(() => _staffCount = list.length);
        }
      } catch (_) {}

      // 3. Fetch Stock Catalog for Admin / Assistant
      try {
        final stockRes = await dio.get(ApiConstants.stockLevels);
        final dynamic sData = stockRes.data;
        List<dynamic> list = [];
        if (sData is List) {
          list = sData;
        } else if (sData is Map && sData['data'] is List) {
          list = sData['data'] as List;
        }
        final lowCount = list.where((item) {
          if (item is Map) {
            final curr = int.tryParse(item['current_quantity']?.toString() ?? '0') ?? 0;
            final min = int.tryParse(item['min_threshold']?.toString() ?? '5') ?? 5;
            return curr <= min;
          }
          return false;
        }).length;

        if (mounted) {
          setState(() {
            _stockCatalogCount = list.length;
            _lowStockCount = lowCount;
          });
        }
      } catch (_) {}

      // 4. Fetch Cycles for Admin / Assistant
      try {
        final cyclesRes = await dio.get(ApiConstants.cycles);
        final dynamic cData = cyclesRes.data;
        List<dynamic> list = [];
        if (cData is List) {
          list = cData;
        } else if (cData is Map && cData['data'] is List) {
          list = cData['data'] as List;
        }
        String latestRef = 'N/A';
        if (list.isNotEmpty && list.first is Map) {
          final first = list.first as Map;
          latestRef = '#${first['cycle_number'] ?? first['id'] ?? '1'}';
        }
        if (mounted) {
          setState(() {
            _cyclesCount = list.length;
            _latestCycleRef = latestRef;
          });
        }
      } catch (_) {}
    } catch (_) {}
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
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AdminColors.error, size: 20),
            SizedBox(width: 10),
            Text('Sign Out', style: AdminTypography.h3),
          ],
        ),
        content: Text(
          'Are you sure you want to end your session and sign out of STERIQORE?',
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
              try {
                final authBloc = widget.authBloc ?? context.read<AuthBloc>();
                authBloc.add(const AuthLogoutRequested());
              } catch (_) {}
              try {
                context.go('/login');
              } catch (_) {}
            },
            child: const Text('Sign Out', style: AdminTypography.button),
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
            color: AdminColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enter Code Manually', style: AdminTypography.h3),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s8),
              Text(
                'Enter the alphanumeric code printed on the sterilization pouch:',
                style: AdminTypography.bodySmall.copyWith(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.s16),
              TextField(
                controller: controller,
                autofocus: true,
                style: AdminTypography.monospace,
                decoration: const InputDecoration(
                  hintText: 'e.g. LBL-2026-007834',
                  prefixIcon: Icon(Icons.qr_code_2_rounded, size: 20),
                ),
              ),
              const SizedBox(height: AppDimensions.s20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: AdminColors.primaryInverse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final code = controller.text.trim();
                  if (code.isNotEmpty) {
                    Navigator.of(sheetCtx).pop();
                    context.push('/label/$code');
                  }
                },
                child: const Text('Search Label', style: AdminTypography.button),
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

    // Resolve user from state, falling back to cached user model (prevents initial flash of wrong role)
    User? currentUser = authState.user ?? AuthLocalDataSourceImpl.cachedUser?.toEntity();

    // If still authenticating and no cached user is available, display clean loading view
    if (currentUser == null && (authState is AuthInitial || authState is AuthLoading)) {
      return const Scaffold(
        backgroundColor: AdminColors.background,
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
          ),
        ),
      );
    }

    final role = currentUser?.role.toLowerCase() ?? 'practitioner';
    final isAdmin = role == 'admin' || role == 'administrateur';
    final isAssistant = role == 'assistant' || role == 'stock_manager';

    final body = Scaffold(
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
            CircleAvatar(
              radius: 18,
              backgroundColor: AdminColors.primary,
              child: Text(
                currentUser != null && currentUser.name.isNotEmpty
                    ? currentUser.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(color: AdminColors.primaryInverse, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser?.name ?? 'Dental Staff',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTypography.h4,
                  ),
                  Text(
                    '${currentUser?.cabinetName ?? 'Cabinet Central'} · ${currentUser?.cabinetRoom ?? 'Cabinet'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                  ),
                ],
              ),
            ),
            RoleBadge(role: role),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20, color: AdminColors.textSecondary),
              tooltip: 'Sign Out',
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentRoute: '/home'),
      floatingActionButton: (!isAdmin)
          ? FloatingActionButton.extended(
              backgroundColor: AdminColors.primary,
              foregroundColor: AdminColors.primaryInverse,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan Instrument', style: AdminTypography.button),
              onPressed: () => context.push('/scanner'),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          color: AdminColors.accent,
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeRefreshRequested());
            await _fetchLiveOverviewData();
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final stats = (state is HomeLoaded)
                  ? state.stats
                  : const DashboardStats(
                      todayScansCount: 0,
                      pendingSyncCount: 0,
                      activeAlertsCount: 0,
                      lastCycleTimestamp: 'N/A',
                      activeAlertMessages: [],
                    );

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role Header
                        _buildHeader(role, currentUser),
                        const SizedBox(height: 18),

                        // Role-specific widgets
                        if (isAdmin) ..._buildAdminWidgets(context, stats),
                        if (isAssistant) ..._buildAssistantWidgets(context, stats),
                        if (!isAdmin && !isAssistant) ..._buildPractitionerWidgets(context, stats),
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

  Widget _buildHeader(String role, User? user) {
    String greeting;
    String subtitle;
    if (role == 'admin' || role == 'administrateur') {
      greeting = 'Practice Administration';
      subtitle = 'Cabinet governance, user rights, and regulatory audit trail';
    } else if (role == 'assistant' || role == 'stock_manager') {
      greeting = 'Sterilization & Stock Overview';
      subtitle = 'Autoclave batches, lot validation, and supply levels';
    } else {
      greeting = 'Good morning, ${user?.name ?? "Doctor"}';
      subtitle = 'Scan instrument pouches to attach traceability records to patient files';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: AdminTypography.h2),
        const SizedBox(height: 4),
        Text(subtitle, style: AdminTypography.bodySmall.copyWith(color: AdminColors.textSecondary)),
      ],
    );
  }

  List<Widget> _buildAdminWidgets(BuildContext context, DashboardStats stats) => [
        // Admin KPI Summary with live counts
        Row(
          children: [
            Expanded(
              child: _AdminKpiTile(
                title: 'Staff Accounts',
                value: '$_staffCount',
                icon: Icons.people_outline_rounded,
                onTap: () => context.push('/admin/users'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AdminKpiTile(
                title: 'Audit Events',
                value: '$_auditEventsCount',
                icon: Icons.history_edu_rounded,
                onTap: () => context.push('/admin/audit'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AdminKpiTile(
                title: 'Stock Catalog',
                value: '$_stockCatalogCount',
                icon: Icons.inventory_2_outlined,
                onTap: () => context.push('/stock'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AdminKpiTile(
                title: 'Autoclave Cycles',
                value: '$_cyclesCount',
                icon: Icons.local_hospital_outlined,
                onTap: () => context.push('/cycles'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Administrative Navigation
        Text('MANAGEMENT MODULES', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _ActionTile(
          icon: Icons.person_add_outlined,
          title: 'User Management & Roles',
          subtitle: 'Create staff accounts and adjust role permissions',
          onTap: () => context.push('/admin/users'),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.verified_user_outlined,
          title: 'Audit & Compliance Trail',
          subtitle: 'Inspect immutable traceability and clinical events',
          onTap: () => context.push('/admin/audit'),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.tune_rounded,
          title: 'Practice & Safety Settings',
          subtitle: 'DLC thresholds, biometrics, and clinic parameters',
          onTap: () => context.push('/admin/settings'),
        ),
      ];

  List<Widget> _buildAssistantWidgets(BuildContext context, DashboardStats stats) => [
        // Assistant Stock & Cycle Summary with live values
        Row(
          children: [
            Expanded(
              child: _AdminKpiTile(
                title: 'Low Stock Items',
                value: '$_lowStockCount',
                icon: Icons.warning_amber_rounded,
                valueColor: _lowStockCount > 0 ? AdminColors.warning : AdminColors.textPrimary,
                onTap: () => context.push('/stock'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AdminKpiTile(
                title: 'Autoclave Batch',
                value: _latestCycleRef,
                icon: Icons.local_hospital_outlined,
                valueColor: AdminColors.accent,
                onTap: () => context.push('/cycles'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Assistant Quick Actions
        Text('STERILIZATION OPERATIONS', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _ActionTile(
          icon: Icons.add_circle_outline_rounded,
          title: 'Start Sterilization Cycle',
          subtitle: 'Log autoclave chamber, program, and generate lot',
          onTap: () => context.push('/cycles'),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory & Reorders',
          subtitle: 'Monitor stock levels and create supplier orders',
          onTap: () => context.push('/stock'),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Scan & Verify Label',
          subtitle: 'Check pouch validity and lot compliance',
          onTap: () => context.push('/scanner'),
        ),
      ];

  List<Widget> _buildPractitionerWidgets(BuildContext context, DashboardStats stats) => [
        // Primary Hero Quick Action: Scan Package
        QuickActionButton(
          isPrimary: true,
          icon: Icons.qr_code_scanner_rounded,
          title: 'Scan Instrument Package',
          subtitle: 'Verify sterilization & record usage',
          onTap: () => context.push('/scanner'),
        ),
        const SizedBox(height: 20),

        // Stats Card Grid (2x2)
        StatsCardGrid(stats: stats),
        const SizedBox(height: 20),

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
            const SizedBox(width: 16),
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
        const SizedBox(height: 24),

        // Compliance Alerts Card
        Text('COMPLIANCE & ALERTS', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        AlertSummaryCard(alerts: stats.activeAlertMessages),
        const SizedBox(height: 24),

        // Recent Scans Section with real logs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RECENT TRACEABILITY LOGS', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: () => context.push('/history'),
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
        _recentUsages.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.borderSubtle),
                ),
                child: Center(
                  child: Text(
                    'No recent instrument scans recorded yet.',
                    style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                  ),
                ),
              )
            : RecentScansList(
                items: _recentUsages,
                onItemTap: (item) {
                  context.push('/label/${item.lotNumber}');
                },
              ),
      ];
}

class _AdminKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback onTap;

  const _AdminKpiTile({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AdminTypography.navLabel),
                    Icon(icon, size: 18, color: AdminColors.textTertiary),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: AdminTypography.h1.copyWith(
                    color: valueColor ?? AdminColors.textPrimary,
                    fontSize: 26,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: AdminColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AdminTypography.h4),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AdminColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
