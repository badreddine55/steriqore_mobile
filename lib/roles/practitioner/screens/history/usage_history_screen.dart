import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/steriqore_shared.dart';
import '../../blocs/history/history_bloc.dart';
import '../../blocs/history/history_event.dart';
import '../../blocs/history/history_state.dart';
import '../../models/usage_model.dart';
import '../../offline/sync_service.dart';
import '../../widgets/usage_history_tile.dart';

class UsageHistoryScreen extends StatefulWidget {
  const UsageHistoryScreen({super.key});

  @override
  State<UsageHistoryScreen> createState() => _UsageHistoryScreenState();
}

class _UsageHistoryScreenState extends State<UsageHistoryScreen> {
  final _searchController = TextEditingController();
  int _selectedDateFilterIndex = 0; // 0: All, 1: Today, 2: This Week, 3: This Month

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyDateFilter(BuildContext context, int index) {
    setState(() => _selectedDateFilterIndex = index);
    final now = DateTime.now();

    DateTime? from;
    DateTime? to;

    if (index == 1) {
      // Today
      from = DateTime(now.year, now.month, now.day);
      to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (index == 2) {
      // This Week
      from = now.subtract(Duration(days: now.weekday - 1));
      from = DateTime(from.year, from.month, from.day);
    } else if (index == 3) {
      // This Month
      from = DateTime(now.year, now.month, 1);
    }

    context.read<HistoryBloc>().add(FilterHistoryByDate(from: from, to: to));
  }

  void _showUsageDetailSheet(BuildContext context, UsageModel usage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Usage Audit Record',
                    style: steriqoreFont(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Product', value: usage.productName),
              _DetailRow(label: 'Lot Number', value: usage.lotNumber),
              _DetailRow(label: 'Reference', value: usage.reference.isNotEmpty ? usage.reference : usage.labelCode),
              _DetailRow(label: 'Patient', value: '${usage.patientName} (${usage.patientIdentifier ?? 'PAT-${usage.patientId}'})'),
              _DetailRow(label: 'Practitioner', value: usage.practitionerName),
              _DetailRow(label: 'Recorded Date', value: usage.usedAt.toString().split('.')[0]),
              _DetailRow(label: 'Procedure', value: usage.procedureType ?? 'Standard Procedure'),
              if (usage.notes != null && usage.notes!.isNotEmpty)
                _DetailRow(label: 'Notes', value: usage.notes!),
              _DetailRow(label: 'Idempotency UUID', value: usage.idempotencyKey, isLast: true),
              const SizedBox(height: 20),
              DentisTrackSecondaryButton(
                label: 'Close Record',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryBloc()..add(const LoadUsageHistory()),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDefault,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundElevated,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Usage Traceability History',
            style: steriqoreFont(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Top Search & Filter Section
                  Container(
                    color: AppColors.backgroundElevated,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                    child: ResponsiveContentContainer(
                      maxWidth: Breakpoints.dashboardMaxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Input Field
                          TextField(
                            controller: _searchController,
                            onChanged: (val) => context.read<HistoryBloc>().add(SearchHistory(val)),
                            style: steriqoreFont(fontSize: 14.5),
                            decoration: InputDecoration(
                              hintText: 'Search product, lot #, or patient...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<HistoryBloc>().add(const SearchHistory(''));
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Date Filter Quick Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'All Time',
                                  isSelected: _selectedDateFilterIndex == 0,
                                  onTap: () => _applyDateFilter(context, 0),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Today',
                                  isSelected: _selectedDateFilterIndex == 1,
                                  onTap: () => _applyDateFilter(context, 1),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'This Week',
                                  isSelected: _selectedDateFilterIndex == 2,
                                  onTap: () => _applyDateFilter(context, 2),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'This Month',
                                  isSelected: _selectedDateFilterIndex == 3,
                                  onTap: () => _applyDateFilter(context, 3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // History Items List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await SyncService().syncNow();
                        if (context.mounted) {
                          context.read<HistoryBloc>().add(const LoadUsageHistory());
                        }
                      },
                      child: _buildBody(context, state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryState state) {
    if (state is HistoryLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    if (state is HistoryError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Failed to load history',
                style: steriqoreFont(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(state.message, textAlign: TextAlign.center, style: steriqoreFont(fontSize: 13.5, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              DentisTrackSecondaryButton(
                label: 'Retry',
                onPressed: () => context.read<HistoryBloc>().add(const LoadUsageHistory()),
              ),
            ],
          ),
        ),
      );
    }

    if (state is HistoryLoaded) {
      if (state.filteredUsages.isEmpty) {
        return ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 14),
                  Text(
                    'No usage records match the filter',
                    style: steriqoreFont(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try changing your date filter or search query.',
                    style: steriqoreFont(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.filteredUsages.length,
        itemBuilder: (context, index) {
          final usage = state.filteredUsages[index];
          return ResponsiveContentContainer(
            maxWidth: Breakpoints.dashboardMaxWidth,
            child: UsageHistoryTile(
              usage: usage,
              onTap: () => _showUsageDetailSheet(context, usage),
              onRetrySync: () {
                context.read<HistoryBloc>().add(RetrySyncItem(usage));
              },
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundDefault,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: steriqoreFont(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: steriqoreFont(fontSize: 13, color: AppColors.textSecondary),
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
              style: steriqoreFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
