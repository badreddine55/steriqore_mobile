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

      if (list.isEmpty) {
        return _getMockPatients(query);
      }

      return list.map((e) => PatientModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getMockPatients(query);
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

  List<PatientModel> _getMockPatients(String? query) {
    final all = [
      PatientModel.fromJson(const {
        'id': 'PAT-001',
        'firstName': 'Marie',
        'lastName': 'Dubois',
        'dossierId': 'DOS-2024-001',
        'allergies': ['Pénicilline', 'Latex'],
        'allergySeverity': ['severe', 'moderate'],
        'lastVisit': '2026-08-10',
      }),
      PatientModel.fromJson(const {
        'id': 'PAT-002',
        'firstName': 'Jean',
        'lastName': 'Moreau',
        'dossierId': 'DOS-2024-045',
        'allergies': ['Ibuprofène'],
        'allergySeverity': ['moderate'],
        'lastVisit': '2026-08-12',
      }),
      PatientModel.fromJson(const {
        'id': 'PAT-003',
        'firstName': 'Sophie',
        'lastName': 'Lefèvre',
        'dossierId': 'DOS-2025-112',
        'allergies': [],
        'allergySeverity': [],
        'lastVisit': '2026-08-14',
      }),
      PatientModel.fromJson(const {
        'id': 'PAT-004',
        'firstName': 'Pierre',
        'lastName': 'Bernard',
        'dossierId': 'DOS-2023-089',
        'allergies': ['Lidocaïne', 'Latex'],
        'allergySeverity': ['severe', 'severe'],
        'lastVisit': '2026-08-08',
      }),
      PatientModel.fromJson(const {
        'id': 'PAT-005',
        'firstName': 'Claire',
        'lastName': 'Rousseau',
        'dossierId': 'DOS-2025-234',
        'allergies': ['Amoxicilline'],
        'allergySeverity': ['moderate'],
        'lastVisit': '2026-08-13',
      }),
    ];

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      return all.where((p) => p.fullName.toLowerCase().contains(q) || p.dossierId.toLowerCase().contains(q)).toList();
    }
    return all;
  }
}
