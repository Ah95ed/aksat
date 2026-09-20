import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { checking, unauthenticated, authenticated, submitting, error }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthStatus status = AuthStatus.checking;
  User? user;
  String? errorMessage;
  int? retryAfterSeconds;

  void clearError() {
    errorMessage = null;
    retryAfterSeconds = null;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    status = AuthStatus.checking;
    notifyListeners();
    try {
      final hasSession = await _repository.hasSession();
      status = hasSession
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) =>
      _submit(() => _repository.login(email: email, password: password));

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) => _submit(
    () => _repository.register(name: name, email: email, password: password),
  );

  Future<bool> _submit(
    Future<({String token, User user})> Function() action,
  ) async {
    status = AuthStatus.submitting;
    errorMessage = null;
    retryAfterSeconds = null;
    notifyListeners();
    try {
      final session = await action();
      user = session.user;
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on RateLimited catch (error) {
      retryAfterSeconds = error.retryAfterSeconds;
      errorMessage =
          'محاولات كثيرة. أعد المحاولة بعد ${error.retryAfterSeconds} ثانية.';
    } on SubscriptionStopped {
      errorMessage = 'الاشتراك متوقف أو منتهٍ.';
    } on ApiError catch (error) {
      errorMessage = error.message;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
    } catch (_) {
      errorMessage = 'حدث خطأ غير متوقع.';
    }
    status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();
    user = null;
    errorMessage = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
