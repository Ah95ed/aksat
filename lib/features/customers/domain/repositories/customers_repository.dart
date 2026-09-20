import '../entities/customer.dart';

abstract interface class CustomersRepository {
  Future<List<Customer>> fetchAll({String? search});
  Future<Customer> create(Customer customer);
  Future<Customer> update(Customer customer);
  Future<void> delete(String id);
}
