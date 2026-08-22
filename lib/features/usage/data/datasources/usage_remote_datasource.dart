import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/patient_model.dart';
import '../models/usage_request_model.dart';
import '../models/usage_response_model.dart';

abstract class UsageRemoteDataSource {
  Future<List<PatientModel>> getPatients({String? query});
  Future<UsageResponseModel> recordUsage({
    required String labelId,
    required UsageRequestModel request,
  });
}

class UsageRemoteDataSourceImpl implements UsageRemoteDataSource {
  final DioClient _dioClient;

  UsageRemoteDataSourceImpl([DioClient? dioClient])
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<List<PatientModel>> getPatients({String? query}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.patients,
        queryParameters: query != null && query.isNotEmpty ? {'search': query} : null,
      );

      final list = response.data is Map && response.data['data'] is List
          ? response.data['data'] as List
          : (response.data is List ? response.data as List : []);

      return list.map((e) => PatientModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<UsageResponseModel> recordUsage({
    required String labelId,
    required UsageRequestModel request,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.recordUsage(labelId),
      data: request.toJson(),
    );

    final data = response.data is Map && response.data['data'] != null
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    return UsageResponseModel.fromJson(data);
  }
}
