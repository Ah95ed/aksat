import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/state/locale_controller.dart';
import '../../../../core/state/theme_controller.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_spinner.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/store_settings.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storeName = TextEditingController();
  final _currencyName = TextEditingController();
  final _currencySymbol = TextEditingController();
  final _exchangeRate = TextEditingController();
  final _whatsappTemplate = TextEditingController();

  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsController>().load();
    });
  }

  @override
  void dispose() {
    _storeName.dispose();
    _currencyName.dispose();
    _currencySymbol.dispose();
    _exchangeRate.dispose();
    _whatsappTemplate.dispose();
    super.dispose();
  }

  void _fill(StoreSettings value) {
    if (_initialized) return;
    _initialized = true;
    _storeName.text = value.storeName;
    _currencyName.text = value.currencyName.isNotEmpty ? value.currencyName : 'دينار';
    _currencySymbol.text = value.currencySymbol.isNotEmpty ? value.currencySymbol : 'د.ع';
    _exchangeRate.text = value.exchangeRate.isNotEmpty ? value.exchangeRate : '1450';
    _whatsappTemplate.text = value.whatsappTemplate;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final controller = context.read<SettingsController>();

    final updated = StoreSettings(
      storeName: _storeName.text.trim(),
      currencyName: _currencyName.text.trim(),
      currencySymbol: _currencySymbol.text.trim(),
      exchangeRate: _exchangeRate.text.trim(),
      whatsappTemplate: _whatsappTemplate.text.trim(),
      subscriptionRemainingDays: controller.settings.subscriptionRemainingDays,
    );

    final saved = await controller.update(updated);
    if (!mounted) return;
    setState(() => _saving = false);

    if (saved) {
      AppDialogs.alert(context, '✅ تم حفظ الإعدادات');
    } else {
      AppDialogs.alert(context, 'فشل: ${controller.errorMessage ?? "حدث خطأ"}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    _fill(controller.settings);
    final theme = context.watch<ThemeController>();
    final locale = context.watch<LocaleController>();
    final isArabic = locale.locale.languageCode == 'ar';
    final isDark = theme.isDark;

    final titleColor = isDark ? AppColors.white : AppColors.gray800;
    final primaryTextColor = isDark ? AppColors.gray100 : AppColors.gray800;
    final secondaryTextColor = isDark ? AppColors.gray400 : AppColors.gray500;
    final cardHeaderColor = isDark ? AppColors.blue400 : AppColors.blue700;
    final dividerColor = isDark ? const Color(0xFF334155) : AppColors.gray200;

    if (controller.state == ViewState.loading && !_initialized) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: AppSpinner(size: 40)),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                isArabic ? '⚙️ الإعدادات' : '⚙️ Settings',
                style: AppTextStyles.xxxlBold(titleColor),
              ),
              const SizedBox(height: 24),

              // Card 1: Store info
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? '🏪 معلومات المتجر' : '🏪 Store Information',
                      style: AppTextStyles.xlBold(cardHeaderColor),
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: dividerColor),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _storeName,
                      label: isArabic ? 'اسم المتجر' : 'Store Name',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Currency settings
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💱 إعدادات العملة',
                      style: AppTextStyles.xlBold(AppColors.blue700),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.gray200),
                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 500;
                        final nameField = AppTextField(
                          controller: _currencyName,
                          label: 'اسم العملة المحلية',
                          hint: 'مثال: دينار، ريال، جنيه',
                        );
                        final symField = AppTextField(
                          controller: _currencySymbol,
                          label: 'رمز العملة',
                          hint: 'مثال: د.ع، ر.س',
                        );

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: nameField),
                              const SizedBox(width: 16),
                              Expanded(child: symField),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            nameField,
                            const SizedBox(height: 12),
                            symField,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _exchangeRate,
                      label: 'سعر صرف الدولار (1\$ = ?)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      hint: '1450',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'أدخل قيمة الدولار الواحد بالعملة المحلية. مثال: 1450 للدينار العراقي',
                      style: AppTextStyles.xs(AppColors.gray500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 3: WhatsApp template
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💬 قالب رسالة الواتساب',
                      style: AppTextStyles.xlBold(AppColors.blue700),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.gray200),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _whatsappTemplate,
                      label: 'القالب',
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              AppButton(
                text: _saving ? '⏳ جاري الحفظ...' : '💾 حفظ التغييرات',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: 20),

              // Card 4: System info
              AppCard(
                color: isDark ? const Color(0xFF1E293B) : AppColors.gray50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'ℹ️ معلومات النظام' : 'ℹ️ System Information',
                      style: AppTextStyles.xlBold(cardHeaderColor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'إصدار النظام:' : 'System Version:',
                          style: AppTextStyles.base(secondaryTextColor),
                        ),
                        Text(AppConfig.appVersion, style: AppTextStyles.baseBold(primaryTextColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'حالة قاعدة البيانات:' : 'Database Status:',
                          style: AppTextStyles.base(secondaryTextColor),
                        ),
                        AppBadge(
                          label: isArabic ? 'متصلة' : 'Connected',
                          variant: AppBadgeVariant.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Card 5: Danger Zone - Delete Account
              AppCard(
                color: isDark ? const Color(0xFF261215) : AppColors.red50,
                border: Border.all(
                  color: isDark ? const Color(0xFF7F1D1D) : AppColors.red200,
                  width: 1.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.red600,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'منطقة الخطر: حذف الحساب' : 'Danger Zone: Delete Account',
                          style: AppTextStyles.xlBold(AppColors.red600),
                        ),
                        const Spacer(),
                        AppBadge(
                          label: isArabic ? 'إجراء نهائي' : 'Permanent',
                          variant: AppBadgeVariant.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF7F1D1D) : AppColors.red200,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isArabic
                          ? 'تحذير: عند النقر على حذف الحساب سيتم مسح كافة البيانات بشكل كامل وفوري من السيرفر ولن تتمكن من استعادتها بأي شكل من الأشكال، ويشمل ذلك:'
                          : 'Warning: Deleting your account permanently deletes all your store data from the server. This includes:',
                      style: AppTextStyles.baseMedium(
                        isDark ? AppColors.red200 : AppColors.red800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDeletedItemRow('📦', isArabic ? 'المخزن والمنتجات المسجلة والكميات' : 'Inventory and products', isDark),
                    _buildDeletedItemRow('👥', isArabic ? 'سجل العملاء والمشترين وأرقامهم' : 'Customers and buyers records', isDark),
                    _buildDeletedItemRow('💰', isArabic ? 'المبيعات والأقساط المسجلة والدفعات' : 'Sales, installments and payments', isDark),
                    _buildDeletedItemRow('📊', isArabic ? 'كافة التقارير والإحصائيات والأرباح' : 'All reports and financial statistics', isDark),
                    _buildDeletedItemRow('🏪', isArabic ? 'إعدادات وبيانات المتجر بالكامل' : 'Store profile and all settings', isDark),
                    const SizedBox(height: 20),
                    Align(
                      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                      child: AppButton(
                        text: isArabic ? '🗑️ حذف الحساب نهائياً' : '🗑️ Delete Account Permanently',
                        variant: AppButtonVariant.danger,
                        size: AppButtonSize.large,
                        onPressed: () => _showDeleteAccountDialog(context, isArabic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedItemRow(String emoji, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.sm(
                isDark ? AppColors.gray300 : AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, bool isArabic) async {
    final passwordController = TextEditingController();
    bool obscure = true;
    bool isSubmitting = false;
    String? localError;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      barrierColor: AppColors.modalBackdrop,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bg = isDark ? const Color(0xFF1E293B) : AppColors.white;
            final textColor = isDark ? AppColors.white : AppColors.gray900;
            final secondaryColor = isDark ? AppColors.gray300 : AppColors.gray600;

            return Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                backgroundColor: bg,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppDimens.border2Xl,
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.red100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.red600,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic ? 'تأكيد حذف الحساب نهائياً' : 'Confirm Account Deletion',
                        style: AppTextStyles.xlBold(AppColors.red600),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3B1215) : AppColors.red50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.red800 : AppColors.red200,
                          ),
                        ),
                        child: Text(
                          isArabic
                              ? '⚠️ تنبيه: سيتم حذف جميع بيانات متجرك والمخزن والعملاء والأقساط بشكل كامل ودائم من السيرفر. لا يمكن التراجع عن هذا الإجراء.'
                              : '⚠️ Warning: All store data, inventory, customers, and installments will be permanently erased. This action cannot be undone.',
                          style: AppTextStyles.sm(
                            isDark ? AppColors.red200 : AppColors.red700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isArabic
                            ? 'أدخل كلمة المرور الخاصة بحسابك للتأكيد:'
                            : 'Enter your account password to confirm:',
                        style: AppTextStyles.smMedium(textColor),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        style: AppTextStyles.base(textColor),
                        decoration: InputDecoration(
                          hintText: isArabic ? 'كلمة المرور' : 'Password',
                          hintStyle: AppTextStyles.base(secondaryColor),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : AppColors.gray50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF475569) : AppColors.gray300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF475569) : AppColors.gray300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.red500,
                              width: 1.8,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: secondaryColor,
                            ),
                            onPressed: () {
                              setDialogState(() => obscure = !obscure);
                            },
                          ),
                        ),
                      ),
                      if (localError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          localError!,
                          style: AppTextStyles.smBold(AppColors.red500),
                        ),
                      ],
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                actions: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: secondaryColor,
                    ),
                    child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final password = passwordController.text.trim();
                            if (password.isEmpty) {
                              setDialogState(() {
                                localError = isArabic
                                    ? 'يرجى إدخال كلمة المرور أولاً'
                                    : 'Please enter your password first';
                              });
                              return;
                            }
                            setDialogState(() {
                              isSubmitting = true;
                              localError = null;
                            });

                            final auth = context.read<AuthController>();
                            final success = await auth.deleteAccount(password: password);

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'تم حذف الحساب وجميع البيانات بنجاح.'
                                        : 'Account and all data deleted successfully.',
                                  ),
                                  backgroundColor: AppColors.red600,
                                ),
                              );
                            } else {
                              setDialogState(() {
                                isSubmitting = false;
                                localError = auth.errorMessage ??
                                    (isArabic
                                        ? 'فشل حذف الحساب. تأكد من صحة كلمة المرور.'
                                        : 'Failed to delete account. Check your password.');
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red600,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            isArabic ? 'تأكيد الحذف النهائي' : 'Permanently Delete',
                            style: AppTextStyles.baseBold(AppColors.white),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
