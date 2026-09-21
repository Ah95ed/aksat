import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/whatsapp_launcher.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_spinner.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/state/view_state.dart';
import '../../../sales/presentation/services/sale_pdf_service.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/customer_detail.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsPage extends StatefulWidget {
  const CustomerDetailsPage({
    super.key,
    required this.customerId,
    required this.onBack,
  });

  final String customerId;
  final VoidCallback onBack;

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerDetailsController>().load(widget.customerId);
    });
  }

  double _getDisplayAmount(
    double amount,
    String originalCurrency,
    String saleId,
    CustomerDetailsController ctrl,
    dynamic settings,
  ) {
    final mode = ctrl.displayCurrency[saleId];
    if (mode == null || mode == 'ORIGINAL') return amount;
    final target = originalCurrency == 'USD' ? 'LOCAL' : 'USD';
    return MoneyFormatter.convertCurrency(
      amount,
      originalCurrency,
      target,
      settings.exchangeRate,
    );
  }

  String _getDisplaySymbol(
    String originalCurrency,
    String saleId,
    CustomerDetailsController ctrl,
    dynamic settings,
  ) {
    final mode = ctrl.displayCurrency[saleId];
    final isOriginal = mode == null || mode == 'ORIGINAL';
    if (isOriginal) {
      return originalCurrency == 'USD'
          ? '\$'
          : MoneyFormatter.currencySymbol('LOCAL', settings);
    }
    return originalCurrency == 'USD'
        ? MoneyFormatter.currencySymbol('LOCAL', settings)
        : '\$';
  }

  void _sendWhatsApp(CustomerDetail customer, CustomerDetailSale sale, dynamic settings) {
    // Find nearest unpaid installment
    final unpaid = sale.installments.where((i) => i.status != 'paid').toList();
    final nextInst = unpaid.isNotEmpty ? unpaid.first : null;

    final sym = sale.currency == 'USD'
        ? '\$'
        : MoneyFormatter.currencySymbol('LOCAL', settings);

    final amountStr = nextInst != null
        ? MoneyFormatter.formatAmount(nextInst.amount)
        : MoneyFormatter.formatAmount(sale.remaining - sale.paidAmount);

    final dueDateStr = nextInst != null
        ? DateFormatter.formatDateShort(nextInst.dueDate)
        : '-';

    final template = (settings.whatsappTemplate as String).isNotEmpty
        ? settings.whatsappTemplate as String
        : 'السلام عليكم {customer_name}،\nنذكركم بقسط {product_name}\nالمبلغ: {amount} {currency}\nتاريخ الاستحقاق: {due_date}\nشكراً لتعاملكم معنا.';

    final message = WhatsAppLauncher.replacePlaceholders(
      template,
      customerName: customer.name,
      productName: sale.productName,
      amount: amountStr,
      currency: sym,
      dueDate: dueDateStr,
    );

    WhatsAppLauncher.launchWhatsApp(
      phone: customer.phone,
      message: message,
    );
  }

  Future<void> _payInstallment(String installmentId) async {
    final confirmed = await AppDialogs.confirm(context, 'تأكيد دفع هذا القسط؟');
    if (!confirmed || !mounted) return;

    final ctrl = context.read<CustomerDetailsController>();
    final ok = await ctrl.payInstallment(installmentId, widget.customerId);
    if (!ok && mounted) {
      AppDialogs.alert(context, ctrl.errorMessage ?? 'فشل تسديد القسط');
    }
  }

  Future<void> _unpayInstallment(String installmentId) async {
    final confirmed = await AppDialogs.confirm(context, 'إلغاء دفع هذا القسط؟');
    if (!confirmed || !mounted) return;

    final ctrl = context.read<CustomerDetailsController>();
    final ok = await ctrl.unpayInstallment(installmentId, widget.customerId);
    if (!ok && mounted) {
      AppDialogs.alert(context, ctrl.errorMessage ?? 'فشل إلغاء تسديد القسط');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CustomerDetailsController>();
    final settingsCtrl = context.watch<SettingsController>();
    final settings = settingsCtrl.settings;
    final customer = ctrl.customer;

    if (ctrl.state == ViewState.loading && customer == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: AppSpinner(size: 48)),
      );
    }

    if (customer == null) {
      return AppCard(
        child: Column(
          children: [
            const EmptyView(message: 'المشتري غير موجود', inCard: false),
            const SizedBox(height: 16),
            AppButton(
              text: '→ العودة للقائمة',
              variant: AppButtonVariant.secondary,
              onPressed: widget.onBack,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              text: '→ العودة للقائمة',
              variant: AppButtonVariant.secondary,
              onPressed: widget.onBack,
            ),
          ),
          const SizedBox(height: 16),

          // Customer info card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('👤', style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.name, style: AppTextStyles.xxxlBold(AppColors.gray800)),
                          const SizedBox(height: 4),
                          Text(
                            '📞 ${customer.phone}',
                            style: AppTextStyles.base(AppColors.gray600),
                            textDirection: TextDirection.ltr,
                          ),
                          if (customer.address != null && customer.address!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '📍 ${customer.address}',
                              style: AppTextStyles.sm(AppColors.gray500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4 Stats
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    final tiles = [
                      _headerStat('${customer.sales.length}', 'إجمالي البيوع', AppColors.blue50, AppColors.blue700),
                      _headerStat('${customer.activeSales.length}', 'نشط', AppColors.green50, AppColors.green700),
                      _headerStat('${customer.completedSales.length}', 'مكتمل', AppColors.purple50, AppColors.purple700),
                      _headerStat('${customer.totalLateCount}', 'قسط متأخر', AppColors.red50, AppColors.red700),
                    ];

                    if (isWide) {
                      return Row(
                        children: tiles.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: t))).toList(),
                      );
                    }
                    return Column(
                      children: [
                        Row(children: [Expanded(child: tiles[0]), const SizedBox(width: 8), Expanded(child: tiles[1])]),
                        const SizedBox(height: 8),
                        Row(children: [Expanded(child: tiles[2]), const SizedBox(width: 8), Expanded(child: tiles[3])]),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sales List
          if (customer.sales.isEmpty)
            const AppCard(
              child: EmptyView(message: 'لا توجد مبيعات لهذا المشتري', inCard: false),
            )
          else
            ...customer.sales.map((sale) => _buildSaleCard(customer, sale, ctrl, settings)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimens.borderLg,
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.xxlBold(textCol)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.sm(AppColors.gray600)),
        ],
      ),
    );
  }

  Widget _buildSaleCard(
    CustomerDetail customer,
    CustomerDetailSale sale,
    CustomerDetailsController ctrl,
    dynamic settings,
  ) {
    final isCompleted = sale.status == 'completed';
    final hasLate = sale.lateCount > 0;
    final isToggled = ctrl.displayCurrency[sale.id] == 'OTHER';

    final totalDisplay = _getDisplayAmount(sale.totalPrice, sale.currency, sale.id, ctrl, settings);
    final downDisplay = _getDisplayAmount(sale.downPayment, sale.currency, sale.id, ctrl, settings);
    final paidDisplay = _getDisplayAmount(sale.paidAmount + sale.downPayment, sale.currency, sale.id, ctrl, settings);
    final remainingDisplay = _getDisplayAmount(sale.remaining - sale.paidAmount, sale.currency, sale.id, ctrl, settings);
    final sym = _getDisplaySymbol(sale.currency, sale.id, ctrl, settings);

    final progressFraction = sale.installments.isNotEmpty
        ? (sale.paidCount / sale.installments.length).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: isCompleted ? AppColors.green300 : AppColors.gray200,
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('📦 ${sale.productName}', style: AppTextStyles.xlBold(AppColors.gray800)),
                      if (sale.quantity > 1) ...[
                        const SizedBox(width: 8),
                        AppBadge(label: '× ${sale.quantity}', variant: AppBadgeVariant.info),
                      ],
                      const SizedBox(width: 8),
                      if (isCompleted)
                        const AppBadge(label: '✅ مكتمل', variant: AppBadgeVariant.success)
                      else if (hasLate)
                        const AppBadge(label: '⚠️ متأخر', variant: AppBadgeVariant.danger)
                      else
                        const AppBadge(label: '🔄 نشط', variant: AppBadgeVariant.info),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تاريخ البيع: ${DateFormatter.formatDateNumeric(sale.saleDate)}',
                    style: AppTextStyles.sm(AppColors.gray500),
                  ),
                ],
              );

              final buttonsSection = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: '🖨️ طباعة',
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                    onPressed: () => SalePdfService.printSale(
                      customer: customer,
                      sale: sale,
                      settings: settings,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: '💬 واتساب',
                    variant: AppButtonVariant.success,
                    size: AppButtonSize.small,
                    onPressed: () => _sendWhatsApp(customer, sale, settings),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: '💱 ${isToggled ? "الأصلية" : "تبديل"}',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                    onPressed: () => ctrl.toggleCurrency(sale.id),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    titleSection,
                    buttonsSection,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleSection,
                  const SizedBox(height: 12),
                  buttonsSection,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.gray200),
          const SizedBox(height: 16),

          // 4 summary boxes
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final b1 = _saleBox('السعر الكلي', '${MoneyFormatter.formatAmount(totalDisplay)} $sym', AppColors.gray50, AppColors.gray800);
              final b2 = _saleBox('المقدمة', '${MoneyFormatter.formatAmount(downDisplay)} $sym', AppColors.amber50, AppColors.amber700);
              final b3 = _saleBox('المدفوع', '${MoneyFormatter.formatAmount(paidDisplay)} $sym', AppColors.green50, AppColors.green700);
              final b4 = _saleBox('المتبقي', '${MoneyFormatter.formatAmount(remainingDisplay)} $sym', AppColors.blue50, AppColors.blue700);

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: b1),
                    const SizedBox(width: 8),
                    Expanded(child: b2),
                    const SizedBox(width: 8),
                    Expanded(child: b3),
                    const SizedBox(width: 8),
                    Expanded(child: b4),
                  ],
                );
              }
              return Column(
                children: [
                  Row(children: [Expanded(child: b1), const SizedBox(width: 8), Expanded(child: b2)]),
                  const SizedBox(height: 8),
                  Row(children: [Expanded(child: b3), const SizedBox(width: 8), Expanded(child: b4)]),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التقدم', style: AppTextStyles.sm(AppColors.gray600)),
                  Text(
                    '${sale.paidCount} / ${sale.installments.length} قسط',
                    style: AppTextStyles.smBold(AppColors.gray800),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: AppDimens.borderFull,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: progressFraction,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: AppDimens.borderFull,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Installments Table
          AppTable(
            minWidth: 600,
            columns: const [
              AppTableColumn(title: '#', width: 48),
              AppTableColumn(title: 'تاريخ الاستحقاق'),
              AppTableColumn(title: 'المبلغ'),
              AppTableColumn(title: 'الحالة'),
              AppTableColumn(title: 'تاريخ الدفع'),
              AppTableColumn(title: 'الإجراءات', width: 90),
            ],
            rows: sale.installments.map((inst) {
              final isPaid = inst.status == 'paid';
              final isLate = inst.status == 'late';
              final instAmount = _getDisplayAmount(inst.amount, sale.currency, sale.id, ctrl, settings);

              return AppTableRow(
                backgroundColor: isPaid
                    ? AppColors.green50
                    : isLate
                        ? AppColors.red50
                        : null,
                cells: [
                  AppTableCell(child: Text('${inst.installmentNumber}', style: AppTextStyles.baseBold(AppColors.gray800))),
                  AppTableCell(child: Text(DateFormatter.formatDateShort(inst.dueDate))),
                  AppTableCell(
                    child: Text(
                      '${MoneyFormatter.formatAmount(instAmount)} $sym',
                      style: AppTextStyles.baseBold(AppColors.gray800),
                    ),
                  ),
                  AppTableCell(
                    child: isPaid
                        ? const AppBadge(label: '✅ مدفوع', variant: AppBadgeVariant.success)
                        : isLate
                            ? const AppBadge(label: '⚠️ متأخر', variant: AppBadgeVariant.danger)
                            : const AppBadge(label: '⏳ قادم', variant: AppBadgeVariant.info),
                  ),
                  AppTableCell(
                    child: Text(
                      inst.paidDate != null ? DateFormatter.formatDateShort(inst.paidDate!) : '-',
                      style: AppTextStyles.sm(AppColors.gray600),
                    ),
                  ),
                  AppTableCell(
                    child: !isPaid
                        ? Material(
                            color: AppColors.green600,
                            borderRadius: AppDimens.borderSm,
                            child: InkWell(
                              onTap: () => _payInstallment(inst.id),
                              borderRadius: AppDimens.borderSm,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text('💵 دفع', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )
                        : Material(
                            color: AppColors.gray500,
                            borderRadius: AppDimens.borderSm,
                            child: InkWell(
                              onTap: () => _unpayInstallment(inst.id),
                              borderRadius: AppDimens.borderSm,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text('↩️ إلغاء', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                  ),
                ],
              );
            }).toList(),
          ),

          // Notes
          if (sale.notes != null && sale.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.yellow50,
                border: const Border(
                  right: BorderSide(color: AppColors.amber400, width: 4),
                ),
                borderRadius: AppDimens.borderSm,
              ),
              child: Text(
                '📝 ${sale.notes}',
                style: AppTextStyles.sm(AppColors.gray700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _saleBox(String label, String value, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimens.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.xs(AppColors.gray600)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.lgBold(textCol)),
        ],
      ),
    );
  }
}
