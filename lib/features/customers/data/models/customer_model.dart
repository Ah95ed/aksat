import '../../../../core/utils/parsers.dart';
import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.phone,
    super.address,
    super.notes,
    super.salesCount,
    super.activeSales,
    super.lateCount,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: toStr(json['id']),
    name: toStr(json['name']),
    phone: toStr(json['phone']),
    address: json['address']?.toString(),
    notes: json['notes']?.toString(),
    salesCount: toInt(json['sales_count']),
    activeSales: toInt(json['active_sales']),
    lateCount: toInt(json['late_count']),
  );

  factory CustomerModel.fromEntity(Customer value) => CustomerModel(
    id: value.id,
    name: value.name,
    phone: value.phone,
    address: value.address,
    notes: value.notes,
  );

  Map<String, dynamic> toJson({bool includeId = false}) => {
    ...?includeId ? {'id': id} : null,
    'name': name,
    'phone': phone,
    'address': address,
    'notes': notes,
  };
}
