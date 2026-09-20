import '../../../../core/network/auth_interceptor.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._authInterceptor);

  final AuthRemoteDataSource _remote;
  final AuthInterceptor _authInterceptor;

  @override
  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) => _saveSession(_remote.login(email: email, password: password));

  @override
  Future<({String token, User user})> register({
    required String name,
    required String email,
    required String password,
  }) => _saveSession(
    _remote.register(name: name, email: email, password: password),
  );

  Future<({String token, User user})> _saveSession(
    Future<AuthSessionModel> request,
  ) async {
    final session = await request;
    if (session.token.isEmpty) {
      throw StateError('لم يرجع الخادم رمز جلسة صالحاً');
    }
    await _authInterceptor.saveToken(session.token);
    return (token: session.token, user: session.user);
  }

  @override
  Future<bool> hasSession() async =>
      (await _authInterceptor.getToken())?.isNotEmpty ?? false;

  @override
  Future<void> logout() => _authInterceptor.clearToken();
}
