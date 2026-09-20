class Installment {
  const Installment({
    required this.id,
    required this.saleId,
    required this.number,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.productName,
    required this.customerName,
    required this.customerPhone,
    this.paidDate,
    this.notes,
    this.currency = 'USD',
  });

  final String id;
  final String saleId;
  final int number;
  final double amount;
  final String dueDate;
  final String status;
  final String productName;
  final String customerName;
  final String customerPhone;
  final String? paidDate;
  final String? notes;
  final String currency;
}
