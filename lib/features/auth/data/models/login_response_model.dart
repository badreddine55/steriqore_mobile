import 'user_model.dart';

class LoginResponseModel {
  final String token;
  final UserModel user;

  const LoginResponseModel({
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String? ?? json['access_token'] as String? ?? '';
    final userJson = json['user'] as Map<String, dynamic>? ?? json['data'] as Map<String, dynamic>? ?? json;

    return LoginResponseModel(
      token: token,
      user: UserModel.fromJson(userJson),
    );
  }
}
