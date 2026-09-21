import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_spinner.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/state/view_state.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/reports_controller.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsController>().loadAll();
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller, bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      if (!mounted) return;
      final ymd = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.text = ymd;
      final ctrl = context.read<ReportsController>();
      if (isFrom) {
        ctrl.setCustomDates(ymd, _toController.text);
      } else {
        ctrl.setCustomDates(_fromController.text, ymd);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ReportsController>();
    final settingsCtrl = context.watch<SettingsController>();
    final settings = settingsCtrl.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.white : AppColors.gray800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          '📊 التقارير والأرباح',
          style: AppTextStyles.xxxlBold(titleColor),
        ),
        const SizedBox(height: 24),

          // Filters Card
          AppCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الفترة الزمنية', style: AppTextStyles.smBold(AppColors.gray700)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: AppDimens.borderMd,
                                  border: Border.all(color: AppColors.gray300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: ctrl.period,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(value: 'today', child: Text('اليوم')),
                                      DropdownMenuItem(value: 'week', child: Text('آخر 7 أيام')),
                                      DropdownMenuItem(value: 'month', child: Text('هذا الشهر')),
                                      DropdownMenuItem(value: 'last_month', child: Text('الشهر الماضي')),
                                      DropdownMenuItem(value: 'year', child: Text('هذه السنة')),
                                      DropdownMenuItem(value: 'all', child: Text('كل الوقت')),
                                      DropdownMenuItem(value: 'custom', child: Text('فترة مخصصة')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) ctrl.setPeriod(val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (ctrl.period != 'custom') ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('العملة', style: AppTextStyles.smBold(AppColors.gray700)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: AppDimens.borderMd,
                                    border: Border.all(color: AppColors.gray300),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: ctrl.currency,
                                      isExpanded: true,
                                      items: [
                                        const DropdownMenuItem(value: 'all', child: Text('كل العملات')),
                                        const DropdownMenuItem(value: 'USD', child: Text('دولار 💵')),
                                        DropdownMenuItem(
                                          value: 'LOCAL',
                                          child: Text(
                                            '${MoneyFormatter.currencyName('LOCAL', settings)} 🪙',
                                          ),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) ctrl.setCurrency(val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (ctrl.period == 'custom') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('من تاريخ', style: AppTextStyles.smBold(AppColors.gray700)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _pickDate(_fromController, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: AppDimens.borderMd,
                                      border: Border.all(color: AppColors.gray300),
                                    ),
                                    child: Text(
                                      _fromController.text.isEmpty ? 'اختر التاريخ' : _fromController.text,
                                      style: AppTextStyles.base(AppColors.gray800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('إلى تاريخ', style: AppTextStyles.smBold(AppColors.gray700)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _pickDate(_toController, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: AppDimens.borderMd,
                                      border: Border.all(color: AppColors.gray300),
                                    ),
                                    child: Text(
                                      _toController.text.isEmpty ? 'اختر التاريخ' : _toController.text,
                                      style: AppTextStyles.base(AppColors.gray800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Tabs Card
          AppCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tabButton('summary', '💰', 'ملخص الأرباح', ctrl),
                  const SizedBox(width: 8),
                  _tabButton('by_product', '📦', 'ربح كل مادة', ctrl),
                  const SizedBox(width: 8),
                  _tabButton('top_selling', '🏆', 'أكثر مبيعاً', ctrl),
                  const SizedBox(width: 8),
                  _tabButton('timeline', '📈', 'الأرباح حسب الفترة', ctrl),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          if (ctrl.state == ViewState.loading && ctrl.summary == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: AppSpinner(size: 40)),
            )
          else if (ctrl.state == ViewState.error && ctrl.summary == null)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                    const SizedBox(height: 12),
                    Text(
                      ctrl.errorMessage ?? 'تعذر تحميل التقارير',
                      style: AppTextStyles.baseMedium(AppColors.gray700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'إعادة المحاولة',
                      variant: AppButtonVariant.primary,
                      onPressed: () => ctrl.loadAll(),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (ctrl.activeTab == 'summary') _buildSummaryTab(ctrl, settings),
            if (ctrl.activeTab == 'by_product') _buildByProductTab(ctrl, settings),
            if (ctrl.activeTab == 'top_selling') _buildTopSellingTab(ctrl, settings),
            if (ctrl.activeTab == 'timeline') _buildTimelineTab(ctrl, settings),
          ],
          const SizedBox(height: 32),
        ],
      );
  }

  Widget _tabButton(String tabId, String icon, String label, ReportsController ctrl) {
    final active = ctrl.activeTab == tabId;
    return Material(
      color: active ? AppColors.blue600 : AppColors.gray100,
      borderRadius: AppDimens.borderLg,
      child: InkWell(
        onTap: () => ctrl.setActiveTab(tabId),
        borderRadius: AppDimens.borderLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            '$icon $label',
            style: AppTextStyles.baseMedium(active ? AppColors.white : AppColors.gray700),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab(ReportsController ctrl, dynamic settings) {
    final summary = ctrl.summary;
    if (summary == null) {
      return const AppCard(
        child: EmptyView(message: 'لا توجد بيانات', inCard: false),
      );
    }

    final usdData = summary['USD'] is Map
        ? Map<String, dynamic>.from((summary['USD'] as Map).map((k, v) => MapEntry(k.toString(), v)))
        : <String, dynamic>{};
    final localData = summary['LOCAL'] is Map
        ? Map<String, dynamic>.from((summary['LOCAL'] as Map).map((k, v) => MapEntry(k.toString(), v)))
        : <String, dynamic>{};

    final usdSales = toInt(usdData['sales_count']);
    final localSales = toInt(localData['sales_count']);

    if (usdSales == 0 && localSales == 0) {
      return const AppCard(
        child: EmptyView(message: 'لا توجد مبيعات في هذه الفترة', inCard: false),
      );
    }

    return Column(
      children: [
        if (usdSales > 0) _buildCurrencySummaryCard('USD', '💵 الدولار', usdData, settings),
        if (usdSales > 0 && localSales > 0) const SizedBox(height: 16),
        if (localSales > 0)
          _buildCurrencySummaryCard(
            'LOCAL',
            '🪙 ${MoneyFormatter.currencyName('LOCAL', settings)}',
            localData,
            settings,
          ),
      ],
    );
  }

  Widget _buildCurrencySummaryCard(
    String cur,
    String title,
    Map<String, dynamic> data,
    dynamic settings,
  ) {
    final salesCount = toInt(data['sales_count']);
    final itemsSold = toInt(data['items_sold']);
    final totalRevenue = toNum(data['total_revenue']);
    final totalCost = toNum(data['total_cost']);
    final expectedProfit = toNum(data['expected_profit']);
    final actualProfit = toNum(data['actual_profit']);
    final totalCollected = toNum(data['total_collected']);
    final sym = cur == 'USD' ? '\$' : MoneyFormatter.currencySymbol('LOCAL', settings);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.xlBold(AppColors.gray800)),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.gray200),
          const SizedBox(height: 16),

          // 4 stats tiles
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final tiles = [
                _miniStat('عدد المبيعات', '$salesCount', AppColors.blue50, AppColors.blue700),
                _miniStat('عدد القطع', '$itemsSold', AppColors.indigo50, AppColors.indigo700),
                _miniStat(
                  'إجمالي الإيرادات',
                  '${MoneyFormatter.formatAmount(totalRevenue)} $sym',
                  AppColors.purple50,
                  AppColors.purple700,
                ),
                _miniStat(
                  'إجمالي التكلفة',
                  '${MoneyFormatter.formatAmount(totalCost)} $sym',
                  AppColors.amber50,
                  AppColors.amber700,
                ),
              ];

              if (isWide) {
                return Row(
                  children: tiles.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: t))).toList(),
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: tiles[0]),
                      const SizedBox(width: 8),
                      Expanded(child: tiles[1]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: tiles[2]),
                      const SizedBox(width: 8),
                      Expanded(child: tiles[3]),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // 2 profit cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final expectedCard = Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppDimens.borderLg,
                  border: Border.all(color: AppColors.green300, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💰 الربح المتوقع (كل المبيعات)', style: AppTextStyles.smMedium(AppColors.gray700)),
                    const SizedBox(height: 8),
                    Text(
                      '${MoneyFormatter.formatAmount(expectedProfit)} $sym',
                      style: AppTextStyles.xxxlBold(AppColors.green700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هامش الربح: ${MoneyFormatter.profitMargin(expectedProfit, totalRevenue)}%',
                      style: AppTextStyles.xs(AppColors.gray600),
                    ),
                  ],
                ),
              );

              final actualCard = Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppDimens.borderLg,
                  border: Border.all(color: AppColors.blue300, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✅ الربح الفعلي (المُحصَّل)', style: AppTextStyles.smMedium(AppColors.gray700)),
                    const SizedBox(height: 8),
                    Text(
                      '${MoneyFormatter.formatAmount(actualProfit)} $sym',
                      style: AppTextStyles.xxxlBold(AppColors.blue700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'من إجمالي ${MoneyFormatter.formatAmount(totalCollected)} $sym مُحصَّل',
                      style: AppTextStyles.xs(AppColors.gray600),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: expectedCard),
                    const SizedBox(width: 16),
                    Expanded(child: actualCard),
                  ],
                );
              }
              return Column(
                children: [
                  expectedCard,
                  const SizedBox(height: 12),
                  actualCard,
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Explanatory note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: AppDimens.borderSm,
            ),
            child: Text(
              '💡 الربح المتوقع: يحسب جميع المبيعات حتى لو لم تُدفع جميع الأقساط\n💡 الربح الفعلي: يحسب الجزء المُحصَّل فعلياً (نسبة من المتوقع)',
              style: AppTextStyles.xs(AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color bg, Color textCol) {
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
          Text(value, style: AppTextStyles.xlBold(textCol)),
        ],
      ),
    );
  }

  Widget _buildByProductTab(ReportsController ctrl, dynamic settings) {
    final list = ctrl.byProduct;
    if (list.isEmpty) {
      return const AppCard(child: EmptyView(message: 'لا توجد بيانات', inCard: false));
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: AppTable(
        minWidth: 700,
        columns: const [
          AppTableColumn(title: '#', width: 48),
          AppTableColumn(title: 'المادة'),
          AppTableColumn(title: 'الكمية المباعة'),
          AppTableColumn(title: 'إيرادات'),
          AppTableColumn(title: 'تكلفة'),
          AppTableColumn(title: 'الربح'),
          AppTableColumn(title: 'الهامش'),
          AppTableColumn(title: 'العملة'),
        ],
        rows: list.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final expectedProfit = toNum(p['expected_profit']);
          final totalRevenue = toNum(p['total_revenue']);
          final totalCost = toNum(p['total_cost']);
          final cur = toStr(p['currency']);
          final sym = cur == 'USD' ? '\$' : MoneyFormatter.currencySymbol('LOCAL', settings);

          return AppTableRow(
            cells: [
              AppTableCell(child: Text('${i + 1}')),
              AppTableCell(child: Text(toStr(p['product_name']), style: AppTextStyles.baseMedium(AppColors.gray800))),
              AppTableCell(child: Text('${toInt(p['total_quantity'])}')),
              AppTableCell(child: Text(MoneyFormatter.formatAmount(totalRevenue), style: AppTextStyles.base(AppColors.purple700))),
              AppTableCell(child: Text(MoneyFormatter.formatAmount(totalCost), style: AppTextStyles.base(AppColors.amber700))),
              AppTableCell(
                child: Text(
                  MoneyFormatter.formatAmount(expectedProfit),
                  style: AppTextStyles.baseBold(expectedProfit >= 0 ? AppColors.green700 : AppColors.red700),
                ),
              ),
              AppTableCell(child: Text('${MoneyFormatter.profitMargin(expectedProfit, totalRevenue)}%')),
              AppTableCell(
                child: AppBadge(
                  label: sym,
                  variant: cur == 'USD' ? AppBadgeVariant.info : AppBadgeVariant.warning,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopSellingTab(ReportsController ctrl, dynamic settings) {
    final list = ctrl.topSelling;
    if (list.isEmpty) {
      return const AppCard(child: EmptyView(message: 'لا توجد بيانات', inCard: false));
    }

    return AppCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final p = list[i];
          final rank = i == 0
              ? '🥇'
              : i == 1
                  ? '🥈'
                  : i == 2
                      ? '🥉'
                      : '#${i + 1}';
          final isTop3 = i < 3;
          final cur = toStr(p['currency']);
          final sym = cur == 'USD' ? '\$' : MoneyFormatter.currencySymbol('LOCAL', settings);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTop3 ? null : AppColors.gray50,
              gradient: isTop3
                  ? const LinearGradient(
                      colors: [Color(0xFFFEFCE8), Color(0xFFFFF7ED)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    )
                  : null,
              border: isTop3 ? Border.all(color: AppColors.yellow300, width: 2) : null,
              borderRadius: AppDimens.borderLg,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    rank,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: isTop3 ? 28 : 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(toStr(p['product_name']), style: AppTextStyles.lgBold(AppColors.gray800)),
                      const SizedBox(height: 4),
                      Text(
                        '${toInt(p['sales_count'])} عملية بيع • ${toInt(p['total_quantity'])} قطعة',
                        style: AppTextStyles.sm(AppColors.gray600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الربح', style: AppTextStyles.xs(AppColors.gray500)),
                    const SizedBox(height: 2),
                    Text(
                      '${MoneyFormatter.formatAmount(toNum(p['expected_profit']))} $sym',
                      style: AppTextStyles.baseBold(AppColors.green700),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineTab(ReportsController ctrl, dynamic settings) {
    final list = ctrl.timeline;

    return Column(
      children: [
        // Group by buttons
        Row(
          children: [
            _groupByBtn('day', 'يومي', ctrl),
            const SizedBox(width: 8),
            _groupByBtn('week', 'أسبوعي', ctrl),
            const SizedBox(width: 8),
            _groupByBtn('month', 'شهري', ctrl),
            const SizedBox(width: 8),
            _groupByBtn('year', 'سنوي', ctrl),
          ],
        ),
        const SizedBox(height: 12),

        if (list.isEmpty)
          const AppCard(child: EmptyView(message: 'لا توجد بيانات', inCard: false))
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: AppTable(
              minWidth: 700,
              columns: const [
                AppTableColumn(title: 'الفترة'),
                AppTableColumn(title: 'عدد المبيعات'),
                AppTableColumn(title: 'القطع المباعة'),
                AppTableColumn(title: 'الإيرادات'),
                AppTableColumn(title: 'التكلفة'),
                AppTableColumn(title: 'الربح'),
                AppTableColumn(title: 'العملة'),
              ],
              rows: list.map((t) {
                final cur = toStr(t['currency']);
                final sym = cur == 'USD' ? '\$' : MoneyFormatter.currencySymbol('LOCAL', settings);
                final expectedProfit = toNum(t['expected_profit']);

                return AppTableRow(
                  cells: [
                    AppTableCell(child: Text(DateFormatter.formatPeriod(toStr(t['period'])), style: AppTextStyles.baseMedium(AppColors.gray800))),
                    AppTableCell(child: Text('${toInt(t['sales_count'])}')),
                    AppTableCell(child: Text('${toInt(t['items_sold'])}')),
                    AppTableCell(child: Text(MoneyFormatter.formatAmount(toNum(t['total_revenue'])), style: AppTextStyles.base(AppColors.purple700))),
                    AppTableCell(child: Text(MoneyFormatter.formatAmount(toNum(t['total_cost'])), style: AppTextStyles.base(AppColors.amber700))),
                    AppTableCell(
                      child: Text(
                        MoneyFormatter.formatAmount(expectedProfit),
                        style: AppTextStyles.baseBold(expectedProfit >= 0 ? AppColors.green700 : AppColors.red700),
                      ),
                    ),
                    AppTableCell(
                      child: AppBadge(
                        label: sym,
                        variant: cur == 'USD' ? AppBadgeVariant.info : AppBadgeVariant.warning,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _groupByBtn(String key, String label, ReportsController ctrl) {
    final active = ctrl.groupBy == key;
    return Material(
      color: active ? AppColors.blue600 : AppColors.gray100,
      borderRadius: AppDimens.borderMd,
      child: InkWell(
        onTap: () => ctrl.setGroupBy(key),
        borderRadius: AppDimens.borderMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: AppTextStyles.smMedium(active ? AppColors.white : AppColors.gray700),
          ),
        ),
      ),
    );
  }
}
