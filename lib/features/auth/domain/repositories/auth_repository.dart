import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<({String token, User user})> login({
    required String email,
    required String password,
  });

  Future<({String token, User user})> register({
    required String name,
    required String email,
    required String password,
  });

  Future<bool> hasSession();
  Future<void> logout();
  Future<void> deleteAccount({required String password});
}
