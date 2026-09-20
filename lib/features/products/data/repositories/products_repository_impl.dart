import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<List<Product>> fetchAll() => _remote.fetchAll();

  @override
  Future<Product> create(Product product) =>
      _remote.create(ProductModel.fromEntity(product));

  @override
  Future<Product> update(Product product) =>
      _remote.update(ProductModel.fromEntity(product));

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
