import '../entities/installment.dart';

abstract interface class InstallmentsRepository {
  Future<List<Installment>> fetch(String filter);
  Future<void> update({
    required String id,
    required String action,
    String? notes,
    String? paidDate,
  });
}
