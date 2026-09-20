class InventoryMovement {
  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String productId;
  final String type;
  final int quantity;
  final String createdAt;
  final String? notes;
}
