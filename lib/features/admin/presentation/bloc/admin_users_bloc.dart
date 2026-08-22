import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_cabinet_user.dart';
import '../../domain/usecases/get_cabinet_users.dart';
import '../../domain/usecases/toggle_user_status.dart';
import '../../domain/usecases/update_cabinet_user.dart';
import 'admin_users_event.dart';
import 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final GetCabinetUsersUseCase getCabinetUsersUseCase;
  final CreateCabinetUserUseCase createCabinetUserUseCase;
  final UpdateCabinetUserUseCase updateCabinetUserUseCase;
  final ToggleUserStatusUseCase toggleUserStatusUseCase;

  AdminUsersBloc({
    required this.getCabinetUsersUseCase,
    required this.createCabinetUserUseCase,
    required this.updateCabinetUserUseCase,
    required this.toggleUserStatusUseCase,
  }) : super(const AdminUsersState()) {
    on<AdminLoadUsersRequested>(_onLoadUsers);
    on<AdminRefreshUsersRequested>(_onRefreshUsers);
    on<AdminSearchUsersQueryChanged>(_onSearchQueryChanged);
    on<AdminRoleFilterChanged>(_onRoleFilterChanged);
    on<AdminCreateUserSubmitted>(_onCreateUser);
    on<AdminUpdateUserSubmitted>(_onUpdateUser);
    on<AdminToggleUserStatusRequested>(_onToggleUserStatus);
  }

  Future<void> _onLoadUsers(
    AdminLoadUsersRequested event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(state.copyWith(status: AdminUsersStatus.loading));

    final result = await getCabinetUsersUseCase(GetCabinetUsersParams(
      search: event.search ?? state.searchQuery,
      role: event.role ?? (state.activeRoleFilter == 'all' ? null : state.activeRoleFilter),
      isActive: event.isActive,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminUsersStatus.error,
        errorMessage: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: AdminUsersStatus.loaded,
        users: users,
      )),
    );
  }

  Future<void> _onRefreshUsers(
    AdminRefreshUsersRequested event,
    Emitter<AdminUsersState> emit,
  ) async {
    final result = await getCabinetUsersUseCase(GetCabinetUsersParams(
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      role: state.activeRoleFilter != 'all' ? state.activeRoleFilter : null,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminUsersStatus.error,
        errorMessage: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: AdminUsersStatus.loaded,
        users: users,
      )),
    );
  }

  void _onSearchQueryChanged(
    AdminSearchUsersQueryChanged event,
    Emitter<AdminUsersState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onRoleFilterChanged(
    AdminRoleFilterChanged event,
    Emitter<AdminUsersState> emit,
  ) {
    emit(state.copyWith(activeRoleFilter: event.role));
  }

  Future<void> _onCreateUser(
    AdminCreateUserSubmitted event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(state.copyWith(status: AdminUsersStatus.creating));

    final result = await createCabinetUserUseCase(CreateCabinetUserParams(
      name: event.name,
      email: event.email,
      phone: event.phone,
      role: event.role,
      password: event.password,
      cabinetRoom: event.cabinetRoom,
      permissions: event.permissions,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminUsersStatus.error,
        errorMessage: failure.message,
      )),
      (newUser) {
        final updatedList = [newUser, ...state.users];
        emit(state.copyWith(
          status: AdminUsersStatus.actionSuccess,
          users: updatedList,
          lastModifiedUser: newUser,
          successMessage: 'User "${newUser.name}" created successfully. Credentials dispatched.',
        ));
      },
    );
  }

  Future<void> _onUpdateUser(
    AdminUpdateUserSubmitted event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(state.copyWith(status: AdminUsersStatus.updating));

    final result = await updateCabinetUserUseCase(UpdateCabinetUserParams(
      id: event.id,
      name: event.name,
      email: event.email,
      phone: event.phone,
      role: event.role,
      cabinetRoom: event.cabinetRoom,
      permissions: event.permissions,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminUsersStatus.error,
        errorMessage: failure.message,
      )),
      (updatedUser) {
        final updatedList = state.users.map((u) => u.id == updatedUser.id ? updatedUser : u).toList();
        emit(state.copyWith(
          status: AdminUsersStatus.actionSuccess,
          users: updatedList,
          lastModifiedUser: updatedUser,
          successMessage: 'User profile updated successfully.',
        ));
      },
    );
  }

  Future<void> _onToggleUserStatus(
    AdminToggleUserStatusRequested event,
    Emitter<AdminUsersState> emit,
  ) async {
    final result = await toggleUserStatusUseCase(ToggleUserStatusParams(
      id: event.id,
      isActive: event.isActive,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminUsersStatus.error,
        errorMessage: failure.message,
      )),
      (updatedUser) {
        final updatedList = state.users.map((u) => u.id == updatedUser.id ? updatedUser : u).toList();
        final actionText = event.isActive ? 'activated' : 'disabled (soft deleted)';
        emit(state.copyWith(
          status: AdminUsersStatus.actionSuccess,
          users: updatedList,
          lastModifiedUser: updatedUser,
          successMessage: 'User "${updatedUser.name}" $actionText.',
        ));
      },
    );
  }
}
