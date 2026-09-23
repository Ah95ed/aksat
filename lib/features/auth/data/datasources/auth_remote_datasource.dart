import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(response);
  }

  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(response);
  }

  Future<void> deleteAccount({required String password}) async {
    await _apiClient.delete(
      ApiEndpoints.account,
      data: {'password': password},
    );
  }
}
