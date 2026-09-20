import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/locale_controller.dart';
import '../../../../core/state/theme_controller.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/store_settings.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _storeName;
  late final TextEditingController _currencyName;
  late final TextEditingController _currencySymbol;
  late final TextEditingController _exchangeRate;
  late final TextEditingController _whatsappTemplate;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _storeName = TextEditingController();
    _currencyName = TextEditingController();
    _currencySymbol = TextEditingController();
    _exchangeRate = TextEditingController();
    _whatsappTemplate = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SettingsController>().load(),
    );
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
    _currencyName.text = value.currencyName;
    _currencySymbol.text = value.currencySymbol;
    _exchangeRate.text = value.exchangeRate;
    _whatsappTemplate.text = value.whatsappTemplate;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<SettingsController>();
    final saved = await controller.update(
      StoreSettings(
        storeName: _storeName.text.trim(),
        currencyName: _currencyName.text.trim(),
        currencySymbol: _currencySymbol.text.trim(),
        exchangeRate: _exchangeRate.text.trim(),
        whatsappTemplate: _whatsappTemplate.text.trim(),
        subscriptionRemainingDays:
            controller.settings.subscriptionRemainingDays,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'تم حفظ الإعدادات.'
              : controller.errorMessage ?? 'تعذر الحفظ.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    _fill(controller.settings);
    final locale = context.watch<LocaleController>();
    final theme = context.watch<ThemeController>();
    final english = locale.locale.languageCode == 'en';
    final title = english ? 'Settings' : 'الإعدادات';

    return Directionality(
      textDirection: english ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: controller.state.isLoading && !_initialized
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    _SectionTitle(english ? 'Appearance' : 'المظهر'),
                    DropdownButtonFormField<ThemeMode>(
                      initialValue: theme.mode,
                      decoration: InputDecoration(
                        labelText: english ? 'Theme' : 'الثيم',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(english ? 'System' : 'حسب النظام'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(english ? 'Light' : 'نهاري'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(english ? 'Dark' : 'ليلي'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) theme.setMode(value);
                      },
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: locale.locale.languageCode,
                      decoration: InputDecoration(
                        labelText: english ? 'Language' : 'اللغة',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (value) {
                        if (value != null) locale.setLocale(value);
                      },
                    ),
                    SizedBox(height: 20.h),
                    _SectionTitle(
                      english ? 'Store settings' : 'إعدادات المتجر',
                    ),
                    _field(_storeName, english ? 'Store name' : 'اسم المتجر'),
                    _field(
                      _currencyName,
                      english ? 'Local currency name' : 'اسم العملة المحلية',
                    ),
                    _field(
                      _currencySymbol,
                      english ? 'Currency symbol' : 'رمز العملة',
                    ),
                    _field(
                      _exchangeRate,
                      english ? 'Exchange rate' : 'سعر الصرف',
                      number: true,
                    ),
                    _field(
                      _whatsappTemplate,
                      english ? 'WhatsApp template' : 'قالب واتساب',
                      maxLines: 4,
                    ),
                    SizedBox(height: 20.h),
                    FilledButton.icon(
                      onPressed: controller.state.isLoading ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(english ? 'Save settings' : 'حفظ الإعدادات'),
                    ),
                    if (controller.settings.subscriptionRemainingDays !=
                        null) ...[
                      SizedBox(height: 16.h),
                      Text(
                        english
                            ? 'Subscription remaining days: ${controller.settings.subscriptionRemainingDays}'
                            : 'الأيام المتبقية للاشتراك: ${controller.settings.subscriptionRemainingDays}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
    int maxLines = 1,
  }) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          number &&
              value != null &&
              value.isNotEmpty &&
              double.tryParse(value) == null
          ? 'أدخل رقماً صحيحاً.'
          : null,
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}
