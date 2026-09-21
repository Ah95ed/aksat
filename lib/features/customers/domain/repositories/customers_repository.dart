import '../entities/customer.dart';
import '../entities/customer_detail.dart';

abstract interface class CustomersRepository {
  Future<List<Customer>> fetchAll({String? search});
  Future<CustomerDetail> fetchById(String id);
  Future<Customer> create(Customer customer);
  Future<Customer> update(Customer customer);
  Future<void> delete(String id);
}
