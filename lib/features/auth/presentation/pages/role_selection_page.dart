import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/role_selection_card.dart';

class RoleSelectionPage extends StatefulWidget {
  final AuthBloc? authBloc;
  final ValueChanged<String>? onRoleSelected;

  const RoleSelectionPage({
    super.key,
    this.authBloc,
    this.onRoleSelected,
  });

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;

  void _handleSelectRole(String role) {
    setState(() {
      _selectedRole = role;
    });

    if (widget.onRoleSelected != null) {
      widget.onRoleSelected!(role);
    }

    final bloc = widget.authBloc ?? context.read<AuthBloc>();
    bloc.add(AuthRoleSelected(role));

    try {
      context.go('/home');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: statusBarHeight + 32),

              // Title
              Text('Select your role', style: AppTypography.h1),
              const SizedBox(height: AppDimensions.s8),

              // Subtitle
              Text(
                'Choose how you will use STERIQORE',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Role Card 1: Administrator
              RoleSelectionCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Administrator',
                subtitle: 'Manage users, settings, and supervision',
                isSelected: _selectedRole == 'admin',
                onTap: () => _handleSelectRole('admin'),
              ),
              const SizedBox(height: AppDimensions.s16),

              // Role Card 2: Stock Manager
              RoleSelectionCard(
                icon: Icons.inventory_2_outlined,
                title: 'Stock Manager',
                subtitle: 'Products, orders, lots, and sterilization',
                isSelected: _selectedRole == 'assistant' || _selectedRole == 'stock_manager',
                onTap: () => _handleSelectRole('assistant'),
              ),
              const SizedBox(height: AppDimensions.s16),

              // Role Card 3: Practitioner
              RoleSelectionCard(
                icon: Icons.medical_services_outlined,
                title: 'Practitioner',
                subtitle: 'Scan instruments and record usage',
                isSelected: _selectedRole == 'practitioner',
                onTap: () => _handleSelectRole('practitioner'),
              ),
              const SizedBox(height: AppDimensions.s32),
            ],
          ),
        ),
      ),
    );
  }
}
