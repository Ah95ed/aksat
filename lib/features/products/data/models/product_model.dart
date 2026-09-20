import '../../../../core/utils/parsers.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.costPrice,
    required super.currency,
    super.notes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id']?.toString() ?? '',
    name: toStr(json['name']),
    price: toNum(json['price']),
    costPrice: toNum(json['cost_price']),
    currency: toStr(json['currency']).isEmpty ? 'USD' : toStr(json['currency']),
    notes: json['notes']?.toString(),
  );

  factory ProductModel.fromEntity(Product product) => ProductModel(
    id: product.id,
    name: product.name,
    price: product.price,
    costPrice: product.costPrice,
    currency: product.currency,
    notes: product.notes,
  );

  Map<String, dynamic> toJson({String? idOverride}) => {
    ...?idOverride == null ? null : {'id': idOverride},
    'name': name,
    'price': price,
    'cost_price': costPrice,
    'currency': currency,
    'notes': notes,
  };
}
