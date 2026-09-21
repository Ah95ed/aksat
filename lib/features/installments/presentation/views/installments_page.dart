import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/whatsapp_launcher.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_spinner.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/state/view_state.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/installment.dart';
import '../controllers/installments_controller.dart';

class InstallmentsPage extends StatefulWidget {
  const InstallmentsPage({
    super.key,
    this.initialFilter = 'late',
    this.onNavigateToCustomer,
  });

  final String initialFilter;
  final ValueChanged<String>? onNavigateToCustomer;

  @override
  State<InstallmentsPage> createState() => _InstallmentsPageState();
}

class _InstallmentsPageState extends State<InstallmentsPage> {
  static const _filters = [
    ('late', '⚠️ المتأخرة'),
    ('upcoming_week', '📅 هذا الأسبوع'),
    ('upcoming_month', '📆 هذا الشهر'),
    ('all', '📋 الكل'),
    ('paid', '✅ المدفوعة'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstallmentsController>().load(widget.initialFilter);
    });
  }

  Future<void> _pay(Installment inst) async {
    final confirmed = await AppDialogs.confirm(context, 'تأكيد دفع هذا القسط؟');
    if (!confirmed || !mounted) return;

    final ctrl = context.read<InstallmentsController>();
    final ok = await ctrl.update(inst, 'pay');
    if (!ok && mounted) {
      AppDialogs.alert(context, ctrl.errorMessage ?? 'فشل: حدث خطأ');
    }
  }

  Future<void> _sendWhatsApp(Installment inst, dynamic settings) async {
    if (inst.customerPhone.trim().isEmpty) {
      if (mounted) {
        AppDialogs.alert(context, 'رقم هاتف المشتري غير متوفر.');
      }
      return;
    }

    final sym = inst.currency == 'USD'
        ? '\$'
        : MoneyFormatter.currencySymbol('LOCAL', settings);

    final tplStr = settings?.whatsappTemplate?.toString() ?? '';
    final template = tplStr.trim().isNotEmpty
        ? tplStr
        : WhatsAppLauncher.defaultTemplate;

    final message = WhatsAppLauncher.replacePlaceholders(
      template,
      customerName: inst.customerName,
      productName: inst.productName,
      amount: MoneyFormatter.formatAmount(inst.amount),
      currency: sym,
      dueDate: DateFormatter.formatDateShort(inst.dueDate),
    );

    final ok = await WhatsAppLauncher.launchWhatsApp(
      phone: inst.customerPhone,
      message: message,
    );

    if (!ok && mounted) {
      AppDialogs.alert(context, 'تعذر فتح تطبيق واتساب. تأكد من تثبيت واتساب أو صحة الرقم.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InstallmentsController>();
    final settingsCtrl = context.watch<SettingsController>();
    final settings = settingsCtrl.settings;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            '🔔 الأقساط القادمة والمتأخرة',
            style: AppTextStyles.xxxlBold(AppColors.gray800),
          ),
          const SizedBox(height: 24),

          // Filters Card
          AppCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final active = controller.filter == f.$1;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Material(
                      color: active ? AppColors.blue600 : AppColors.gray100,
                      borderRadius: AppDimens.borderLg,
                      child: InkWell(
                        onTap: () => controller.load(f.$1),
                        borderRadius: AppDimens.borderLg,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text(
                            f.$2,
                            style: AppTextStyles.baseMedium(active ? AppColors.white : AppColors.gray700),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          if (controller.state == ViewState.loading && controller.installments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: AppSpinner(size: 40)),
            )
          else if (controller.installments.isEmpty)
            const AppCard(
              child: EmptyView(
                message: '✨ لا توجد أقساط في هذه الفئة',
                inCard: false,
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: AppTable(
                minWidth: 700,
                columns: const [
                  AppTableColumn(title: 'المشتري'),
                  AppTableColumn(title: 'الهاتف', hideOnMobile: true),
                  AppTableColumn(title: 'المادة'),
                  AppTableColumn(title: 'القسط'),
                  AppTableColumn(title: 'المبلغ'),
                  AppTableColumn(title: 'تاريخ الاستحقاق'),
                  AppTableColumn(title: 'الحالة'),
                  AppTableColumn(title: 'الإجراءات', width: 90),
                ],
                rows: controller.installments.map((inst) {
                  final isLate = inst.status == 'late';
                  final isPaid = inst.status == 'paid';
                  final days = DateFormatter.daysUntil(inst.dueDate);
                  final daysText = DateFormatter.daysUntilText(inst.dueDate);

                  final sym = inst.currency == 'USD'
                      ? '\$'
                      : MoneyFormatter.currencySymbol('LOCAL', settings);

                  Color daysColor = AppColors.gray500;
                  FontWeight daysWeight = FontWeight.normal;
                  if (days < 0) {
                    daysColor = AppColors.red700;
                    daysWeight = FontWeight.bold;
                  } else if (days <= 3) {
                    daysColor = AppColors.amber700;
                    daysWeight = FontWeight.bold;
                  }

                  return AppTableRow(
                    backgroundColor: isLate ? AppColors.red50 : null,
                    cells: [
                      // Customer name (clickable)
                      AppTableCell(
                        child: InkWell(
                          onTap: () {
                            if (widget.onNavigateToCustomer != null && inst.customerId.isNotEmpty) {
                              widget.onNavigateToCustomer!(inst.customerId);
                            }
                          },
                          child: Text(
                            inst.customerName,
                            style: AppTextStyles.baseMedium(AppColors.blue700).copyWith(
                              decoration: widget.onNavigateToCustomer != null ? TextDecoration.underline : null,
                            ),
                          ),
                        ),
                      ),
                      // Phone
                      AppTableCell(
                        hideOnMobile: true,
                        child: Text(
                          inst.customerPhone,
                          style: AppTextStyles.sm(AppColors.gray600),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                      // Product name
                      AppTableCell(child: Text(inst.productName)),
                      // Installment number
                      AppTableCell(child: Text('#${inst.number}')),
                      // Amount
                      AppTableCell(
                        child: Text(
                          '${MoneyFormatter.formatAmount(inst.amount)} $sym',
                          style: AppTextStyles.baseBold(AppColors.gray800),
                        ),
                      ),
                      // Due date + days until
                      AppTableCell(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormatter.formatDateShort(inst.dueDate)),
                            Text(
                              daysText,
                              style: TextStyle(
                                fontSize: 11,
                                color: daysColor,
                                fontWeight: daysWeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      AppTableCell(
                        child: isPaid
                            ? const AppBadge(label: '✅ مدفوع', variant: AppBadgeVariant.success)
                            : isLate
                                ? const AppBadge(label: '⚠️ متأخر', variant: AppBadgeVariant.danger)
                                : const AppBadge(label: '⏳ قادم', variant: AppBadgeVariant.info),
                      ),
                      // Actions (Pay + WhatsApp)
                      AppTableCell(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isPaid)
                              Material(
                                color: AppColors.green600,
                                borderRadius: AppDimens.borderSm,
                                child: InkWell(
                                  onTap: () => _pay(inst),
                                  borderRadius: AppDimens.borderSm,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text('💵', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Material(
                              color: AppColors.green500,
                              borderRadius: AppDimens.borderSm,
                              child: InkWell(
                                onTap: () => _sendWhatsApp(inst, settings),
                                borderRadius: AppDimens.borderSm,
                                child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text('💬', style: TextStyle(fontSize: 14)),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
