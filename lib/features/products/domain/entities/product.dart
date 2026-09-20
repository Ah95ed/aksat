class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.costPrice,
    required this.currency,
    this.notes,
  });

  final String id;
  final String name;
  final double price;
  final double costPrice;
  final String currency;
  final String? notes;
}
