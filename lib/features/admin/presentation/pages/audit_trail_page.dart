import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/audit_entry.dart';
import '../bloc/admin_audit_bloc.dart';
import '../bloc/admin_audit_event.dart';
import '../bloc/admin_audit_state.dart';
import '../widgets/audit_filter_sheet.dart';
import '../widgets/audit_timeline_tile.dart';

class AuditTrailPage extends StatefulWidget {
  const AuditTrailPage({super.key});

  @override
  State<AuditTrailPage> createState() => _AuditTrailPageState();
}

class _AuditTrailPageState extends State<AuditTrailPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTimeframe = 'all';
  String _selectedAction = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminAuditBloc>().add(const AdminLoadAuditRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<AdminAuditBloc>().add(AdminAuditSearchChanged(query));
  }

  void _openFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AuditFilterSheet(
        selectedDateFilter: _selectedTimeframe,
        selectedActionFilter: _selectedAction,
        onDateFilterSelected: (val) {
          setState(() => _selectedTimeframe = val);
          context.read<AdminAuditBloc>().add(AdminAuditDateFilterChanged(val));
        },
        onActionFilterSelected: (val) {
          setState(() => _selectedAction = val);
          context.read<AdminAuditBloc>().add(AdminAuditActionFilterChanged(val));
        },
        onReset: () {
          setState(() {
            _selectedTimeframe = 'all';
            _selectedAction = 'all';
          });
          context.read<AdminAuditBloc>().add(const AdminAuditDateFilterChanged('all'));
          context.read<AdminAuditBloc>().add(const AdminAuditActionFilterChanged('all'));
        },
      ),
    );
  }

  void _showEntryDetailSheet(BuildContext context, AuditEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                width: 40,
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
                const Text('Audit Record Details', style: AdminTypography.h3),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AdminColors.textSecondary),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _DetailRow(label: 'Record ID', value: entry.id, isMono: true),
            _DetailRow(label: 'Action Type', value: entry.action, isBold: true),
            _DetailRow(label: 'Staff Member', value: '${entry.userName} (${entry.userRole.toUpperCase()})'),
            _DetailRow(label: 'Timestamp', value: DateFormatter.formatDateTime(entry.timestamp)),
            if (entry.entityId != null) _DetailRow(label: 'Entity Ref', value: entry.entityId!, isMono: true),
            _DetailRow(label: 'IP Address', value: entry.ipAddress, isMono: true),
            _DetailRow(label: 'User Agent / Terminal', value: entry.userAgent ?? 'Steriqore Terminal'),
            const SizedBox(height: 12),

            Text('AUDIT DESCRIPTION', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AdminColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminColors.borderSubtle),
              ),
              child: Text(
                entry.details,
                style: AdminTypography.bodySmall.copyWith(color: AdminColors.textPrimary, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: AdminColors.primaryInverse,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close Inspector', style: AdminTypography.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _selectedTimeframe != 'all' || _selectedAction != 'all';

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
          onPressed: () => context.pop(),
        ),
        title: const Text('Audit Trail & Compliance', style: AdminTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AdminColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<AdminAuditBloc>().add(const AdminRefreshAuditRequested());
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded, color: AdminColors.textPrimary),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AdminColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter Logs',
            onPressed: () => _openFilterModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Container (40px, #F1F5F9)
            Container(
              color: AdminColors.surfaceElevated,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AdminTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Search actions, staff names, or entity IDs...',
                    hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AdminColors.textTertiary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16, color: AdminColors.textTertiary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: AdminColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AdminColors.borderStrong),
                    ),
                  ),
                ),
              ),
            ),
            Container(color: AdminColors.borderSubtle, height: 1),

            // Timeline List Content
            Expanded(
              child: BlocBuilder<AdminAuditBloc, AdminAuditState>(
                builder: (context, state) {
                  if (state.status == AdminAuditStatus.loading && state.entries.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AdminColors.accent),
                    );
                  }

                  final displayEntries = state.filteredEntries;

                  if (displayEntries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.history_edu_rounded,
                              size: 48,
                              color: AdminColors.borderStrong, // Simple line icon, NO illustration
                            ),
                            const SizedBox(height: 16),
                            const Text('No Audit Records Found', style: AdminTypography.h4),
                            const SizedBox(height: 6),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No audit entries match "${_searchController.text}".'
                                  : 'No clinical operations or actions logged matching filter.',
                              textAlign: TextAlign.center,
                              style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AdminColors.accent,
                    onRefresh: () async {
                      context.read<AdminAuditBloc>().add(const AdminRefreshAuditRequested());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: displayEntries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = displayEntries[index];
                        return AuditTimelineTile(
                          entry: entry,
                          onTap: () => _showEntryDetailSheet(context, entry),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isMono = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: isMono
                  ? AdminTypography.mono.copyWith(fontSize: 12)
                  : AdminTypography.bodySmall.copyWith(
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                      color: AdminColors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
