import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/whatsapp_launcher.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onGoToRegister,
    required this.onLoginSuccess,
  });

  final VoidCallback onGoToRegister;
  final VoidCallback onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _logoError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    final auth = context.read<AuthController>();
    final success = await auth.login(email: email, password: password);
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isSubmitting = auth.status == AuthStatus.submitting;
    final errorMessage = auth.errorMessage;
    final isSubscriptionStopped = auth.isSubscriptionStopped ||
        (errorMessage != null &&
            (errorMessage.contains('إيقاف') || errorMessage.contains('اشتراكك')));

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
                        'تسجيل الدخول',
                        style: AppTextStyles.xxlBold(AppColors.gray800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Error message + WhatsApp renew button
                      if (errorMessage != null && errorMessage.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.red100,
                            borderRadius: AppDimens.borderSm,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage,
                                style: AppTextStyles.sm(AppColors.red700),
                                textAlign: TextAlign.center,
                              ),
                              if (isSubscriptionStopped) ...[
                                const SizedBox(height: 12),
                                Material(
                                  color: AppColors.emerald600,
                                  borderRadius: AppDimens.borderSm,
                                  child: InkWell(
                                    onTap: () => WhatsAppLauncher.launchWhatsApp(
                                      phone: auth.subscriptionWhatsappPhone ?? '9647706118992',
                                      message: 'السلام عليكم، أرغب بتجديد اشتراكي',
                                    ),
                                    borderRadius: AppDimens.borderSm,
                                    highlightColor: AppColors.emerald700,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/whatsapp.svg',
                                            width: 20,
                                            height: 20,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'التواصل عبر واتساب لتجديد الاشتراك',
                                            style: AppTextStyles.smBold(AppColors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      // Email field
                      AppTextField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        hintText: 'example@mail.com',
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
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
                        textDirection: TextDirection.ltr,
                        isLoginStyle: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 16),

                      // Submit button
                      AppButton(
                        text: isSubmitting ? 'جاري التحقق...' : 'دخول',
                        isLoading: isSubmitting,
                        onPressed: isSubmitting ? null : _handleLogin,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 16),

                      // Link to register
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'ليس لديك حساب؟ ',
                              style: AppTextStyles.sm(AppColors.gray600),
                            ),
                            GestureDetector(
                              onTap: widget.onGoToRegister,
                              child: Text(
                                'إنشاء حساب جديد',
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
