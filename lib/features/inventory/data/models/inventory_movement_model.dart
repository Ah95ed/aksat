import '../../../../core/utils/parsers.dart';
import '../../domain/entities/inventory_movement.dart';

class InventoryMovementModel extends InventoryMovement {
  const InventoryMovementModel({
    required super.id,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.createdAt,
    super.notes,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) =>
      InventoryMovementModel(
        id: toStr(json['id']),
        productId: toStr(json['product_id']),
        type: toStr(json['movement_type']),
        quantity: toInt(json['quantity']),
        createdAt: toStr(json['created_at']),
        notes: json['notes']?.toString(),
      );
}
