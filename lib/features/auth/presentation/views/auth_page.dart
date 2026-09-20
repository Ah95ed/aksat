import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    if (_isRegister) {
      await auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
    });
    context.read<AuthController>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isSubmitting = auth.status == AuthStatus.submitting;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 56.r,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _isRegister ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _isRegister
                            ? 'أنشئ حسابك لإدارة المبيعات والأقساط.'
                            : 'أهلاً بك مجدداً في أقساط.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 28.h),
                      if (_isRegister) ...[
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'الاسم',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().length < 2
                              ? 'اكتب اسماً من حرفين على الأقل.'
                              : null,
                        ),
                        SizedBox(height: 14.h),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(email)
                              ? null
                              : 'اكتب بريداً إلكترونياً صحيحاً.';
                        },
                      ),
                      SizedBox(height: 14.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            tooltip: 'إظهار كلمة المرور',
                          ),
                        ),
                        validator: (value) => value == null || value.length < 8
                            ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.'
                            : null,
                      ),
                      if (auth.errorMessage != null) ...[
                        SizedBox(height: 14.h),
                        Text(
                          auth.errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: 22.h),
                      FilledButton(
                        onPressed: isSubmitting ? null : _submit,
                        child: isSubmitting
                            ? SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isRegister ? 'إنشاء الحساب' : 'دخول'),
                      ),
                      SizedBox(height: 10.h),
                      TextButton(
                        onPressed: isSubmitting ? null : _toggleMode,
                        child: Text(
                          _isRegister
                              ? 'لديك حساب؟ سجّل الدخول'
                              : 'ليس لديك حساب؟ أنشئ حساباً',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
