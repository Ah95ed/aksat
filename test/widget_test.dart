import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:aksat/features/auth/domain/entities/user.dart';
import 'package:aksat/features/auth/domain/repositories/auth_repository.dart';
import 'package:aksat/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aksat/features/auth/presentation/views/auth_page.dart';

void main() {
  testWidgets('shows login when no session exists', (
    WidgetTester tester,
  ) async {
    final controller = AuthController(_FakeAuthRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, child) => const MaterialApp(home: AuthPage()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
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
  Future<bool> hasSession() async => false;

  @override
  Future<void> logout() async {}
}
