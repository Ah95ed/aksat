import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_movement_model.dart';

class InventoryRemoteDataSource {
  const InventoryRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<InventoryItemModel>> fetchAll({bool lowStock = false}) async {
    final response = await _apiClient.get(
      ApiEndpoints.inventory,
      query: lowStock ? {'low_stock': '1'} : null,
    );
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(InventoryItemModel.fromJson)
        .toList();
  }

  Future<InventoryItemModel?> fetchOne(String productId) async {
    final response = await _apiClient.get(
      ApiEndpoints.inventory,
      query: {'product_id': productId},
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return InventoryItemModel.fromJson(data);
  }

  Future<List<InventoryMovementModel>> fetchMovements(String productId) async {
    final response = await _apiClient.get(
      ApiEndpoints.inventory,
      query: {'movements': productId},
    );
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(InventoryMovementModel.fromJson)
        .toList();
  }

  Future<InventoryItemModel?> save({
    required String productId,
    required int quantity,
    required String action,
    required int lowStockThreshold,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.inventory,
      data: {
        'product_id': productId,
        'quantity': quantity,
        'action': action,
        'low_stock_threshold': lowStockThreshold,
        'notes': ?notes,
      },
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return InventoryItemModel.fromJson(data);
  }

  Future<void> updateSettings({
    required String productId,
    required int lowStockThreshold,
    String? notes,
  }) => _apiClient
      .put(
        ApiEndpoints.inventory,
        data: {
          'product_id': productId,
          'low_stock_threshold': lowStockThreshold,
          'notes': ?notes,
        },
      )
      .then((_) {});

  Future<void> disable(String productId) => _apiClient
      .delete(ApiEndpoints.inventory, query: {'product_id': productId})
      .then((_) {});
}
