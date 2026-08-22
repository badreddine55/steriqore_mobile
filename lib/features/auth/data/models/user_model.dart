import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.codeId,
    required super.name,
    required super.email,
    super.role = 'practitioner',
    super.cabinetId,
    super.cabinetName,
    super.cabinetRoom,
    super.permissions = const [],
    super.avatarUrl,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 1;
    if (json['id'] is int) {
      parsedId = json['id'] as int;
    } else if (json['id'] != null) {
      final digits = json['id'].toString().replaceAll(RegExp(r'\D'), '');
      parsedId = int.tryParse(digits) ?? 1;
    }

    final rawPermissions = json['permissions'];
    List<String> parsedPermissions = [];
    if (rawPermissions is List) {
      parsedPermissions = rawPermissions.map((e) => e.toString()).toList();
    }

    final rawRole = json['role']?.toString().toLowerCase().trim();
    final bool isAdminFlag = json['is_admin'] == true || json['is_admin'] == 1 || json['isAdmin'] == true;
    final String emailStr = (json['email'] as String? ?? '').toLowerCase();
    final String nameStr = (json['name'] as String? ?? '').toLowerCase();

    String parsedRole = 'practitioner';
    if (rawRole != null && rawRole.isNotEmpty && rawRole != 'null') {
      if (rawRole == 'admin' || rawRole == 'administrator' || rawRole == 'administrateur') {
        parsedRole = 'admin';
      } else if (rawRole == 'assistant' || rawRole == 'assistante' || rawRole == 'stock_manager') {
        parsedRole = 'assistant';
      } else {
        parsedRole = rawRole;
      }
    } else if (isAdminFlag || emailStr.contains('admin') || nameStr.contains('administrator') || nameStr.contains('administrateur')) {
      parsedRole = 'admin';
    }

    return UserModel(
      id: parsedId,
      codeId: json['id']?.toString() ?? json['code_id']?.toString(),
      name: json['name'] as String? ?? (parsedRole == 'admin' ? 'Administrator' : 'Practitioner'),
      email: json['email'] as String? ?? '',
      role: parsedRole,
      cabinetId: json['cabinet_id']?.toString(),
      cabinetName: json['cabinet_name'] as String? ?? json['practice_name'] as String?,
      cabinetRoom: json['cabinet_room'] as String? ?? json['room'] as String? ?? (parsedRole == 'admin' ? 'Direction' : 'Fauteuil 1'),
      permissions: parsedPermissions,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code_id': codeId,
      'name': name,
      'email': email,
      'role': role,
      'cabinet_id': cabinetId,
      'cabinet_name': cabinetName,
      'cabinet_room': cabinetRoom,
      'permissions': permissions,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
    };
  }

  User toEntity() {
    return User(
      id: id,
      codeId: codeId,
      name: name,
      email: email,
      role: role,
      cabinetId: cabinetId,
      cabinetName: cabinetName,
      cabinetRoom: cabinetRoom,
      permissions: permissions,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
