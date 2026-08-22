import 'package:equatable/equatable.dart';

class CabinetUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'admin', 'assistant', 'practitioner'
  final bool isActive;
  final String? cabinetName;
  final String? cabinetRoom;
  final String? avatarUrl;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final List<String> permissions;

  const CabinetUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.isActive = true,
    this.cabinetName,
    this.cabinetRoom,
    this.avatarUrl,
    this.lastLoginAt,
    this.createdAt,
    this.permissions = const [],
  });

  bool get isAdmin => role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrateur';
  bool get isPractitioner => role.toLowerCase() == 'practitioner' || role.toLowerCase() == 'praticien';
  bool get isAssistant => role.toLowerCase() == 'assistant' || role.toLowerCase() == 'stock_manager';

  String get roleDisplayName {
    if (isAdmin) return 'Administrator';
    if (isAssistant) return 'Stock Manager';
    return 'Practitioner';
  }

  CabinetUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    String? cabinetName,
    String? cabinetRoom,
    String? avatarUrl,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    List<String>? permissions,
  }) {
    return CabinetUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      cabinetName: cabinetName ?? this.cabinetName,
      cabinetRoom: cabinetRoom ?? this.cabinetRoom,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        isActive,
        cabinetName,
        cabinetRoom,
        avatarUrl,
        lastLoginAt,
        createdAt,
        permissions,
      ];
}
