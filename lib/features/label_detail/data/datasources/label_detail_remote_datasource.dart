import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cycle_item_model.dart';
import '../models/cycle_model.dart';

abstract class LabelDetailRemoteDataSource {
  Future<CycleModel> getCycleDetails(String cycleId);
  Future<List<CycleItemModel>> getCycleItems(String cycleId);
  Future<List<String>> getCycleAttachments(String cycleId);
}

class LabelDetailRemoteDataSourceImpl implements LabelDetailRemoteDataSource {
  final DioClient _dioClient;

  LabelDetailRemoteDataSourceImpl([DioClient? dioClient])
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<CycleModel> getCycleDetails(String cycleId) async {
    final response = await _dioClient.get(ApiConstants.cycleDetail(cycleId));
    final data = response.data is Map && response.data['data'] != null
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;
    return CycleModel.fromJson(data);
  }

  @override
  Future<List<CycleItemModel>> getCycleItems(String cycleId) async {
    try {
      final response = await _dioClient.get(ApiConstants.cycleItems(cycleId));
      final list = response.data is Map && response.data['data'] is List
          ? response.data['data'] as List
          : (response.data is List ? response.data as List : []);
      return list.map((e) => CycleItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<String>> getCycleAttachments(String cycleId) async {
    try {
      final response = await _dioClient.get(ApiConstants.cycleAttachments(cycleId));
      final list = response.data is Map && response.data['data'] is List
          ? response.data['data'] as List
          : (response.data is List ? response.data as List : []);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }
}
