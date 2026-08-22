import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

class AdminLoadUsersRequested extends AdminUsersEvent {
  final String? search;
  final String? role;
  final bool? isActive;

  const AdminLoadUsersRequested({this.search, this.role, this.isActive});

  @override
  List<Object?> get props => [search, role, isActive];
}

class AdminRefreshUsersRequested extends AdminUsersEvent {
  const AdminRefreshUsersRequested();
}

class AdminSearchUsersQueryChanged extends AdminUsersEvent {
  final String query;
  const AdminSearchUsersQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class AdminRoleFilterChanged extends AdminUsersEvent {
  final String role; // 'all', 'practitioner', 'assistant', 'admin'
  const AdminRoleFilterChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class AdminCreateUserSubmitted extends AdminUsersEvent {
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String password;
  final String? cabinetRoom;
  final List<String>? permissions;

  const AdminCreateUserSubmitted({
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.password,
    this.cabinetRoom,
    this.permissions,
  });

  @override
  List<Object?> get props => [name, email, phone, role, password, cabinetRoom, permissions];
}

class AdminUpdateUserSubmitted extends AdminUsersEvent {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? cabinetRoom;
  final List<String>? permissions;

  const AdminUpdateUserSubmitted({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.cabinetRoom,
    this.permissions,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, cabinetRoom, permissions];
}

class AdminToggleUserStatusRequested extends AdminUsersEvent {
  final int id;
  final bool isActive;

  const AdminToggleUserStatusRequested({required this.id, required this.isActive});

  @override
  List<Object?> get props => [id, isActive];
}
