import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../domain/entities/cabinet_settings.dart';
import '../bloc/admin_settings_bloc.dart';
import '../bloc/admin_settings_event.dart';
import '../bloc/admin_settings_state.dart';
import '../../../../shared/widgets/role_based_bottom_nav.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cabinetNameController;
  late TextEditingController _cabinetCodeController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _autoclaveController;

  int _dlcThresholdDays = 30;
  int _lowStockThreshold = 5;
  bool _enableBiometrics = true;
  bool _autoSyncEnabled = true;
  CabinetSettings? _loadedSettings;

  @override
  void initState() {
    super.initState();
    _cabinetNameController = TextEditingController();
    _cabinetCodeController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _autoclaveController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminSettingsBloc>().add(const AdminLoadSettingsRequested());
      }
    });
  }

  void _populate(CabinetSettings settings) {
    if (_loadedSettings == null || _loadedSettings != settings) {
      _loadedSettings = settings;
      _cabinetNameController.text = settings.cabinetName;
      _cabinetCodeController.text = settings.cabinetCode;
      _addressController.text = settings.address ?? '';
      _phoneController.text = settings.phone ?? '';
      _emailController.text = settings.email ?? '';
      _autoclaveController.text = settings.primaryAutoclaveId ?? '';
      _dlcThresholdDays = settings.dlcThresholdDays;
      _lowStockThreshold = settings.lowStockThreshold;
      _enableBiometrics = settings.enableBiometrics;
      _autoSyncEnabled = settings.autoSyncEnabled;
    }
  }

  @override
  void dispose() {
    _cabinetNameController.dispose();
    _cabinetCodeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _autoclaveController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      final current = _loadedSettings ?? const CabinetSettings(id: 1, cabinetName: '', cabinetCode: '');
      context.read<AdminSettingsBloc>().add(
        AdminUpdateSettingsSubmitted(
          current.copyWith(
            cabinetName: _cabinetNameController.text.trim(),
            cabinetCode: _cabinetCodeController.text.trim(),
            address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
            phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
            email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
            dlcThresholdDays: _dlcThresholdDays,
            lowStockThreshold: _lowStockThreshold,
            enableBiometrics: _enableBiometrics,
            autoSyncEnabled: _autoSyncEnabled,
            primaryAutoclaveId: _autoclaveController.text.trim().isNotEmpty ? _autoclaveController.text.trim() : null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Practice & Safety Settings', style: AdminTypography.h3),
      ),
      body: BlocConsumer<AdminSettingsBloc, AdminSettingsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AdminColors.primaryInverse, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.successMessage!)),
                  ],
                ),
                backgroundColor: AdminColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AdminColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.settings != null) {
            _populate(state.settings!);
          }

          final isLoading = state.status == AdminSettingsStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 1: Cabinet Identity
                        Text('CABINET IDENTIFICATION', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),

                        Text('Cabinet Name *', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _cabinetNameController,
                          style: AdminTypography.body,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AdminColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.accent, width: 1.5),
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),

                        Text('Cabinet Code / Tenant ID *', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _cabinetCodeController,
                          style: AdminTypography.mono,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AdminColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.accent, width: 1.5),
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Cabinet code required' : null,
                        ),
                        const SizedBox(height: 16),

                        Text('Physical Address', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _addressController,
                          style: AdminTypography.body,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AdminColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AdminColors.accent, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 2: Sterilization Safety Parameters
                        Text('STERILIZATION & COMPLIANCE THRESHOLDS', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('DLC Alert Threshold (Days)', style: AdminTypography.h4),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Warns practitioner before instrument bag expiration',
                                          style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AdminColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$_dlcThresholdDays d',
                                      style: AdminTypography.mono.copyWith(
                                        color: AdminColors.primaryInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _dlcThresholdDays.toDouble(),
                                min: 7,
                                max: 90,
                                divisions: 83,
                                activeColor: AdminColors.accent,
                                inactiveColor: AdminColors.surfaceMuted,
                                onChanged: (v) => setState(() => _dlcThresholdDays = v.round()),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Low Stock Warning Level', style: AdminTypography.h4),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Minimum serialized units before replenishment notification',
                                          style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AdminColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$_lowStockThreshold pcs',
                                      style: AdminTypography.mono.copyWith(
                                        color: AdminColors.primaryInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _lowStockThreshold.toDouble(),
                                min: 1,
                                max: 30,
                                divisions: 29,
                                activeColor: AdminColors.accent,
                                inactiveColor: AdminColors.surfaceMuted,
                                onChanged: (v) => setState(() => _lowStockThreshold = v.round()),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 3: Security & Sync Policies
                        Text('SECURITY & PROTOCOLS', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Biometric Authentication', style: AdminTypography.h4),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Allow FaceID/Fingerprint for instant clinical validation',
                                      style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _enableBiometrics,
                                activeTrackColor: AdminColors.accent,
                                onChanged: (v) => setState(() => _enableBiometrics = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Background Auto-Sync', style: AdminTypography.h4),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Automatically synchronizes offline batch scans with central server',
                                      style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _autoSyncEnabled,
                                activeTrackColor: AdminColors.accent,
                                onChanged: (v) => setState(() => _autoSyncEnabled = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Save Button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primary,
                              foregroundColor: AdminColors.primaryInverse,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // 8px radius
                              ),
                            ),
                            onPressed: isLoading ? null : _saveSettings,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AdminColors.primaryInverse,
                                    ),
                                  )
                                : const Text('Save Practice Settings', style: AdminTypography.buttonLarge),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentRoute: '/admin/settings'),
    );
  }
}
