import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/report_result_model.dart';

class ReportsRemoteDataSource {
  const ReportsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ReportResultModel> fetch({
    required String type,
    required String period,
    required String currency,
    String? groupBy,
    String? productId,
    String? from,
    String? to,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.reports,
      query: {
        'type': type,
        'period': period,
        'currency': currency,
        'group_by': ?groupBy,
        'product_id': ?productId,
        'from': ?from,
        'to': ?to,
      },
    );
    return ReportResultModel.fromResponse(type, response);
  }
}
