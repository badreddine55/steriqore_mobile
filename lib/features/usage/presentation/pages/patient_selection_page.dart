import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../scanner/domain/entities/label.dart';
import '../../domain/entities/patient.dart';
import '../bloc/usage_bloc.dart';
import '../bloc/usage_event.dart';
import '../bloc/usage_state.dart';
import '../widgets/patient_list_item.dart';
import '../../../../core/di/injection.dart';
import '../widgets/patient_search_bar.dart';

class PatientSelectionPage extends StatefulWidget {
  final Label label;
  final UsageBloc? usageBloc;

  const PatientSelectionPage({
    super.key,
    required this.label,
    this.usageBloc,
  });

  @override
  State<PatientSelectionPage> createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load patients
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final bloc = widget.usageBloc ?? context.read<UsageBloc>();
          if (bloc.state.status == UsageFormStatus.initial) {
            bloc.add(const UsageLoadPatientsRequested());
          }
        } catch (_) {}
      }
    });
  }

  void _onAddNewPatientQuickModal() {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final dossierCtrl = TextEditingController(text: 'DOS-${DateTime.now().year}-${DateTime.now().millisecond}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
        ),
        child: Center(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quick Register Patient', style: AppTypography.h3),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.s16),
                  TextField(
                    controller: firstCtrl,
                    decoration: const InputDecoration(labelText: 'First Name', hintText: 'e.g. Marc'),
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  TextField(
                    controller: lastCtrl,
                    decoration: const InputDecoration(labelText: 'Last Name', hintText: 'e.g. Vasseur'),
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  TextField(
                    controller: dossierCtrl,
                    decoration: const InputDecoration(labelText: 'Dossier ID', hintText: 'DOS-2026-999'),
                  ),
                  const SizedBox(height: AppDimensions.s20),
                  AppButton.primary(
                    label: 'Save & Select Patient',
                    onPressed: () {
                      if (firstCtrl.text.trim().isNotEmpty && lastCtrl.text.trim().isNotEmpty) {
                        final newPatient = Patient(
                          id: 'PAT-${DateTime.now().millisecondsSinceEpoch}',
                          firstName: firstCtrl.text.trim(),
                          lastName: lastCtrl.text.trim(),
                          dossierId: dossierCtrl.text.trim(),
                          allergies: const [],
                        );
                        Navigator.of(modalCtx).pop();
                        context.read<UsageBloc>().add(UsagePatientSelectedEvent(newPatient));
                      }
                    },
                  ),
                ],
              ),
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
        title: const Text('Select Patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<UsageBloc, UsageState>(
          builder: (context, state) {
            final selectedPatient = state.selectedPatient;
            final patients = state.patients.where((p) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return p.fullName.toLowerCase().contains(q) || p.dossierId.toLowerCase().contains(q);
            }).toList();

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Column(
                        children: [
                          // Top Patient Search Bar & Summary
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.screenPadding,
                              AppDimensions.s12,
                              AppDimensions.screenPadding,
                              AppDimensions.s12,
                            ),
                            child: PatientSearchBar(
                              onSearch: (q) => setState(() => _searchQuery = q),
                              onClear: () => setState(() => _searchQuery = ''),
                            ),
                          ),

                          // Patients List Area
                          Expanded(
                            child: state.status == UsageFormStatus.loadingPatients
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  )
                                : patients.isEmpty
                                    ? AppEmptyState(
                                        title: 'No Patient Found',
                                        message: 'No patient matches "$_searchQuery". Create a new patient profile below.',
                                        buttonLabel: 'Register New Patient',
                                        onAction: _onAddNewPatientQuickModal,
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDimensions.screenPadding,
                                          vertical: AppDimensions.s8,
                                        ),
                                        itemCount: patients.length,
                                        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.s12),
                                        itemBuilder: (context, index) {
                                          final p = patients[index];
                                          final isSelected = selectedPatient?.id == p.id;
                                          return PatientListItem(
                                            patient: p,
                                            isSelected: isSelected,
                                            onTap: () {
                                              context.read<UsageBloc>().add(UsagePatientSelectedEvent(p));
                                            },
                                          );
                                        },
                                      ),
                          ),

                          // Quick Register Patient Ghost
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                            child: AppButton.ghost(
                              label: '+ Register New Patient',
                              onPressed: _onAddNewPatientQuickModal,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Continue CTA
                Container(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  decoration: const BoxDecoration(
                    color: AppColors.elevated,
                    border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: AppButton.primary(
                        label: selectedPatient != null
                            ? 'Continue with ${selectedPatient.firstName} ${selectedPatient.lastName}'
                            : 'Select a Patient to Continue',
                        onPressed: selectedPatient != null
                            ? () {
                                context.push(
                                  '/usage/confirm',
                                  extra: {
                                    'label': widget.label,
                                    'patient': selectedPatient,
                                  },
                                );
                              }
                            : null,
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
      create: (_) => sl<UsageBloc>()..add(const UsageLoadPatientsRequested()),
      child: body,
    );
  }
}
