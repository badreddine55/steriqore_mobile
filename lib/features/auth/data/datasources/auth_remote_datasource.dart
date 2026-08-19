import '../../../../core/constants/api_constants.dart';
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
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Invalid login response format.');
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: request.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Invalid register response format.');
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
    final data = response.data is Map && (response.data['data'] != null || response.data['user'] != null)
        ? (response.data['data'] ?? response.data['user']) as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    return UserModel.fromJson(data);
  }
}
