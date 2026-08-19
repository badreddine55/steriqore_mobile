import 'package:equatable/equatable.dart';

class RegisterRequestModel extends Equatable {
  final String name;
  final String email;
  final String? phone;
  final String cabinetCode;
  final String password;
  final String confirmPassword;
  final String role;

  const RegisterRequestModel({
    required this.name,
    required this.email,
    this.phone,
    required this.cabinetCode,
    required this.password,
    required this.confirmPassword,
    this.role = 'practitioner',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'cabinet_code': cabinetCode,
      'practice_code': cabinetCode,
      'password': password,
      'password_confirmation': confirmPassword,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        cabinetCode,
        password,
        confirmPassword,
        role,
      ];
}
