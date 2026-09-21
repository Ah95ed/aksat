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
                '⚙️ الإعدادات',
                style: AppTextStyles.xxxlBold(AppColors.gray800),
              ),
              const SizedBox(height: 24),

              // Card 1: Store info
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏪 معلومات المتجر',
                      style: AppTextStyles.xlBold(AppColors.blue700),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.gray200),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _storeName,
                      label: 'اسم المتجر',
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
                    const SizedBox(height: 8),

                    Text('المتغيرات المتاحة:', style: AppTextStyles.xs(AppColors.gray600)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: const [
                        _VariableChip(code: '{customer_name}', label: 'اسم المشتري'),
                        _VariableChip(code: '{product_name}', label: 'اسم المادة'),
                        _VariableChip(code: '{amount}', label: 'مبلغ القسط'),
                        _VariableChip(code: '{currency}', label: 'رمز العملة'),
                        _VariableChip(code: '{due_date}', label: 'تاريخ الاستحقاق'),
                      ],
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
                color: AppColors.gray50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ معلومات النظام',
                      style: AppTextStyles.xlBold(AppColors.gray700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('إصدار النظام:', style: AppTextStyles.base(AppColors.gray600)),
                        Text(AppConfig.appVersion, style: AppTextStyles.baseBold(AppColors.gray800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('حالة قاعدة البيانات:', style: TextStyle(color: Color(0xFF4B5563))),
                        AppBadge(label: 'متصلة', variant: AppBadgeVariant.success),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 5: Appearance & Language
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎨 المظهر واللغة',
                      style: AppTextStyles.xlBold(AppColors.blue700),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.gray200),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الوضع الداكن', style: AppTextStyles.baseMedium(AppColors.gray800)),
                            Text('تفعيل النمط الليلي للتطبيق', style: AppTextStyles.xs(AppColors.gray500)),
                          ],
                        ),
                        Switch(
                          value: theme.isDark,
                          onChanged: (_) => theme.toggle(),
                          activeThumbColor: AppColors.blue600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('اللغة', style: AppTextStyles.baseMedium(AppColors.gray800)),
                            Text('العربية / English', style: AppTextStyles.xs(AppColors.gray500)),
                          ],
                        ),
                        DropdownButton<String>(
                          value: locale.locale.languageCode,
                          items: const [
                            DropdownMenuItem(value: 'ar', child: Text('العربية')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                          ],
                          onChanged: (lang) {
                            if (lang != null) locale.setLocale(lang);
                          },
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

class _VariableChip extends StatelessWidget {
  const _VariableChip({required this.code, required this.label});
  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppDimens.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
          const SizedBox(width: 4),
          Text('- $label', style: AppTextStyles.xs(AppColors.gray600)),
        ],
      ),
    );
  }
}
