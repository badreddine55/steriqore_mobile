import 'package:equatable/equatable.dart';
import '../../domain/entities/cabinet_user.dart';

enum AdminUsersStatus { initial, loading, loaded, creating, updating, error, actionSuccess }

class AdminUsersState extends Equatable {
  final AdminUsersStatus status;
  final List<CabinetUser> users;
  final String searchQuery;
  final String activeRoleFilter; // 'all', 'practitioner', 'assistant', 'admin'
  final String? errorMessage;
  final String? successMessage;
  final CabinetUser? lastModifiedUser;

  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.searchQuery = '',
    this.activeRoleFilter = 'all',
    this.errorMessage,
    this.successMessage,
    this.lastModifiedUser,
  });

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<CabinetUser>? users,
    String? searchQuery,
    String? activeRoleFilter,
    String? errorMessage,
    String? successMessage,
    CabinetUser? lastModifiedUser,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      activeRoleFilter: activeRoleFilter ?? this.activeRoleFilter,
      errorMessage: errorMessage,
      successMessage: successMessage,
      lastModifiedUser: lastModifiedUser ?? this.lastModifiedUser,
    );
  }

  List<CabinetUser> get filteredUsers {
    return users.where((u) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final match = u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            (u.phone?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (activeRoleFilter != 'all') {
        if (u.role.toLowerCase() != activeRoleFilter.toLowerCase()) return false;
      }
      return true;
    }).toList();
  }

  int get totalCount => users.length;
  int get activeCount => users.where((u) => u.isActive).length;
  int get practitionerCount => users.where((u) => u.isPractitioner).length;
  int get assistantCount => users.where((u) => u.isAssistant).length;
  int get adminCount => users.where((u) => u.isAdmin).length;

  @override
  List<Object?> get props => [
        status,
        users,
        searchQuery,
        activeRoleFilter,
        errorMessage,
        successMessage,
        lastModifiedUser,
      ];
}
