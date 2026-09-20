class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.notes,
    this.salesCount = 0,
    this.activeSales = 0,
    this.lateCount = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String? address;
  final String? notes;
  final int salesCount;
  final int activeSales;
  final int lateCount;
}
