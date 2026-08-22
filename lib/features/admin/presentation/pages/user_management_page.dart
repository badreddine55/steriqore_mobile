import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';
import '../widgets/user_list_item.dart';
import '../../../../shared/widgets/role_based_bottom_nav.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminUsersBloc>().add(const AdminLoadUsersRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<AdminUsersBloc>().add(AdminSearchUsersQueryChanged(query));
  }

  void _onRoleFilterChanged(String role) {
    setState(() => _selectedRole = role);
    context.read<AdminUsersBloc>().add(AdminRoleFilterChanged(role));
  }

  @override
  Widget build(BuildContext context) {
    final roleFilters = [
      ('all', 'All Staff'),
      ('practitioner', 'Practitioners'),
      ('assistant', 'Stock Managers'),
      ('admin', 'Administrators'),
    ];

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('User Management', style: AdminTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AdminColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<AdminUsersBloc>().add(const AdminRefreshUsersRequested());
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: AdminColors.primaryInverse,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Add User', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              onPressed: () {
                if (GoRouter.maybeOf(context) != null) {
                  context.push('/admin/users/create');
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter header container
            Container(
              color: AdminColors.surfaceElevated,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                children: [
                  // Search field (40px, #F1F5F9)
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: AdminTypography.body,
                      decoration: InputDecoration(
                        hintText: 'Search by staff name, email, or chair...',
                        hintStyle: AdminTypography.bodySmall.copyWith(color: AdminColors.textTertiary),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AdminColors.textTertiary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16, color: AdminColors.textTertiary),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: AdminColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AdminColors.borderStrong),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role horizontal filter chips (32px, 6px radius - STERIQORE_ADMIN_DESIGN_SYSTEM.md)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: roleFilters.map((rf) {
                        final isSelected = _selectedRole == rf.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _onRoleFilterChanged(rf.$1),
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AdminColors.primary : AdminColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? AdminColors.primary : AdminColors.borderSubtle,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                rf.$2,
                                style: AdminTypography.caption.copyWith(
                                  color: isSelected ? AdminColors.primaryInverse : AdminColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(color: AdminColors.borderSubtle, height: 1),

            // Users List Content
            Expanded(
              child: BlocConsumer<AdminUsersBloc, AdminUsersState>(
                listener: (context, state) {
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
                  if (state.status == AdminUsersStatus.loading && state.users.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AdminColors.accent),
                    );
                  }

                  final displayUsers = state.filteredUsers;

                  if (displayUsers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_outline_rounded,
                              size: 48,
                              color: AdminColors.borderStrong, // Simple line icon, NO illustration
                            ),
                            const SizedBox(height: 16),
                            const Text('No Staff Members Found', style: AdminTypography.h4),
                            const SizedBox(height: 6),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No users match "${_searchController.text}". Try another query.'
                                  : 'No staff accounts registered in this category.',
                              textAlign: TextAlign.center,
                              style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primary,
                                  foregroundColor: AdminColors.primaryInverse,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.person_add_rounded, size: 16),
                                label: const Text('Add Staff Member', style: AdminTypography.button),
                                onPressed: () => context.push('/admin/users/create'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AdminColors.accent,
                    onRefresh: () async {
                      context.read<AdminUsersBloc>().add(const AdminRefreshUsersRequested());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                      itemCount: displayUsers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = displayUsers[index];
                        return UserListItem(
                          user: user,
                          onTap: () => context.push('/admin/users/${user.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AdminColors.primary,
        foregroundColor: AdminColors.primaryInverse,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Squared authority (NOT circle)
        ),
        onPressed: () => context.push('/admin/users/create'),
        tooltip: 'Add Staff Member',
        child: const Icon(Icons.person_add_rounded, size: 24),
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentRoute: '/admin/users'),
    );
  }
}
