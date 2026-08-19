import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/steriqore_shared.dart';
import '../models/patient_model.dart';
import '../repositories/patient_repository.dart';

/// Searchable Patient Picker widget with clinical allergy and room tags
class PatientPicker extends StatefulWidget {
  final PatientModel? selectedPatient;
  final ValueChanged<PatientModel> onPatientSelected;
  final VoidCallback? onClear;
  final PatientRepository? patientRepository;

  const PatientPicker({
    super.key,
    required this.selectedPatient,
    required this.onPatientSelected,
    this.onClear,
    this.patientRepository,
  });

  @override
  State<PatientPicker> createState() => _PatientPickerState();
}

class _PatientPickerState extends State<PatientPicker> {
  late final PatientRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = widget.patientRepository ?? PatientRepository();
  }

  void _showPatientSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PatientSearchSheet(
        repository: _repo,
        onSelected: (patient) {
          Navigator.of(context).pop();
          widget.onPatientSelected(patient);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.selectedPatient;

    if (patient == null) {
      return GestureDetector(
        onTap: _showPatientSearchModal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDefault,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderStrong,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_search_rounded, size: 22, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Patient (Mandatory)',
                      style: steriqoreFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to search chart ID or patient name',
                      style: steriqoreFont(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
    }

    // Selected Patient Display Card
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
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
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : 'P',
                  style: steriqoreFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: steriqoreFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Dossier: ${patient.identifier}',
                      style: steriqoreFont(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.change_circle_outlined, color: AppColors.accent, size: 22),
                tooltip: 'Change Patient',
                onPressed: _showPatientSearchModal,
              ),
            ],
          ),
          if (patient.allergies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: patient.allergies.map((allergy) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        'Allergy: $allergy',
                        style: steriqoreFont(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PatientSearchSheet extends StatefulWidget {
  final PatientRepository repository;
  final ValueChanged<PatientModel> onSelected;

  const _PatientSearchSheet({
    required this.repository,
    required this.onSelected,
  });

  @override
  State<_PatientSearchSheet> createState() => _PatientSearchSheetState();
}

class _PatientSearchSheetState extends State<_PatientSearchSheet> {
  final _searchController = TextEditingController();
  List<PatientModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients([String? query]) async {
    setState(() => _isLoading = true);
    try {
      final list = await widget.repository.getPatients(query: query);
      if (mounted) {
        setState(() {
          _patients = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Patient',
                    style: steriqoreFont(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => _loadPatients(val),
                style: steriqoreFont(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search by patient name or dossier #...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _loadPatients();
                          },
                        )
                      : null,
                ),
              ),
            ),

            const Divider(color: AppColors.borderSubtle, height: 1),

            // Patients List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : _patients.isEmpty
                      ? Center(
                          child: Text(
                            'No patients found matching query',
                            style: steriqoreFont(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _patients.length,
                          separatorBuilder: (context, index) => const Divider(color: AppColors.borderSubtle, height: 1),
                          itemBuilder: (context, index) {
                            final p = _patients[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  p.firstName.isNotEmpty ? p.firstName[0].toUpperCase() : 'P',
                                  style: steriqoreFont(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                p.fullName,
                                style: steriqoreFont(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Dossier ${p.identifier}${p.cabinetRoom != null ? ' · ${p.cabinetRoom}' : ''}',
                                style: steriqoreFont(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
                              onTap: () => widget.onSelected(p),
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
