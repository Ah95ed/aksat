import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isRegister = false;

  @override
  Widget build(BuildContext context) {
    if (_isRegister) {
      return RegisterPage(
        onGoToLogin: () => setState(() => _isRegister = false),
        onRegisterSuccess: () {},
      );
    }
    return LoginPage(
      onGoToRegister: () => setState(() => _isRegister = true),
      onLoginSuccess: () {},
    );
  }
}
