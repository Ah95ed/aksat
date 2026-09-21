import '../../../../core/utils/parsers.dart';
import '../../domain/entities/customer_detail.dart';

class CustomerDetailModel extends CustomerDetail {
  const CustomerDetailModel({
    required super.id,
    required super.name,
    required super.phone,
    super.address,
    super.notes,
    super.sales,
  });

  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    final rawSales = json['sales'];
    final salesList = <CustomerDetailSaleModel>[];
    if (rawSales is List) {
      for (final s in rawSales) {
        if (s is Map<String, dynamic>) {
          salesList.add(CustomerDetailSaleModel.fromJson(s));
        }
      }
    }

    return CustomerDetailModel(
      id: toStr(json['id']),
      name: toStr(json['name']),
      phone: toStr(json['phone']),
      address: json['address']?.toString(),
      notes: json['notes']?.toString(),
      sales: salesList,
    );
  }
}

class CustomerDetailSaleModel extends CustomerDetailSale {
  const CustomerDetailSaleModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.totalPrice,
    required super.downPayment,
    required super.installmentsCount,
    required super.installmentType,
    required super.currency,
    required super.saleDate,
    required super.status,
    required super.paidAmount,
    required super.remaining,
    required super.paidCount,
    required super.lateCount,
    super.notes,
    super.installments,
  });

  factory CustomerDetailSaleModel.fromJson(Map<String, dynamic> json) {
    final rawInsts = json['installments'];
    final instsList = <CustomerDetailInstallmentModel>[];
    if (rawInsts is List) {
      for (final inst in rawInsts) {
        if (inst is Map<String, dynamic>) {
          instsList.add(CustomerDetailInstallmentModel.fromJson(inst));
        }
      }
    }

    return CustomerDetailSaleModel(
      id: toStr(json['id']),
      productId: toStr(json['product_id']),
      productName: toStr(json['product_name']),
      quantity: toInt(json['quantity']) == 0 ? 1 : toInt(json['quantity']),
      totalPrice: toNum(json['total_price']),
      downPayment: toNum(json['down_payment']),
      installmentsCount: toInt(json['installments_count']),
      installmentType: toStr(json['installment_type']),
      currency: toStr(json['currency']).isEmpty ? 'USD' : toStr(json['currency']),
      saleDate: toStr(json['sale_date']),
      status: toStr(json['status']).isEmpty ? 'active' : toStr(json['status']),
      paidAmount: toNum(json['paid_amount']),
      remaining: toNum(json['remaining']),
      paidCount: toInt(json['paid_count']),
      lateCount: toInt(json['late_count']),
      notes: json['notes']?.toString(),
      installments: instsList,
    );
  }
}

class CustomerDetailInstallmentModel extends CustomerDetailInstallment {
  const CustomerDetailInstallmentModel({
    required super.id,
    required super.saleId,
    required super.installmentNumber,
    required super.amount,
    required super.dueDate,
    required super.status,
    super.paidDate,
    super.notes,
  });

  factory CustomerDetailInstallmentModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailInstallmentModel(
      id: toStr(json['id']),
      saleId: toStr(json['sale_id']),
      installmentNumber: toInt(json['installment_number']),
      amount: toNum(json['amount']),
      dueDate: toStr(json['due_date']),
      status: toStr(json['status']).isEmpty ? 'pending' : toStr(json['status']),
      paidDate: json['paid_date']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
