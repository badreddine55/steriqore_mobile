import '../../domain/entities/cabinet_user.dart';

class CabinetUserModel extends CabinetUser {
  const CabinetUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.role,
    super.isActive = true,
    super.cabinetName,
    super.cabinetRoom,
    super.avatarUrl,
    super.lastLoginAt,
    super.createdAt,
    super.permissions = const [],
  });

  factory CabinetUserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    List<String> parsePermissions(dynamic value) {
      if (value == null) return const [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return const [];
    }

    return CabinetUserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'practitioner',
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['is_active'] == 1 || json['status'] == 'active'),
      cabinetName: json['cabinet_name'] as String? ?? json['practice_name'] as String?,
      cabinetRoom: json['cabinet_room'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      lastLoginAt: parseDate(json['last_login_at']),
      createdAt: parseDate(json['created_at']),
      permissions: parsePermissions(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'cabinet_name': cabinetName,
      'cabinet_room': cabinetRoom,
      'avatar_url': avatarUrl,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'permissions': permissions,
    };
  }

  CabinetUser toEntity() {
    return CabinetUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      isActive: isActive,
      cabinetName: cabinetName,
      cabinetRoom: cabinetRoom,
      avatarUrl: avatarUrl,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
      permissions: permissions,
    );
  }
}
