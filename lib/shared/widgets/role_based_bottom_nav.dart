import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/admin_colors.dart';
import '../../core/theme/admin_typography.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class BottomNavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class RoleBasedBottomNav extends StatelessWidget {
  final String? currentRoute;

  const RoleBasedBottomNav({
    super.key,
    this.currentRoute,
  });

  List<BottomNavItemData> _getNavItems(String role) {
    final roleLower = role.toLowerCase();
    if (roleLower == 'admin' || roleLower == 'administrateur') {
      return const [
        BottomNavItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: 'Dashboard',
          route: '/home',
        ),
        BottomNavItemData(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: 'Stock',
          route: '/stock',
        ),
        BottomNavItemData(
          icon: Icons.local_hospital_outlined,
          activeIcon: Icons.local_hospital_rounded,
          label: 'Cycles',
          route: '/cycles',
        ),
        BottomNavItemData(
          icon: Icons.people_outlined,
          activeIcon: Icons.people_rounded,
          label: 'Users',
          route: '/admin/users',
        ),
        BottomNavItemData(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
          label: 'Settings',
          route: '/admin/settings',
        ),
      ];
    } else if (roleLower == 'assistant' || roleLower == 'stock_manager') {
      return const [
        BottomNavItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: 'Dashboard',
          route: '/home',
        ),
        BottomNavItemData(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: 'Stock',
          route: '/stock',
        ),
        BottomNavItemData(
          icon: Icons.local_hospital_outlined,
          activeIcon: Icons.local_hospital_rounded,
          label: 'Cycles',
          route: '/cycles',
        ),
        BottomNavItemData(
          icon: Icons.qr_code_scanner_outlined,
          activeIcon: Icons.qr_code_scanner_rounded,
          label: 'Scan',
          route: '/scanner',
        ),
      ];
    } else {
      // Practitioner default
      return const [
        BottomNavItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: 'Home',
          route: '/home',
        ),
        BottomNavItemData(
          icon: Icons.qr_code_scanner_outlined,
          activeIcon: Icons.qr_code_scanner_rounded,
          label: 'Scan',
          route: '/scanner',
        ),
        BottomNavItemData(
          icon: Icons.history_outlined,
          activeIcon: Icons.history_rounded,
          label: 'History',
          route: '/history',
        ),
        BottomNavItemData(
          icon: Icons.person_outlined,
          activeIcon: Icons.person_rounded,
          label: 'Profile',
          route: '/profile',
        ),
      ];
    }
  }

  int _calculateSelectedIndex(List<BottomNavItemData> items, String current) {
    for (int i = 0; i < items.length; i++) {
      if (current == items[i].route || (items[i].route != '/home' && current.startsWith(items[i].route))) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    final role = user?.role ?? 'practitioner';
    final items = _getNavItems(role);

    if (items.isEmpty) return const SizedBox.shrink();

    String activePath = currentRoute ?? '/home';
    try {
      if (currentRoute == null && GoRouter.maybeOf(context) != null) {
        activePath = GoRouterState.of(context).matchedLocation;
      }
    } catch (_) {}

    final selectedIndex = _calculateSelectedIndex(items, activePath);

    return Container(
      decoration: const BoxDecoration(
        color: AdminColors.surfaceElevated,
        border: Border(
          top: BorderSide(color: AdminColors.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (activePath != item.route) {
                      if (GoRouter.maybeOf(context) != null) {
                        context.go(item.route);
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? AdminColors.primary : AdminColors.textTertiary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AdminTypography.navLabel.copyWith(
                          color: isSelected ? AdminColors.primary : AdminColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
