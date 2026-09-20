import '../../../../core/utils/parsers.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    required super.productId,
    required super.productName,
    required super.price,
    required super.currency,
    required super.quantity,
    required super.lowStockThreshold,
    required super.stockStatus,
    super.inventoryId,
    super.notes,
    super.updatedAt,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      InventoryItemModel(
        productId: toStr(json['product_id']),
        productName: toStr(json['product_name']),
        price: toNum(json['price']),
        currency: toStr(json['currency']).isEmpty
            ? 'USD'
            : toStr(json['currency']),
        quantity: toInt(json['quantity']),
        lowStockThreshold: toInt(json['low_stock_threshold']),
        stockStatus: toStr(json['stock_status']).isEmpty
            ? 'not_tracked'
            : toStr(json['stock_status']),
        inventoryId: json['inventory_id']?.toString(),
        notes: json['inventory_notes']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
}
