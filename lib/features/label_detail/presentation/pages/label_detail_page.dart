import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../bloc/label_detail_bloc.dart';
import '../bloc/label_detail_event.dart';
import '../bloc/label_detail_state.dart';
import '../widgets/blocking_alert_widget.dart';
import '../widgets/cycle_status_card.dart';
import '../widgets/product_header_card.dart';
import '../../../../core/di/injection.dart';
import '../widgets/sterilization_info_card.dart';

class LabelDetailPage extends StatefulWidget {
  final String code;
  final LabelDetailBloc? labelDetailBloc;

  const LabelDetailPage({
    super.key,
    required this.code,
    this.labelDetailBloc,
  });

  @override
  State<LabelDetailPage> createState() => _LabelDetailPageState();
}

class _LabelDetailPageState extends State<LabelDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final bloc = widget.labelDetailBloc ?? context.read<LabelDetailBloc>();
          if (bloc.state is LabelDetailInitial) {
            bloc.add(LoadLabelDetailRequested(widget.code));
          }
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Traceability Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              try {
                final bloc = widget.labelDetailBloc ?? context.read<LabelDetailBloc>();
                bloc.add(RefreshLabelDetailRequested(widget.code));
              } catch (_) {}
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<LabelDetailBloc, LabelDetailState>(
          builder: (context, state) {
            if (state is LabelDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is LabelDetailError) {
              return AppErrorWidget(
                title: 'Lookup Failed',
                message: state.message,
                onRetry: () {
                  final bloc = widget.labelDetailBloc ?? context.read<LabelDetailBloc>();
                  bloc.add(LoadLabelDetailRequested(widget.code));
                },
              );
            }

            if (state is LabelDetailLoaded) {
              final label = state.label;
              final cycle = state.cycle;
              final isBlocked = state.isBlocked;

              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppDimensions.screenPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isBlocked) ...[
                                BlockingAlertWidget.blocked(
                                  message: state.blockReason ?? 'This instrument cannot be used on a patient.',
                                ),
                                const SizedBox(height: AppDimensions.s16),
                              ],
                              ProductHeaderCard(
                                label: label,
                              ),
                              const SizedBox(height: AppDimensions.s16),
                              SterilizationInfoCard(
                                cycle: cycle,
                              ),
                              if (cycle != null) ...[
                                const SizedBox(height: AppDimensions.s16),
                                CycleStatusCard(
                                  isValidated: cycle.isValidated,
                                  statusText: cycle.isValidated
                                      ? 'Autoclave cycle completed with biological and physical conformity.'
                                      : 'Cycle did not meet conformity thresholds.',
                                ),
                              ],
                              const SizedBox(height: AppDimensions.s24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    decoration: const BoxDecoration(
                      color: AppColors.elevated,
                      border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isBlocked) ...[
                              AppButton.primary(
                                label: 'Use on Patient',
                                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                onPressed: () {
                                  context.push(
                                    '/usage/patient-select',
                                    extra: label,
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: AppDimensions.s12),
                            AppButton.secondary(
                              label: 'Scan Another Package',
                              onPressed: () => context.pushReplacement('/scanner'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );

    if (widget.labelDetailBloc != null) {
      return BlocProvider.value(
        value: widget.labelDetailBloc!,
        child: body,
      );
    }

    try {
      context.read<LabelDetailBloc>();
      return body;
    } catch (_) {}

    return BlocProvider(
      create: (_) => sl<LabelDetailBloc>()..add(LoadLabelDetailRequested(widget.code)),
      child: body,
    );
  }
}
