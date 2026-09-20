import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/product_model.dart';

class ProductsRemoteDataSource {
  const ProductsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProductModel>> fetchAll() async {
    final response = await _apiClient.get(ApiEndpoints.products);
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  Future<ProductModel> create(ProductModel product) async {
    final response = await _apiClient.post(
      ApiEndpoints.products,
      data: product.toJson(),
    );
    return ProductModel.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<ProductModel> update(ProductModel product) async {
    final response = await _apiClient.put(
      ApiEndpoints.products,
      data: product.toJson(idOverride: product.id),
    );
    return ProductModel.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<void> delete(String id) =>
      _apiClient.delete(ApiEndpoints.products, query: {'id': id}).then((_) {});
}
