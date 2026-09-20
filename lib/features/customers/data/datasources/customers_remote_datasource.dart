import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/customer_model.dart';

class CustomersRemoteDataSource {
  const CustomersRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CustomerModel>> fetchAll({String? search}) async {
    final response = await _apiClient.get(
      ApiEndpoints.customers,
      query: search == null || search.isEmpty ? null : {'search': search},
    );
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(CustomerModel.fromJson)
        .toList();
  }

  Future<CustomerModel> create(CustomerModel customer) async {
    final response = await _apiClient.post(
      ApiEndpoints.customers,
      data: customer.toJson(),
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> update(CustomerModel customer) async {
    final response = await _apiClient.put(
      ApiEndpoints.customers,
      data: customer.toJson(includeId: true),
    );
    return CustomerModel.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<void> delete(String id) =>
      _apiClient.delete(ApiEndpoints.customers, query: {'id': id}).then((_) {});
}
