import '../../../../core/utils/parsers.dart';
import '../../domain/entities/installment.dart';

class InstallmentModel extends Installment {
  const InstallmentModel({
    required super.id,
    required super.saleId,
    required super.number,
    required super.amount,
    required super.dueDate,
    required super.status,
    required super.productName,
    required super.customerName,
    required super.customerPhone,
    super.paidDate,
    super.notes,
    super.currency,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) => InstallmentModel(
        id: toStr(json['id']),
        saleId: toStr(json['sale_id']),
        number: toInt(json['installment_number']),
        amount: toNum(json['amount']),
        dueDate: toStr(json['due_date']),
        status: toStr(json['status']),
        productName: toStr(json['product_name']),
        customerName: toStr(json['customer_name']),
        customerPhone: toStr(json['customer_phone']),
        paidDate: json['paid_date']?.toString(),
        notes: json['notes']?.toString(),
        currency: toStr(json['currency']).isEmpty ? 'USD' : toStr(json['currency']),
      );
}
