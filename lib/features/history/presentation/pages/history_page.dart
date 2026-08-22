import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../domain/entities/usage_history_entry.dart';
import '../../../../core/di/injection.dart';
import '../widgets/history_filter_chips.dart';
import '../widgets/history_list_item.dart';
import '../widgets/sync_status_indicator.dart';
import '../../../../shared/widgets/role_based_bottom_nav.dart';

class HistoryPage extends StatefulWidget {
  final HistoryBloc? historyBloc;

  const HistoryPage({super.key, this.historyBloc});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = widget.historyBloc ?? context.read<HistoryBloc>();
        bloc.add(const HistoryLoadRequested());
      }
    });
  }

  void _showDetailBottomSheet(BuildContext context, UsageHistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            decoration: const BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radius2xl)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppDimensions.s12),
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Traceability Entry Details', style: AppTypography.h3),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s16),
                _DetailLine(label: 'Patient', value: entry.patientName),
                _DetailLine(label: 'Dossier ID', value: entry.dossierId),
                _DetailLine(label: 'Instrument', value: entry.productName),
                _DetailLine(label: 'Lot / Batch', value: entry.lotNumber, isMonospace: true),
                _DetailLine(label: 'Package Code', value: entry.labelCode),
                _DetailLine(label: 'Recorded At', value: DateFormatter.formatDateTime(entry.usedAt)),
                _DetailLine(label: 'Idempotency UUID', value: entry.idempotencyKey, isMonospace: true),
                if (entry.procedureType != null) _DetailLine(label: 'Procedure', value: entry.procedureType!),
                if (entry.notes != null) _DetailLine(label: 'Notes', value: entry.notes!),
                const SizedBox(height: AppDimensions.s12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sync Status', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                    SyncStatusIndicator(status: entry.syncStatus),
                  ],
                ),
                const SizedBox(height: AppDimensions.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Traceability History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentRoute: '/history'),
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Column(
                  children: [
                    // Top Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding,
                        AppDimensions.s12,
                        AppDimensions.screenPadding,
                        AppDimensions.s12,
                      ),
                      child: AppSearchBar(
                        hint: 'Search by patient, instrument, or lot...',
                        onChanged: (q) {
                          context.read<HistoryBloc>().add(HistoryLoadRequested(query: q));
                        },
                        onClear: () {
                          context.read<HistoryBloc>().add(const HistoryLoadRequested(query: ''));
                        },
                      ),
                    ),

                // Horizontal Filter Chips
                HistoryFilterChips(
                  activeFilter: state.activeFilter,
                  onFilterSelected: (f) {
                    context.read<HistoryBloc>().add(HistoryFilterChangedEvent(f));
                  },
                ),
                const SizedBox(height: AppDimensions.s12),

                // Main List Area
                Expanded(
                  child: state.status == HistoryStatus.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : state.items.isEmpty
                          ? AppEmptyState(
                              title: 'No Usage Records',
                              message: state.searchQuery.isNotEmpty
                                  ? 'No records match "${state.searchQuery}".'
                                  : 'No instrument usages recorded yet under this filter.',
                              buttonLabel: 'Scan Instrument Now',
                              onAction: () => context.push('/scanner'),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<HistoryBloc>().add(const HistoryRefreshRequested());
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                                itemCount: state.items.length,
                                separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.s12),
                                itemBuilder: (context, index) {
                                  final entry = state.items[index];
                                  return HistoryListItem(
                                    entry: entry,
                                    onTap: () => _showDetailBottomSheet(context, entry),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),
);

    if (widget.historyBloc != null) {
      return BlocProvider.value(
        value: widget.historyBloc!,
        child: body,
      );
    }

    try {
      context.read<HistoryBloc>();
      return body;
    } catch (_) {}

    return BlocProvider(
      create: (_) => sl<HistoryBloc>()..add(const HistoryLoadRequested()),
      child: body,
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;

  const _DetailLine({
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppDimensions.s12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: (isMonospace ? AppTypography.data : AppTypography.caption).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
