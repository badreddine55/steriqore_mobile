import 'user_model.dart';

class LoginResponseModel {
  final String token;
  final UserModel user;

  const LoginResponseModel({
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    String token = '';
    if (json['token'] != null && json['token'].toString().isNotEmpty) {
      token = json['token'].toString();
    } else if (json['access_token'] != null && json['access_token'].toString().isNotEmpty) {
      token = json['access_token'].toString();
    } else if (json['plainTextToken'] != null && json['plainTextToken'].toString().isNotEmpty) {
      token = json['plainTextToken'].toString();
    } else if (rawData['token'] != null && rawData['token'].toString().isNotEmpty) {
      token = rawData['token'].toString();
    } else if (rawData['access_token'] != null && rawData['access_token'].toString().isNotEmpty) {
      token = rawData['access_token'].toString();
    } else if (rawData['plainTextToken'] != null && rawData['plainTextToken'].toString().isNotEmpty) {
      token = rawData['plainTextToken'].toString();
    }

    Map<String, dynamic> userJson = <String, dynamic>{};
    if (json['user'] is Map<String, dynamic>) {
      userJson = json['user'] as Map<String, dynamic>;
    } else if (rawData['user'] is Map<String, dynamic>) {
      userJson = rawData['user'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic> && !(json['data'] as Map).containsKey('token')) {
      userJson = json['data'] as Map<String, dynamic>;
    } else {
      userJson = json;
    }

    return LoginResponseModel(
      token: token,
      user: UserModel.fromJson(userJson),
    );
  }
}
