class Sale {
  const Sale({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.productName,
    required this.totalPrice,
    required this.downPayment,
    required this.installmentsCount,
    required this.installmentType,
    required this.currency,
    required this.saleDate,
    required this.quantity,
    required this.status,
    this.customerPhone,
    this.notes,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String productId;
  final String productName;
  final double totalPrice;
  final double downPayment;
  final int installmentsCount;
  final String installmentType;
  final String currency;
  final String saleDate;
  final int quantity;
  final String status;
  final String? customerPhone;
  final String? notes;
}
