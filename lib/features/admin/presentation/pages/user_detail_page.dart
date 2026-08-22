import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/cabinet_user.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';
import '../widgets/role_badge.dart';
import '../widgets/user_status_toggle.dart';

class UserDetailPage extends StatefulWidget {
  final int userId;
  final CabinetUser? initialUser;

  const UserDetailPage({
    super.key,
    required this.userId,
    this.initialUser,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _roomController;

  String _selectedRole = 'practitioner';
  bool _isActive = true;
  CabinetUser? _user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _roomController = TextEditingController();

    if (widget.initialUser != null) {
      _populateUser(widget.initialUser!);
    }
  }

  void _populateUser(CabinetUser user) {
    if (_user == null || _user!.id != user.id) {
      _user = user;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _roomController.text = user.cabinetRoom ?? '';
      _selectedRole = user.role;
      _isActive = user.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _onToggleStatus(bool newValue) {
    setState(() => _isActive = newValue);
    context.read<AdminUsersBloc>().add(
      AdminToggleUserStatusRequested(id: widget.userId, isActive: newValue),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AdminUsersBloc>().add(
        AdminUpdateUserSubmitted(
          id: widget.userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          role: _selectedRole,
          cabinetRoom: _roomController.text.trim().isNotEmpty ? _roomController.text.trim() : null,
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
        title: const Text('Staff Profile & Rights', style: AdminTypography.h3),
      ),
      body: BlocConsumer<AdminUsersBloc, AdminUsersState>(
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
          final user = state.users.where((u) => u.id == widget.userId).firstOrNull;

          if (user == null && state.status == AdminUsersStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AdminColors.accent));
          }

          if (user != null) {
            _populateUser(user);
          }

          final isLoading = state.status == AdminUsersStatus.loading;

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
                        // User Summary Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AdminColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: _isActive ? AdminColors.primary : AdminColors.surfaceMuted,
                                child: Text(
                                  _user != null && _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _isActive ? AdminColors.primaryInverse : AdminColors.textTertiary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_nameController.text, style: AdminTypography.h3),
                                    const SizedBox(height: 2),
                                    Text(
                                      _emailController.text,
                                      style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        RoleBadge(role: _selectedRole, isLarge: true),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ID #USR-${widget.userId}',
                                          style: AdminTypography.mono.copyWith(
                                            fontSize: 11,
                                            color: AdminColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status Toggle (Soft Delete)
                        UserStatusToggle(
                          isActive: _isActive,
                          onChanged: _onToggleStatus,
                        ),
                        const SizedBox(height: 24),

                        // Section: Role & Authority
                        Text('ASSIGNED ROLE', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AdminColors.borderSubtle),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AdminColors.textSecondary),
                              items: const [
                                DropdownMenuItem(
                                  value: 'practitioner',
                                  child: Text('Practitioner (Clinical Recording & Scanning)', style: AdminTypography.body),
                                ),
                                DropdownMenuItem(
                                  value: 'assistant',
                                  child: Text('Stock Manager / Assistant (Sterilization Cycles)', style: AdminTypography.body),
                                ),
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('Administrator (Full Cabinet Supervision)', style: AdminTypography.body),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedRole = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section: Edit Info
                        Text('ACCOUNT PROFILE', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),

                        Text('Full Name *', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
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

                        Text('Login Email *', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
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
                          validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                        ),
                        const SizedBox(height: 16),

                        Text('Phone Number', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
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
                        const SizedBox(height: 16),

                        Text('Assigned Station or Chair', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _roomController,
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

                        // Account Metadata card
                        if (_user != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AdminColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AdminColors.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AUDIT & METADATA', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Account Created', style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary)),
                                    Text(
                                      _user!.createdAt != null ? DateFormatter.formatDate(_user!.createdAt!) : 'N/A',
                                      style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Last Session', style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary)),
                                    Text(
                                      _user!.lastLoginAt != null ? DateFormatter.formatDateTime(_user!.lastLoginAt!) : 'Never logged in',
                                      style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

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
                            onPressed: isLoading ? null : _saveChanges,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AdminColors.primaryInverse,
                                    ),
                                  )
                                : const Text('Save Changes', style: AdminTypography.buttonLarge),
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
    );
  }
}
