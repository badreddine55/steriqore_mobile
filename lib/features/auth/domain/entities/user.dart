import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? cabinetName;
  final String? cabinetRoom;
  final String? avatarUrl;
  final String? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'practitioner',
    this.cabinetName,
    this.cabinetRoom,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isPractitioner => role.toLowerCase() == 'practitioner' || role.toLowerCase() == 'praticien';

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        cabinetName,
        cabinetRoom,
        avatarUrl,
        createdAt,
      ];
}
