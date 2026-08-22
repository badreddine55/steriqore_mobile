import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> register(RegisterRequestModel request);
  Future<void> logout();
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl([DioClient? dioClient])
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      final res = LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
      if (res.token.isNotEmpty) {
        return res;
      }
    }
    throw const ServerException(message: 'Invalid response or missing token from server.');
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: request.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      final res = LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
      return res;
    }
    throw const ServerException(message: 'Invalid registration response from server.');
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiConstants.logout);
    } catch (_) {}
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dioClient.get(ApiConstants.me);

    final dynamic data = response.data;
    Map<String, dynamic> userMap = <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      if (data['user'] is Map<String, dynamic>) {
        userMap = data['user'] as Map<String, dynamic>;
      } else if (data['data'] is Map<String, dynamic>) {
        userMap = data['data'] as Map<String, dynamic>;
      } else {
        userMap = data;
      }
    }

    if (userMap.isNotEmpty) {
      return UserModel.fromJson(userMap);
    }

    throw const ServerException(message: 'Unable to parse user profile from /auth/me');
  }
}
