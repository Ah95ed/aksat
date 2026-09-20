class InventoryItem {
  const InventoryItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.currency,
    required this.quantity,
    required this.lowStockThreshold,
    required this.stockStatus,
    this.inventoryId,
    this.notes,
    this.updatedAt,
  });

  final String productId;
  final String productName;
  final double price;
  final String currency;
  final int quantity;
  final int lowStockThreshold;
  final String stockStatus;
  final String? inventoryId;
  final String? notes;
  final String? updatedAt;
}
