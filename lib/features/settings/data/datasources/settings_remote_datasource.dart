import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/store_settings_model.dart';

class SettingsRemoteDataSource {
  const SettingsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<StoreSettingsModel> fetch() async {
    final response = await _apiClient.get(ApiEndpoints.settings);
    final data = response['data'] as Map<String, dynamic>? ?? const {};
    return StoreSettingsModel.fromJson(data);
  }

  Future<StoreSettingsModel> update(StoreSettingsModel settings) async {
    final response = await _apiClient.put(
      ApiEndpoints.settings,
      data: settings.toJson(),
    );
    final data = response['data'] as Map<String, dynamic>? ?? const {};
    return StoreSettingsModel.fromJson(data);
  }
}
