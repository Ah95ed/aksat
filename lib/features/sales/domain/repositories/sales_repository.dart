import '../entities/sale.dart';

abstract interface class SalesRepository {
  Future<List<Sale>> fetchAll();
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
  Future<void> delete(String id);
}
