import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String? codeId;
  final String name;
  final String email;
  final String role;
  final String? cabinetId;
  final String? cabinetName;
  final String? cabinetRoom;
  final List<String> permissions;
  final String? avatarUrl;
  final String? createdAt;

  const User({
    required this.id,
    this.codeId,
    required this.name,
    required this.email,
    this.role = 'practitioner',
    this.cabinetId,
    this.cabinetName,
    this.cabinetRoom,
    this.permissions = const [],
    this.avatarUrl,
    this.createdAt,
  });

  bool get isPractitioner {
    final r = role.toLowerCase().trim();
    return r == 'practitioner' || r == 'praticien' || r == 'doctor' || r == 'dentist';
  }

  bool get isAdmin {
    final r = role.toLowerCase().trim();
    return r == 'admin' || r == 'administrator' || r == 'administrateur';
  }

  bool get isAssistant {
    final r = role.toLowerCase().trim();
    return r == 'assistant' || r == 'assistante' || r == 'stock_manager' || r == 'aide_soignant';
  }

  // Computed getters for RBAC route and action gating
  bool get canAccessAdmin => isAdmin;
  bool get canAccessStock => isAdmin || isAssistant;
  bool get canAccessCycles => isAdmin || isAssistant;
  bool get canAccessScanner => isAdmin || isAssistant || isPractitioner;
  bool get canAccessUsage => isAdmin || isAssistant || isPractitioner;
  bool get canAccessHistory => isAdmin || isAssistant || isPractitioner;
  bool get canAccessProfile => true;

  @override
  List<Object?> get props => [
        id,
        codeId,
        name,
        email,
        role,
        cabinetId,
        cabinetName,
        cabinetRoom,
        permissions,
        avatarUrl,
        createdAt,
      ];
}
