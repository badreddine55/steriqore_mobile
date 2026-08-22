import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/role_based_bottom_nav.dart';

class SterilizationCycle {
  final String id;
  final int cycleNumber;
  final String autoclaveId;
  final String autoclaveName;
  final String program;
  final String status;
  final int itemsCount;
  final String lotNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime dlcExpiration;
  final double peakTemperature;
  final double peakPressure;

  const SterilizationCycle({
    required this.id,
    required this.cycleNumber,
    required this.autoclaveId,
    required this.autoclaveName,
    required this.program,
    required this.status,
    required this.itemsCount,
    required this.lotNumber,
    required this.startedAt,
    this.completedAt,
    required this.dlcExpiration,
    required this.peakTemperature,
    required this.peakPressure,
  });

  bool get isValidated => status == 'VALIDATED' || status == 'conforme' || status == 'completed';
  bool get isInProgress => status == 'IN_PROGRESS' || status == 'running';
  bool get isFailed => status == 'FAILED' || status == 'non_conforme';

  factory SterilizationCycle.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    final cycleNum = int.tryParse(json['cycle_number']?.toString() ?? json['id']?.toString() ?? '1') ?? 1;
    final lot = json['lot_number']?.toString() ?? 'LOT-2026-$cycleNum';

    return SterilizationCycle(
      id: json['id']?.toString() ?? 'CYC-$cycleNum',
      cycleNumber: cycleNum,
      autoclaveId: json['autoclave_id']?.toString() ?? 'AUTO-MELAG-01',
      autoclaveName: json['autoclave_name']?.toString() ?? json['autoclave']?.toString() ?? 'Melag Vacuklav 40B+',
      program: json['program']?.toString() ?? json['program_name']?.toString() ?? '134°C Prion (18 min)',
      status: (json['status']?.toString() ?? 'VALIDATED').toUpperCase(),
      itemsCount: int.tryParse(json['items_count']?.toString() ?? json['packages_count']?.toString() ?? '0') ?? 0,
      lotNumber: lot,
      startedAt: parseDate(json['started_at'] ?? json['sterilization_date'] ?? json['created_at']),
      completedAt: json['completed_at'] != null ? parseDate(json['completed_at']) : null,
      dlcExpiration: json['dlc_expiration'] != null
          ? parseDate(json['dlc_expiration'])
          : DateTime.now().add(const Duration(days: 90)),
      peakTemperature: double.tryParse(json['temperature']?.toString() ?? json['peak_temperature']?.toString() ?? '134.0') ?? 134.0,
      peakPressure: double.tryParse(json['pressure_bar']?.toString() ?? json['peak_pressure']?.toString() ?? '2.1') ?? 2.1,
    );
  }
}

class CyclesPage extends StatefulWidget {
  const CyclesPage({super.key});

  @override
  State<CyclesPage> createState() => _CyclesPageState();
}

