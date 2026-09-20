import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_datasource.dart';

class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl(this._remote);
  final SalesRemoteDataSource _remote;

  @override
  Future<List<Sale>> fetchAll() => _remote.fetchAll();

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) =>
      _remote.create(data: data);

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
