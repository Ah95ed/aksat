import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardSummaryModel> fetchSummary() async {
    final response = await _apiClient.get(ApiEndpoints.dashboard);
    final data = response['data'] as Map<String, dynamic>? ?? const {};
    return DashboardSummaryModel.fromJson(data);
  }
}
