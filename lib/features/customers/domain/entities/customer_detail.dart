class CustomerDetail {
  const CustomerDetail({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.notes,
    this.sales = const [],
  });

  final String id;
  final String name;
  final String phone;
  final String? address;
  final String? notes;
  final List<CustomerDetailSale> sales;

  List<CustomerDetailSale> get activeSales =>
      sales.where((s) => s.status == 'active').toList();

  List<CustomerDetailSale> get completedSales =>
      sales.where((s) => s.status == 'completed').toList();

  int get totalLateCount =>
      sales.fold(0, (sum, s) => sum + s.lateCount);
}

class CustomerDetailSale {
  const CustomerDetailSale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.downPayment,
    required this.installmentsCount,
    required this.installmentType,
    required this.currency,
    required this.saleDate,
    required this.status,
    required this.paidAmount,
    required this.remaining,
    required this.paidCount,
    required this.lateCount,
    this.notes,
    this.installments = const [],
  });

  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double totalPrice;
  final double downPayment;
  final int installmentsCount;
  final String installmentType;
  final String currency;
  final String saleDate;
  final String status;
  final double paidAmount;
  final double remaining;
  final int paidCount;
  final int lateCount;
  final String? notes;
  final List<CustomerDetailInstallment> installments;
}

class CustomerDetailInstallment {
  const CustomerDetailInstallment({
    required this.id,
    required this.saleId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.notes,
  });

  final String id;
  final String saleId;
  final int installmentNumber;
  final double amount;
  final String dueDate;
  final String status;
  final String? paidDate;
  final String? notes;
}
