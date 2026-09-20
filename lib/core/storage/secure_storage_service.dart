import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage so the rest of the app never touches it.
/// Only the token lives here. Nothing else.
class SecureStorageService {
  const SecureStorageService();

  static const _keyToken = 'aksat_token';
  Future<String?> readToken() =>
      const FlutterSecureStorage().read(key: _keyToken);

  Future<void> writeToken(String token) =>
      const FlutterSecureStorage().write(key: _keyToken, value: token);

  Future<void> deleteToken() =>
      const FlutterSecureStorage().delete(key: _keyToken);
}
