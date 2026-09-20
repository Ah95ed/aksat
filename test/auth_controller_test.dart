import 'package:flutter_test/flutter_test.dart';

import 'package:aksat/features/auth/domain/entities/user.dart';
import 'package:aksat/features/auth/domain/repositories/auth_repository.dart';
import 'package:aksat/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  test('restores an authenticated state when a session exists', () async {
    final controller = AuthController(
      _FakeAuthRepository(hasSavedSession: true),
    );

    await controller.restoreSession();

    expect(controller.status, AuthStatus.authenticated);
  });

  test('keeps the user signed out when no session exists', () async {
    final controller = AuthController(
      _FakeAuthRepository(hasSavedSession: false),
    );

    await controller.restoreSession();

    expect(controller.status, AuthStatus.unauthenticated);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.hasSavedSession});

  final bool hasSavedSession;

  @override
  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) async => (token: 'token', user: User(id: '1', name: 'Test', email: email));

  @override
  Future<({String token, User user})> register({
    required String name,
    required String email,
    required String password,
  }) async => (token: 'token', user: User(id: '1', name: name, email: email));

  @override
  Future<bool> hasSession() async => hasSavedSession;

  @override
  Future<void> logout() async {}
}
