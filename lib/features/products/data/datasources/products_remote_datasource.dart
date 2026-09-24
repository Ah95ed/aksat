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
    return _parseProductResponse(response, fallback: product);
  }

  Future<ProductModel> update(ProductModel product) async {
    final response = await _apiClient.put(
      ApiEndpoints.products,
      data: product.toJson(idOverride: product.id),
    );
    return _parseProductResponse(response, fallback: product);
  }

  ProductModel _parseProductResponse(
    Map<String, dynamic> response, {
    required ProductModel fallback,
  }) {
    final rawData = response['data'];
    Map<String, dynamic> map = {};

    if (rawData is Map) {
      map = rawData.map((k, v) => MapEntry(k.toString(), v));
    } else if (rawData is int || rawData is String) {
      map = {'id': rawData.toString()};
    } else if (response['id'] != null) {
      map = {'id': response['id'].toString()};
    }

    final parsed = ProductModel.fromJson(map);

    return ProductModel(
      id: parsed.id.isNotEmpty
          ? parsed.id
          : (fallback.id.isNotEmpty
                ? fallback.id
                : (response['id']?.toString() ?? '')),
      name: parsed.name.isNotEmpty ? parsed.name : fallback.name,
      price: parsed.price > 0 ? parsed.price : fallback.price,
      costPrice: parsed.costPrice > 0 ? parsed.costPrice : fallback.costPrice,
      currency: parsed.currency.isNotEmpty
          ? parsed.currency
          : fallback.currency,
      notes: (parsed.notes != null && parsed.notes!.isNotEmpty)
          ? parsed.notes
          : fallback.notes,
    );
  }

  Future<void> delete(String id) =>
      _apiClient.delete(ApiEndpoints.products, query: {'id': id}).then((_) {});
}
