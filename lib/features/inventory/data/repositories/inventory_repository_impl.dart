import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_movement.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._remote);

  final InventoryRemoteDataSource _remote;

  @override
  Future<List<InventoryItem>> fetchAll({bool lowStock = false}) =>
      _remote.fetchAll(lowStock: lowStock);

  @override
  Future<InventoryItem?> fetchOne(String productId) =>
      _remote.fetchOne(productId);

  @override
  Future<List<InventoryMovement>> fetchMovements(String productId) =>
      _remote.fetchMovements(productId);

  @override
  Future<InventoryItem?> save({
    required String productId,
    required int quantity,
    required String action,
    required int lowStockThreshold,
    String? notes,
  }) => _remote.save(
    productId: productId,
    quantity: quantity,
    action: action,
    lowStockThreshold: lowStockThreshold,
    notes: notes,
  );

  @override
  Future<void> updateSettings({
    required String productId,
    required int lowStockThreshold,
    String? notes,
  }) => _remote.updateSettings(
    productId: productId,
    lowStockThreshold: lowStockThreshold,
    notes: notes,
  );

  @override
  Future<void> disable(String productId) => _remote.disable(productId);
}
