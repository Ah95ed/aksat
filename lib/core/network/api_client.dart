import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_response_handler.dart';
import 'auth_interceptor.dart';

/// The single, unchanging Dio instance for the whole app.
/// Adding a new endpoint, changing auth, or swapping transports only
/// touches this file (plus AuthInterceptor).
class ApiClient {
  ApiClient(this._auth);

  final AuthInterceptor _auth;
  late final Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {'Content-Type': 'application/json'},
        // We handle 401/403/429/success:false ourselves.
        validateStatus: (_) => true,
      ),
    );
    _dio.interceptors.add(_auth);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  /// Executes [request], maps transport errors via [mapDioException],
  /// then runs the body through [ApiResponseHandler.handle].
  Future<Map<String, dynamic>> send(
    Future<Response<dynamic>> Function(Dio) request,
  ) async {
    try {
      final res = await request(_dio);
      return ApiResponseHandler.handle(res.statusCode, res.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => send((dio) => dio.get(path, queryParameters: query));

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) => send((dio) => dio.post(path, data: data));

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) =>
      send((dio) => dio.put(path, data: data));

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) => send((dio) => dio.delete(path, queryParameters: query, data: data));
}
