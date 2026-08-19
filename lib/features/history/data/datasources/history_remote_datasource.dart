import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/usage_history_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<UsageHistoryModel>> getHistory({
    int page = 1,
    String? search,
    String? filterDate,
  });
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final DioClient _dioClient;

  HistoryRemoteDataSourceImpl([DioClient? dioClient])
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<List<UsageHistoryModel>> getHistory({
    int page = 1,
    String? search,
    String? filterDate,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.myHistory,
        queryParameters: {
          'page': page,
          if (search != null && search.isNotEmpty) 'search': search,
          if (filterDate != null && filterDate.isNotEmpty) 'date': filterDate,
        },
      );

      final list = response.data is Map && response.data['data'] is List
          ? response.data['data'] as List
          : (response.data is List ? response.data as List : []);

      return list.map((e) => UsageHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
