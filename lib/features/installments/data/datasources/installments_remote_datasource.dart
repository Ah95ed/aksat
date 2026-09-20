import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/installment_model.dart';

class InstallmentsRemoteDataSource {
  const InstallmentsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<InstallmentModel>> fetch(String filter) async {
    final response = await _apiClient.get(
      ApiEndpoints.installments,
      query: {'filter': filter},
    );
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(InstallmentModel.fromJson)
        .toList();
  }

  Future<void> update({
    required String id,
    required String action,
    String? notes,
    String? paidDate,
  }) async {
    await _apiClient.put(
      ApiEndpoints.installments,
      data: {
        'id': id,
        'action': action,
        'notes': ?notes,
        'paid_date': ?paidDate,
      },
    );
  }
}
