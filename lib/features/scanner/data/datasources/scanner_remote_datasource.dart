import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/label_model.dart';

abstract class ScannerRemoteDataSource {
  Future<LabelModel> getLabelByCode(String code);
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final DioClient _dioClient;

  ScannerRemoteDataSourceImpl([DioClient? dioClient])
      : _dioClient = dioClient ?? DioClient();

  @override
  Future<LabelModel> getLabelByCode(String code) async {
    final cleanCode = Uri.encodeComponent(code.trim());
    final response = await _dioClient.get(ApiConstants.labelDetail(cleanCode));

    final data = response.data is Map && response.data['data'] != null
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    return LabelModel.fromJson(data);
  }
}
