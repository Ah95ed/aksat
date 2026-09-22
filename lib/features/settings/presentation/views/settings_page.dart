import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/state/locale_controller.dart';
import '../../../../core/state/theme_controller.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_spinner.dart';
import '../../../../core/widgets/app_text_field.dart';
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
