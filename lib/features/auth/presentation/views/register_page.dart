import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.onGoToLogin,
    required this.onRegisterSuccess,
  });

  final VoidCallback onGoToLogin;
  final VoidCallback onRegisterSuccess;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _logoError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) return;

    final auth = context.read<AuthController>();
    final success = await auth.register(name: name, email: email, password: password);
    if (success && mounted) {
      widget.onRegisterSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isSubmitting = auth.status == AuthStatus.submitting;
    final errorMessage = auth.errorMessage;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.p4), // 16px
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.p8), // 32px
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppDimens.borderLg, // 8px
                    boxShadow: AppShadows.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo (80x80)
                      if (!_logoError)
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: AppDimens.borderXl,
                              border: Border.all(color: AppColors.gray200),
                              boxShadow: AppShadows.sm,
                            ),
                            child: ClipRRect(
                              borderRadius: AppDimens.borderLg,
                              child: Image.asset(
                                'assets/images/icon.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) setState(() => _logoError = true);
                                  });
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                        ),

                      // Title
                      Text(
                        'إنشاء حساب جديد',
                        style: AppTextStyles.xxlBold(AppColors.gray800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Error message
                      if (errorMessage != null && errorMessage.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.red100,
                            borderRadius: AppDimens.borderSm,
                          ),
                          child: Text(
                            errorMessage,
                            style: AppTextStyles.sm(AppColors.red700),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Name field
                      AppTextField(
                        label: 'الاسم الكامل',
                        controller: _nameController,
                        hintText: 'أدخل اسمك',
                        isLoginStyle: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Email field
                      AppTextField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        hintText: 'example@mail.com',
                        keyboardType: TextInputType.emailAddress,
                        isLoginStyle: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      AppTextField(
                        label: 'كلمة المرور',
                        controller: _passwordController,
                        hintText: '********',
                        isPassword: true,
                        isLoginStyle: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleRegister(),
                      ),
                      const SizedBox(height: 16),

                      // Submit button
                      AppButton(
                        text: isSubmitting ? 'جاري التسجيل...' : 'إنشاء الحساب',
                        isLoading: isSubmitting,
                        onPressed: isSubmitting ? null : _handleRegister,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 16),

                      // Link to login
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'لديك حساب بالفعل؟ ',
                              style: AppTextStyles.sm(AppColors.gray600),
                            ),
                            GestureDetector(
                              onTap: widget.onGoToLogin,
                              child: Text(
                                'تسجيل الدخول',
                                style: AppTextStyles.smBold(AppColors.blue600),
                              ),
                            ),
                          ],
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
