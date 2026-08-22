import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/core/errors/failures.dart';
import 'package:steriqore_mobile/features/admin/domain/entities/audit_entry.dart';
import 'package:steriqore_mobile/features/admin/domain/entities/cabinet_settings.dart';
import 'package:steriqore_mobile/features/admin/domain/entities/cabinet_user.dart';
import 'package:steriqore_mobile/features/admin/domain/repositories/admin_repository.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/create_cabinet_user.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/get_cabinet_users.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/toggle_user_status.dart';
import 'package:steriqore_mobile/features/admin/domain/usecases/update_cabinet_user.dart';
import 'package:steriqore_mobile/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:steriqore_mobile/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:steriqore_mobile/features/admin/presentation/bloc/admin_users_state.dart';

class FakeAdminRepository implements AdminRepository {
  List<CabinetUser> users = [
    const CabinetUser(
      id: 1,
      name: 'Dr. Sarah Martin',
      email: 'sarah.martin@cabinet.fr',
      role: 'admin',
      isActive: true,
    ),
    const CabinetUser(
      id: 2,
      name: 'Dr. Julien Dubois',
      email: 'julien.dubois@cabinet.fr',
      role: 'practitioner',
      isActive: true,
    ),
  ];

  @override
  Future<Either<Failure, List<CabinetUser>>> getUsers({String? search, String? role, bool? isActive}) async {
    return Right(users);
  }

  @override
  Future<Either<Failure, CabinetUser>> getUserById(int id) async {
    return Right(users.firstWhere((u) => u.id == id, orElse: () => users.first));
  }

  @override
  Future<Either<Failure, CabinetUser>> createUser({
    required String name,
    required String email,
    String? phone,
    required String role,
    required String password,
    String? cabinetRoom,
    List<String>? permissions,
  }) async {
    final newUser = CabinetUser(
      id: users.length + 1,
      name: name,
      email: email,
      phone: phone,
      role: role,
      cabinetRoom: cabinetRoom,
      permissions: permissions ?? const [],
    );
    users.insert(0, newUser);
    return Right(newUser);
  }

  @override
  Future<Either<Failure, CabinetUser>> updateUser(int id, {String? name, String? email, String? phone, String? role, String? cabinetRoom, List<String>? permissions}) async {
    final idx = users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final updated = users[idx].copyWith(name: name, email: email, phone: phone, role: role, cabinetRoom: cabinetRoom, permissions: permissions);
      users[idx] = updated;
      return Right(updated);
    }
    return const Left(ServerFailure('User not found'));
  }

  @override
  Future<Either<Failure, CabinetUser>> toggleUserStatus(int id, bool isActive) async {
    final idx = users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final updated = users[idx].copyWith(isActive: isActive);
      users[idx] = updated;
      return Right(updated);
    }
    return const Left(ServerFailure('User not found'));
  }

  @override
  Future<Either<Failure, List<AuditEntry>>> getAuditTrail({String? search, String? action, int? userId, DateTime? startDate, DateTime? endDate}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, CabinetSettings>> getCabinetSettings() async {
    return const Right(CabinetSettings(id: 1, cabinetName: 'Cabinet Dentaire', cabinetCode: 'CAB-01'));
  }

  @override
  Future<Either<Failure, CabinetSettings>> updateCabinetSettings(CabinetSettings settings) async {
    return Right(settings);
  }
}

void main() {
  late FakeAdminRepository fakeRepo;
  late AdminUsersBloc bloc;

  setUp(() {
    fakeRepo = FakeAdminRepository();
    bloc = AdminUsersBloc(
      getCabinetUsersUseCase: GetCabinetUsersUseCase(fakeRepo),
      createCabinetUserUseCase: CreateCabinetUserUseCase(fakeRepo),
      updateCabinetUserUseCase: UpdateCabinetUserUseCase(fakeRepo),
      toggleUserStatusUseCase: ToggleUserStatusUseCase(fakeRepo),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state has AdminUsersStatus.initial', () {
    expect(bloc.state.status, AdminUsersStatus.initial);
    expect(bloc.state.users, isEmpty);
  });

  test('emits [loading, loaded] when AdminLoadUsersRequested succeeds', () async {
    expectLater(
      bloc.stream,
      emitsInOrder([
        const AdminUsersState(status: AdminUsersStatus.loading),
        predicate<AdminUsersState>((s) => s.status == AdminUsersStatus.loaded && s.users.length == 2),
      ]),
    );

    bloc.add(const AdminLoadUsersRequested());
  });

  test('filters users by search query and role', () {
    final state = AdminUsersState(
      status: AdminUsersStatus.loaded,
      users: fakeRepo.users,
      searchQuery: 'julien',
      activeRoleFilter: 'practitioner',
    );

    expect(state.filteredUsers.length, 1);
    expect(state.filteredUsers.first.name, 'Dr. Julien Dubois');
    expect(state.practitionerCount, 1);
    expect(state.adminCount, 1);
  });

  test('emits [creating, actionSuccess] when AdminCreateUserSubmitted succeeds', () async {
    bloc.add(const AdminCreateUserSubmitted(
      name: 'Dr. Anna Dupont',
      email: 'anna@cabinet.fr',
      role: 'practitioner',
      password: 'Password123!',
    ));

    await expectLater(
      bloc.stream,
      emitsThrough(predicate<AdminUsersState>((s) =>
          s.status == AdminUsersStatus.actionSuccess &&
          s.users.any((u) => u.name == 'Dr. Anna Dupont'))),
    );
  });
}
