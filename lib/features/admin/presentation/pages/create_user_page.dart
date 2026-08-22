import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'practitioner';
  bool _sendInviteEmail = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roomController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AdminUsersBloc>().add(
        AdminCreateUserSubmitted(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          role: _selectedRole,
          cabinetRoom: _roomController.text.trim().isNotEmpty ? _roomController.text.trim() : null,
          password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : 'Password123!',
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
          icon: const Icon(Icons.close_rounded, color: AdminColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Staff Member', style: AdminTypography.h3),
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
            context.pop();
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
          final isLoading = state.status == AdminUsersStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 1: Role Selection
                        Text('STAFF ROLE & AUTHORITY', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),

                        _RoleChoiceCard(
                          title: 'Practitioner',
                          subtitle: 'Can scan labels, record patient usages, and access chair history',
                          role: 'practitioner',
                          badgeColor: AdminColors.success,
                          isSelected: _selectedRole == 'practitioner',
                          onTap: () => setState(() => _selectedRole = 'practitioner'),
                        ),
                        const SizedBox(height: 10),

                        _RoleChoiceCard(
                          title: 'Stock Manager / Assistant',
                          subtitle: 'Can validate autoclave cycles, manage lots, print serialization labels',
                          role: 'assistant',
                          badgeColor: AdminColors.accent,
                          isSelected: _selectedRole == 'assistant',
                          onTap: () => setState(() => _selectedRole = 'assistant'),
                        ),
                        const SizedBox(height: 10),

                        _RoleChoiceCard(
                          title: 'Administrator',
                          subtitle: 'Full cabinet authority: create/disable users, review audit trails & settings',
                          role: 'admin',
                          badgeColor: AdminColors.primary,
                          isSelected: _selectedRole == 'admin',
                          onTap: () => setState(() => _selectedRole = 'admin'),
                        ),
                        const SizedBox(height: 24),

                        // Section 2: Account Details
                        Text('STAFF INFORMATION', style: AdminTypography.navLabel.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),

                        // Full Name
                        Text('Full Name *', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          style: AdminTypography.body,
                          decoration: InputDecoration(
                            hintText: 'e.g. Dr. Alexandre Bonnet',
                            hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
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
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Full name is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        Text('Login Email *', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AdminTypography.body,
                          decoration: InputDecoration(
                            hintText: 'e.g. alexandre.bonnet@cabinet.fr',
                            hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
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
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Email is required';
                            if (!val.contains('@')) return 'Please enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        Text('Mobile Phone', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: AdminTypography.body,
                          decoration: InputDecoration(
                            hintText: 'e.g. +33 6 12 34 56 78',
                            hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
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

                        // Room / Chair
                        Text('Assigned Room or Chair', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _roomController,
                          style: AdminTypography.body,
                          decoration: InputDecoration(
                            hintText: 'e.g. Fauteuil 1 - Parodontologie',
                            hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
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

                        // Temporary Password
                        Text('Initial Access Password', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: AdminTypography.body,
                          decoration: InputDecoration(
                            hintText: 'Default: Password123! (Change upon first login)',
                            hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
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

                        // Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _sendInviteEmail,
                                activeColor: AdminColors.accent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (v) => setState(() => _sendInviteEmail = v ?? true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Send invitation email with initial credentials to staff member',
                                style: AdminTypography.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
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
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AdminColors.primaryInverse,
                                    ),
                                  )
                                : const Text(
                                    'Create Account & Send Credentials',
                                    style: AdminTypography.buttonLarge,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
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

class _RoleChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String role;
  final Color badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChoiceCard({
    required this.title,
    required this.subtitle,
    required this.role,
    required this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AdminColors.surfaceMuted : AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12), // 12px radius
        border: Border.all(
          color: isSelected ? AdminColors.primary : AdminColors.borderSubtle,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AdminColors.primary : AdminColors.borderStrong,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AdminColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AdminTypography.h4.copyWith(
                                color: AdminColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AdminTypography.caption.copyWith(
                          color: AdminColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
