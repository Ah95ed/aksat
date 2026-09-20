import '../../../../core/utils/parsers.dart';
import '../../domain/entities/sale.dart';

class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.productId,
    required super.productName,
    required super.totalPrice,
    required super.downPayment,
    required super.installmentsCount,
    required super.installmentType,
    required super.currency,
    required super.saleDate,
    required super.quantity,
    required super.status,
    super.customerPhone,
    super.notes,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: toStr(json['id']),
    customerId: toStr(json['customer_id']),
    customerName: toStr(json['customer_name']),
    productId: toStr(json['product_id']),
    productName: toStr(json['product_name']),
    totalPrice: toNum(json['total_price']),
    downPayment: toNum(json['down_payment']),
    installmentsCount: toInt(json['installments_count']),
    installmentType: toStr(json['installment_type']),
    currency: toStr(json['currency']).isEmpty ? 'USD' : toStr(json['currency']),
    saleDate: toStr(json['sale_date']),
    quantity: toInt(json['quantity']),
    status: toStr(json['status']),
    customerPhone: json['customer_phone']?.toString(),
    notes: json['notes']?.toString(),
  );
}
