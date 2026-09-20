import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/sale_model.dart';

class SalesRemoteDataSource {
  const SalesRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<SaleModel>> fetchAll() async {
    final response = await _apiClient.get(ApiEndpoints.sales);
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(SaleModel.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> create({required Map<String, dynamic> data}) =>
      _apiClient.post(ApiEndpoints.sales, data: data);

  Future<void> delete(String id) =>
      _apiClient.delete(ApiEndpoints.sales, query: {'id': id}).then((_) {});
}
