import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/steriqore_shared.dart';
import '../../blocs/usage/usage_bloc.dart';
import '../../blocs/usage/usage_event.dart';
import '../../blocs/usage/usage_state.dart';
import '../../models/label_model.dart';
import '../../practitioner_routes.dart';
import '../../widgets/patient_picker.dart';

class UsageConfirmationScreen extends StatefulWidget {
  final LabelModel label;
  final UsageBloc? usageBloc;

  const UsageConfirmationScreen({
    super.key,
    required this.label,
    this.usageBloc,
  });

  @override
  State<UsageConfirmationScreen> createState() => _UsageConfirmationScreenState();
}

class _UsageConfirmationScreenState extends State<UsageConfirmationScreen> {
  final _notesController = TextEditingController();
  final _procedureController = TextEditingController(text: 'Dental Implant Placement');

  @override
  void dispose() {
    _notesController.dispose();
    _procedureController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, UsageState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.isOfflineQueued
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  state.isOfflineQueued ? Icons.cloud_queue_rounded : Icons.check_circle_rounded,
                  size: 48,
                  color: state.isOfflineQueued ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                state.isOfflineQueued ? 'Queued for Sync' : 'Usage Recorded!',
                style: steriqoreFont(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                state.isOfflineQueued
                    ? 'Saved locally on device with audit idempotency key. Will sync automatically when connection returns.'
                    : 'Traceability record successfully created on practice audit trail.',
                textAlign: TextAlign.center,
                style: steriqoreFont(fontSize: 13.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              DentisTrackPrimaryButton(
                label: 'Done',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    PractitionerRoutes.dashboard,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundElevated,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Confirm Patient Usage',
          style: steriqoreFont(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<UsageBloc, UsageState>(
          listener: (context, state) {
            if (state.status == UsageFormStatus.success) {
              _showSuccessDialog(context, state);
            } else if (state.status == UsageFormStatus.blocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Cannot record: Instrument is blocked.'),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state.status == UsageFormStatus.alreadyUsed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Usage already recorded.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ResponsiveContentContainer(
                maxWidth: Breakpoints.authFormMaxWidth + 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Instrument Summary Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INSTRUMENT PACKAGE',
                            style: steriqoreFont(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.label.productName,
                            style: steriqoreFont(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lot: ${widget.label.lotNumber} · Ref: ${widget.label.reference}',
                            style: steriqoreFont(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section Title: Mandatory Patient Selection
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'ASSIGN TO PATIENT (REQUIRED)',
                          style: steriqoreFont(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Patient Picker Widget
                    PatientPicker(
                      selectedPatient: state.selectedPatient,
                      onPatientSelected: (patient) {
                        context.read<UsageBloc>().add(UsagePatientSelected(patient));
                      },
                      onClear: () {
                        context.read<UsageBloc>().add(const UsagePatientCleared());
                      },
                    ),
                    if (state.fieldErrors.containsKey('patient_id')) ...[
                      const SizedBox(height: 6),
                      Text(
                        state.fieldErrors['patient_id']!.first,
                        style: steriqoreFont(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Procedure & Clinical Notes Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clinical Procedure Details (Optional)',
                            style: steriqoreFont(fontSize: 14.5, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _procedureController,
                            onChanged: (val) => context.read<UsageBloc>().add(UsageProcedureTypeChanged(val)),
                            style: steriqoreFont(fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: 'Procedure Type',
                              prefixIcon: Icon(Icons.medical_services_outlined, size: 18),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            onChanged: (val) => context.read<UsageBloc>().add(UsageNotesChanged(val)),
                            style: steriqoreFont(fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: 'Traceability Notes / Tooth #',
                              hintText: 'e.g. Tooth 36, bone graft implant session',
                              prefixIcon: Icon(Icons.note_alt_outlined, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Medical Compliance Audit Trail Notice
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Traceability event will capture your authenticated ID, device timestamp, and generate an idempotent audit hash.',
                              style: steriqoreFont(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Confirmation CTA Button
                    DentisTrackPrimaryButton(
                      label: state.selectedPatient == null ? 'Select a Patient to Confirm' : 'Confirm & Record Usage',
                      isLoading: state.status == UsageFormStatus.submitting,
                      onPressed: state.canSubmit
                          ? () {
                              context.read<UsageBloc>().add(UsageSubmitted(label: widget.label));
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DentisTrackSecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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

    return BlocProvider(
      create: (_) => UsageBloc(),
      child: body,
    );
  }
}
