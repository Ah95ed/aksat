import '../entities/product.dart';

abstract interface class ProductsRepository {
  Future<List<Product>> fetchAll();
  Future<Product> create(Product product);
  Future<Product> update(Product product);
  Future<void> delete(String id);
}
