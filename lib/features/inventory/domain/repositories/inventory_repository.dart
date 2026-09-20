import '../entities/inventory_item.dart';
import '../entities/inventory_movement.dart';

abstract interface class InventoryRepository {
  Future<List<InventoryItem>> fetchAll({bool lowStock = false});
  Future<InventoryItem?> fetchOne(String productId);
  Future<List<InventoryMovement>> fetchMovements(String productId);
  Future<InventoryItem?> save({
    required String productId,
    required int quantity,
    required String action,
    required int lowStockThreshold,
    String? notes,
  });
  Future<void> updateSettings({
    required String productId,
    required int lowStockThreshold,
    String? notes,
  });
  Future<void> disable(String productId);
}