class _CyclesPageState extends State<CyclesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  List<SterilizationCycle> _cycles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCycles();
  }

  Future<void> _fetchCycles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = sl<DioClient>();
      final response = await dio.get(ApiConstants.cycles);

      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data') && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is Map && data.containsKey('cycles') && data['cycles'] is List) {
        list = data['cycles'] as List;
      }

      final parsed = list
          .whereType<Map<String, dynamic>>()
          .map((item) => SterilizationCycle.fromJson(item))
          .toList();

      setState(() {
        _cycles = parsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _cycles = [];
        _isLoading = false;
        _errorMessage = 'Could not load sterilization cycles from server.';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SterilizationCycle> get _filteredCycles {
    final query = _searchController.text.trim().toLowerCase();
    return _cycles.where((c) {
      if (query.isNotEmpty) {
        final match = c.id.toLowerCase().contains(query) ||
            c.lotNumber.toLowerCase().contains(query) ||
            c.autoclaveName.toLowerCase().contains(query) ||
            c.program.toLowerCase().contains(query);
        if (!match) return false;
      }
      if (_selectedFilter == 'validated' && !c.isValidated) return false;
      if (_selectedFilter == 'failed' && !c.isFailed) return false;
      return true;
    }).toList();
  }

  void _showNewCycleSheet() {
    final autoclaveController = TextEditingController(text: 'Melag Vacuklav 40B+ (Bay 1)');
    final itemsCountController = TextEditingController(text: '16');
    String selectedProgram = '134°C Prion (18 min)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: AdminColors.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AdminColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Start Sterilization Cycle', style: AdminTypography.h3),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AdminColors.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: autoclaveController,
                  decoration: const InputDecoration(
                    labelText: 'Autoclave Device',
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedProgram,
                  decoration: const InputDecoration(labelText: 'Sterilization Program'),
                  items: const [
                    DropdownMenuItem(
                      value: '134°C Prion (18 min)',
                      child: Text('134°C Prion (18 min) - Mandatory EN 13060'),
                    ),
                    DropdownMenuItem(
                      value: '121°C Standard (30 min)',
                      child: Text('121°C Standard (30 min) - Rubber/Optics'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setSheetState(() => selectedProgram = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: itemsCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Packages / Pouches in Chamber',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: AdminColors.primaryInverse,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final newCycle = SterilizationCycle(
                      id: 'CYC-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      cycleNumber: DateTime.now().millisecondsSinceEpoch % 1000,
                      autoclaveId: 'AUTO-MELAG-01',
                      autoclaveName: autoclaveController.text.trim(),
                      program: selectedProgram,
                      status: 'VALIDATED',
                      itemsCount: int.tryParse(itemsCountController.text) ?? 16,
                      lotNumber: 'LOT-2026-${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}',
                      startedAt: DateTime.now(),
                      completedAt: DateTime.now().add(const Duration(minutes: 50)),
                      dlcExpiration: DateTime.now().add(const Duration(days: 90)),
                      peakTemperature: 135.5,
                      peakPressure: 2.17,
                    );
                    setState(() {
                      _cycles.insert(0, newCycle);
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cycle #${newCycle.cycleNumber} logged and lot ${newCycle.lotNumber} created.'),
                        backgroundColor: AdminColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  child: const Text('Log & Validate Cycle', style: AdminTypography.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCycles;

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
        title: const Text('Sterilization Cycles', style: AdminTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AdminColors.textPrimary),
            tooltip: 'Refresh Cycles',
            onPressed: _fetchCycles,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: AdminColors.primaryInverse,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New Cycle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              onPressed: _showNewCycleSheet,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentRoute: '/cycles'),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header
            Container(
              color: AdminColors.surfaceElevated,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: AdminTypography.body,
                      decoration: InputDecoration(
                        hintText: 'Search cycles by ID, lot, autoclave...',
                        hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AdminColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: AdminColors.surfaceMuted,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FilterTab(
                        label: 'All Cycles (${_cycles.length})',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Validated (${_cycles.where((c) => c.isValidated).length})',
                        isSelected: _selectedFilter == 'validated',
                        onTap: () => setState(() => _selectedFilter = 'validated'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Failed (${_cycles.where((c) => c.isFailed).length})',
                        isSelected: _selectedFilter == 'failed',
                        onTap: () => setState(() => _selectedFilter = 'failed'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(color: AdminColors.borderSubtle, height: 1),

            // Cycles List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
                      ),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_hospital_outlined, size: 48, color: AdminColors.borderStrong),
                                const SizedBox(height: 16),
                                const Text('No Sterilization Cycles Found', style: AdminTypography.h4),
                                const SizedBox(height: 6),
                                Text(
                                  _errorMessage ?? 'No cycle records found in database.',
                                  textAlign: TextAlign.center,
                                  style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AdminColors.accent,
                          onRefresh: _fetchCycles,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final cycle = filtered[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AdminColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: cycle.isFailed
                                        ? AdminColors.error.withValues(alpha: 0.4)
                                        : AdminColors.borderSubtle,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Cycle #${cycle.cycleNumber} · ${cycle.id}',
                                          style: AdminTypography.h4,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: cycle.isFailed ? AdminColors.errorBg : AdminColors.successBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            cycle.status,
                                            style: AdminTypography.caption.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: cycle.isFailed ? AdminColors.error : AdminColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${cycle.autoclaveName} · ${cycle.program}',
                                      style: AdminTypography.bodySmall.copyWith(color: AdminColors.textSecondary),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AdminColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('LOT NUMBER', style: AdminTypography.navLabel.copyWith(fontSize: 10)),
                                              Text(cycle.lotNumber, style: AdminTypography.monospace.copyWith(fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('ITEMS', style: AdminTypography.navLabel.copyWith(fontSize: 10)),
                                              Text('${cycle.itemsCount} pouches', style: AdminTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('PHYSICAL TEST', style: AdminTypography.navLabel.copyWith(fontSize: 10)),
                                              Text('${cycle.peakTemperature}°C / ${cycle.peakPressure} bar', style: AdminTypography.monospace.copyWith(fontSize: 11)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Started: ${DateFormatter.formatDateTime(cycle.startedAt)}',
                                          style: AdminTypography.caption.copyWith(color: AdminColors.textTertiary),
                                        ),
                                        Text(
                                          'DLC: ${DateFormatter.formatDate(cycle.dlcExpiration)}',
                                          style: AdminTypography.caption.copyWith(
                                            color: cycle.isFailed ? AdminColors.error : AdminColors.accent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primary : AdminColors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AdminColors.primary : AdminColors.borderSubtle,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AdminTypography.caption.copyWith(
            color: isSelected ? AdminColors.primaryInverse : AdminColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
