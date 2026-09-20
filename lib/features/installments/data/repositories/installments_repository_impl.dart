import '../../domain/entities/installment.dart';
import '../../domain/repositories/installments_repository.dart';
import '../datasources/installments_remote_datasource.dart';

class InstallmentsRepositoryImpl implements InstallmentsRepository {
  const InstallmentsRepositoryImpl(this._remote);

  final InstallmentsRemoteDataSource _remote;

  @override
  Future<List<Installment>> fetch(String filter) => _remote.fetch(filter);

  @override
  Future<void> update({
    required String id,
    required String action,
    String? notes,
    String? paidDate,
  }) =>
      _remote.update(id: id, action: action, notes: notes, paidDate: paidDate);
}
