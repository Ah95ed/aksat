import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  const CustomersRepositoryImpl(this._remote);

  final CustomersRemoteDataSource _remote;

  @override
  Future<List<Customer>> fetchAll({String? search}) =>
      _remote.fetchAll(search: search);

  @override
  Future<Customer> create(Customer customer) =>
      _remote.create(CustomerModel.fromEntity(customer));

  @override
  Future<Customer> update(Customer customer) =>
      _remote.update(CustomerModel.fromEntity(customer));

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
