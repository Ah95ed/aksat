import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_endpoints.dart';

/// Reads the JWT from secure storage and injects BOTH required headers
/// (`Authorization` and `X-Authorization`) on every request except the
/// public auth endpoints (login/register).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  static const _keyToken = 'aksat_token';
  final FlutterSecureStorage _storage;

  static const _publicPaths = {ApiEndpoints.login, ApiEndpoints.register};

  String? _cachedToken;

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _keyToken);
    return _cachedToken;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _keyToken, value: token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(key: _keyToken);
  }

  bool _isPublic(RequestOptions options) {
    final path = options.path;
    return _publicPaths.any((p) => path.endsWith(p));
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options)) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
        options.headers['X-Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
