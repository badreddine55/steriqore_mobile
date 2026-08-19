import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../scanner/domain/entities/label.dart';
import '../../domain/entities/patient.dart';
import '../bloc/usage_bloc.dart';
import '../bloc/usage_event.dart';
import '../bloc/usage_state.dart';
import '../widgets/offline_badge.dart';
import '../../../../core/di/injection.dart';
import '../widgets/usage_summary_card.dart';

class UsageConfirmationPage extends StatefulWidget {
  final Label label;
  final Patient patient;
  final UsageBloc? usageBloc;

  const UsageConfirmationPage({
    super.key,
    required this.label,
    required this.patient,
    this.usageBloc,
  });

  @override
  State<UsageConfirmationPage> createState() => _UsageConfirmationPageState();
}

class _UsageConfirmationPageState extends State<UsageConfirmationPage> {
  final _notesController = TextEditingController();
  final _procedureController = TextEditingController(text: 'Dental Implant / Care');

  @override
  void dispose() {
    _notesController.dispose();
    _procedureController.dispose();
    super.dispose();
  }

  void _handleConfirmUsage(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String practitionerId = '1';
    String practitionerName = 'Dr. Practitioner';

    if (authState is Authenticated) {
      practitionerId = authState.user.id.toString();
      practitionerName = 'Dr. ${authState.user.name}';
    }

    context.read<UsageBloc>().add(UsageNotesChangedEvent(_notesController.text.trim()));
    context.read<UsageBloc>().add(UsageProcedureChangedEvent(_procedureController.text.trim()));

    context.read<UsageBloc>().add(
          UsageSubmitRequested(
            label: widget.label,
            practitionerId: practitionerId,
            practitionerName: practitionerName,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String practitionerName = 'Dr. Practitioner';
    if (authState is Authenticated) {
      practitionerName = 'Dr. ${authState.user.name}';
    }

    final body = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Usage Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<UsageBloc, UsageState>(
          listener: (context, state) {
            if (state.status == UsageFormStatus.success && state.recordedUsage != null) {
              context.go(
                '/usage/success',
                extra: {
                  'usage': state.recordedUsage!,
                  'isOffline': state.isOfflineQueued,
                },
              );
            } else if (state.status == UsageFormStatus.blocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Safety error: Instrument blocked.'),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state.status == UsageFormStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state.status == UsageFormStatus.submitting;

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
                            // Offline notice banner
                            if (state.isOfflineQueued) ...[
                              const OfflineBadge(),
                              const SizedBox(height: AppDimensions.s16),
                            ],

                            // Main Usage Summary Card
                            UsageSummaryCard(
                              label: widget.label,
                              patient: widget.patient,
                              practitionerName: practitionerName,
                              timestamp: DateTime.now(),
                            ),
                            const SizedBox(height: AppDimensions.s20),

                            // Procedure Type Input
                            Text('CLINICAL DETAILS (OPTIONAL)', style: AppTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: AppDimensions.s8),
                            AppTextField(
                              label: 'Procedure / Acte',
                              hint: 'e.g. Pose implant 3.5, Parodontie...',
                              controller: _procedureController,
                              prefixIcon: const Icon(Icons.medical_information_outlined, size: 20),
                            ),
                            const SizedBox(height: AppDimensions.s16),

                            // Notes Input
                            AppTextField(
                              label: 'Clinical Notes / Remarques',
                              hint: 'Add any specific traceability observations...',
                              controller: _notesController,
                              maxLines: 3,
                              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                            ),
                            const SizedBox(height: AppDimensions.s24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Confirmation CTA
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton.primary(
                            label: 'Confirm & Sign Traceability',
                            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                            isLoading: isSubmitting,
                            onPressed: isSubmitting ? null : () => _handleConfirmUsage(context),
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          AppButton.ghost(
                            label: 'Change Patient',
                            onPressed: isSubmitting ? null : () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (widget.usageBloc != null) {
      return BlocProvider.value(
        value: widget.usageBloc!,
        child: body,
      );
    }

    try {
      context.read<UsageBloc>();
      return body;
    } catch (_) {}

    return BlocProvider(
      create: (_) => sl<UsageBloc>(),
      child: body,
    );
  }
}
