import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.role = 'practitioner',
    super.cabinetName,
    super.cabinetRoom,
    super.avatarUrl,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      name: json['name'] as String? ?? 'Practitioner',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'practitioner',
      cabinetName: json['cabinet_name'] as String? ?? json['practice_name'] as String?,
      cabinetRoom: json['cabinet_room'] as String? ?? 'Fauteuil 1',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'cabinet_name': cabinetName,
      'cabinet_room': cabinetRoom,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      cabinetName: cabinetName,
      cabinetRoom: cabinetRoom,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
