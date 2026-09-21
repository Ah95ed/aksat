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
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/state/view_state.dart';
import '../../../reports/domain/entities/report_result.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final settingsCtrl = context.watch<SettingsController>();
    final settings = settingsCtrl.settings;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppDimens.breakpointMd;
    final isDesktop = screenWidth >= AppDimens.breakpointLg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title: 🏠 لوحة التحكم
        Text(
          '🏠 لوحة التحكم',
          style: AppTextStyles.xxxlBold(AppColors.gray800),
        ),
        const SizedBox(height: 24),

        if (controller.state.isLoading && controller.summary == null)
          const LoadingView(message: 'جاري التحميل...')
        else if (controller.state.isError && controller.summary == null)
          AppCard(
            child: Column(
              children: [
                Text(
                  controller.errorMessage ?? 'تعذر تحميل البيانات',
                  style: AppTextStyles.base(AppColors.danger),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'إعادة المحاولة',
                  variant: AppButtonVariant.primary,
                  onPressed: controller.load,
                ),
              ],
            ),
          )
        else if (controller.summary != null) ...[
          _buildContent(
            context: context,
            summary: controller.summary!,
            profit: controller.monthlyProfit,
            settingsLocalSymbol: settings.currencySymbol,
            settingsLocalName: settings.currencyName,
            isMobile: isMobile,
            isDesktop: isDesktop,
          ),
        ],
      ],
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required dynamic summary,
    required dynamic profit,
    required String settingsLocalSymbol,
    required String settingsLocalName,
    required bool isMobile,
    required bool isDesktop,
  }) {
    // 1. Month Profit Card (if expected_profit > 0)
    double extractExpectedProfit(dynamic p, String currency) {
      if (p == null) return 0.0;
      dynamic map;
      if (p is ReportResult) {
        map = p.data;
      } else if (p is Map) {
        map = p;
      }
      if (map is Map) {
        final curData = map[currency] ?? map[currency.toLowerCase()];
        if (curData is Map) {
          return toNum(curData['expected_profit'] ?? curData['expectedProfit']);
        }
      }
      return 0.0;
    }

    final usdProfit = extractExpectedProfit(profit, 'USD');
    final localProfit = extractExpectedProfit(profit, 'LOCAL');
    final showProfitCard = usdProfit > 0 || localProfit > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showProfitCard) ...[
          AppCard(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [AppColors.green500, AppColors.emerald600],
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💰 ربح هذا الشهر (المتوقع)',
                        style: AppTextStyles.sm(AppColors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 4),
                      if (usdProfit > 0)
                        Text(
                          '\$${MoneyFormatter.formatAmount(usdProfit)}',
                          style: AppTextStyles.xxlBold(AppColors.white),
                        ),
                      if (localProfit > 0)
                        Text(
                          '${MoneyFormatter.formatAmount(localProfit)} ${MoneyFormatter.currencySymbol('LOCAL', settingsLocalSymbol)}',
                          style: AppTextStyles.xxlBold(AppColors.white),
                        ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: '📊 التقارير ←',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => widget.onNavigate('/reports'),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💰 ربح هذا الشهر (المتوقع)',
                            style: AppTextStyles.sm(AppColors.white.withValues(alpha: 0.9)),
                          ),
                          const SizedBox(height: 4),
                          if (usdProfit > 0)
                            Text(
                              '\$${MoneyFormatter.formatAmount(usdProfit)}',
                              style: AppTextStyles.xxxlBold(AppColors.white),
                            ),
                          if (localProfit > 0)
                            Text(
                              '${MoneyFormatter.formatAmount(localProfit)} ${MoneyFormatter.currencySymbol('LOCAL', settingsLocalSymbol)}',
                              style: AppTextStyles.xxxlBold(AppColors.white),
                            ),
                        ],
                      ),
                      AppButton(
                        text: '📊 التقارير ←',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => widget.onNavigate('/reports'),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
        ],

        // 2. Four Main Cards
        GridView.count(
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 1.2 : 1.3,
          children: [
            _buildStatCard(
              emoji: '👥',
              number: '${summary.totalCustomers}',
              label: 'مشتري',
              fromColor: AppColors.blue500,
              toColor: AppColors.blue700,
            ),
            _buildStatCard(
              emoji: '📦',
              number: '${summary.totalProducts}',
              label: 'مادة',
              fromColor: AppColors.green500,
              toColor: AppColors.green700,
            ),
            _buildStatCard(
              emoji: '📋',
              number: '${summary.activeSales}',
              label: 'بيع نشط',
              fromColor: AppColors.amber500,
              toColor: AppColors.amber700,
            ),
            _buildStatCard(
              emoji: '✅',
              number: '${summary.completedSales}',
              label: 'بيع مكتمل',
              fromColor: AppColors.purple500,
              toColor: AppColors.purple700,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 3. Three Amount Cards (المحصل، المتبقي، المتأخرات)
        if (isMobile)
          Column(
            children: [
              _buildAmountCard(
                title: '💰 المحصل',
                titleColor: AppColors.gray800,
                usdAmount: summary.collected['USD'] ?? 0.0,
                localAmount: summary.collected['LOCAL'] ?? 0.0,
                rowBg: AppColors.green50,
                amountColor: AppColors.green700,
                settingsLocalSymbol: settingsLocalSymbol,
                settingsLocalName: settingsLocalName,
              ),
              const SizedBox(height: 16),
              _buildAmountCard(
                title: '⏳ المتبقي',
                titleColor: AppColors.gray800,
                usdAmount: summary.remaining['USD'] ?? 0.0,
                localAmount: summary.remaining['LOCAL'] ?? 0.0,
                rowBg: AppColors.blue50,
                amountColor: AppColors.blue700,
                settingsLocalSymbol: settingsLocalSymbol,
                settingsLocalName: settingsLocalName,
              ),
              const SizedBox(height: 16),
              _buildAmountCard(
                title: '⚠️ المتأخرات (${summary.lateInstallments})',
                titleColor: AppColors.red700,
                usdAmount: summary.lateAmount['USD'] ?? 0.0,
                localAmount: summary.lateAmount['LOCAL'] ?? 0.0,
                rowBg: AppColors.red50,
                amountColor: AppColors.red700,
                border: Border.all(color: AppColors.red200, width: 2),
                settingsLocalSymbol: settingsLocalSymbol,
                settingsLocalName: settingsLocalName,
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAmountCard(
                  title: '💰 المحصل',
                  titleColor: AppColors.gray800,
                  usdAmount: summary.collected['USD'] ?? 0.0,
                  localAmount: summary.collected['LOCAL'] ?? 0.0,
                  rowBg: AppColors.green50,
                  amountColor: AppColors.green700,
                  settingsLocalSymbol: settingsLocalSymbol,
                  settingsLocalName: settingsLocalName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAmountCard(
                  title: '⏳ المتبقي',
                  titleColor: AppColors.gray800,
                  usdAmount: summary.remaining['USD'] ?? 0.0,
                  localAmount: summary.remaining['LOCAL'] ?? 0.0,
                  rowBg: AppColors.blue50,
                  amountColor: AppColors.blue700,
                  settingsLocalSymbol: settingsLocalSymbol,
                  settingsLocalName: settingsLocalName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAmountCard(
                  title: '⚠️ المتأخرات (${summary.lateInstallments})',
                  titleColor: AppColors.red700,
                  usdAmount: summary.lateAmount['USD'] ?? 0.0,
                  localAmount: summary.lateAmount['LOCAL'] ?? 0.0,
                  rowBg: AppColors.red50,
                  amountColor: AppColors.red700,
                  border: Border.all(color: AppColors.red200, width: 2),
                  settingsLocalSymbol: settingsLocalSymbol,
                  settingsLocalName: settingsLocalName,
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),

        // 4. Upcoming Installments Cards (Week & Month)
        if (isMobile)
          Column(
            children: [
              _buildUpcomingCard(
                title: '📅 أقساط هذا الأسبوع (${summary.upcomingWeek.count})',
                titleColor: AppColors.amber800,
                textColor: AppColors.amber900,
                usdAmount: summary.upcomingWeek.usd,
                localAmount: summary.upcomingWeek.local,
                fromColor: AppColors.amber50,
                toColor: AppColors.amber100,
                borderColor: AppColors.amber200,
                settingsLocalSymbol: settingsLocalSymbol,
                settingsLocalName: settingsLocalName,
                onTap: () => widget.onNavigate('/upcoming'),
              ),
              const SizedBox(height: 16),
              _buildUpcomingCard(
                title: '📆 أقساط هذا الشهر (${summary.upcomingMonth.count})',
                titleColor: AppColors.blue800,
                textColor: AppColors.blue900,
                usdAmount: summary.upcomingMonth.usd,
                localAmount: summary.upcomingMonth.local,
                fromColor: AppColors.blue50,
                toColor: AppColors.blue100,
                borderColor: AppColors.blue200,
                settingsLocalSymbol: settingsLocalSymbol,
                settingsLocalName: settingsLocalName,
                onTap: () => widget.onNavigate('/upcoming'),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildUpcomingCard(
                  title: '📅 أقساط هذا الأسبوع (${summary.upcomingWeek.count})',
                  titleColor: AppColors.amber800,
                  textColor: AppColors.amber900,
                  usdAmount: summary.upcomingWeek.usd,
                  localAmount: summary.upcomingWeek.local,
                  fromColor: AppColors.amber50,
                  toColor: AppColors.amber100,
                  borderColor: AppColors.amber200,
                  settingsLocalSymbol: settingsLocalSymbol,
                  settingsLocalName: settingsLocalName,
                  onTap: () => widget.onNavigate('/upcoming'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUpcomingCard(
                  title: '📆 أقساط هذا الشهر (${summary.upcomingMonth.count})',
                  titleColor: AppColors.blue800,
                  textColor: AppColors.blue900,
                  usdAmount: summary.upcomingMonth.usd,
                  localAmount: summary.upcomingMonth.local,
                  fromColor: AppColors.blue50,
                  toColor: AppColors.blue100,
                  borderColor: AppColors.blue200,
                  settingsLocalSymbol: settingsLocalSymbol,
                  settingsLocalName: settingsLocalName,
                  onTap: () => widget.onNavigate('/upcoming'),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),

        // 5. Stock Alerts (if any)
        if (summary.lowStockItems.isNotEmpty) ...[
          AppCard(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.amber50, AppColors.red50],
            ),
            border: Border.all(color: AppColors.amber300, width: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⚠️ تنبيهات المخزون (${summary.lowStockItems.length})',
                      style: AppTextStyles.lgBold(AppColors.amber800),
                    ),
                    GestureDetector(
                      onTap: () => widget.onNavigate('/inventory'),
                      child: Text(
                        'إدارة المخزن ←',
                        style: AppTextStyles.smMedium(AppColors.amber700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : (isMobile ? 1 : 2),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: summary.lowStockItems.length,
                  itemBuilder: (ctx, i) {
                    final item = summary.lowStockItems[i];
                    final isOutOfStock = item.quantity <= 0;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppDimens.borderLg,
                        border: isOutOfStock
                            ? Border.all(color: AppColors.red300, width: 2)
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTextStyles.smMedium(AppColors.gray800),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'حد التنبيه: ${item.lowStockThreshold}',
                                  style: AppTextStyles.xs(AppColors.gray500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOutOfStock ? AppColors.red100 : AppColors.amber100,
                              borderRadius: AppDimens.borderLg,
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.xxlBold(
                                isOutOfStock ? AppColors.red700 : AppColors.amber700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 6. Top Products & Recent Sales
        if (isMobile)
          Column(
            children: [
              _buildTopProductsCard(summary.topProducts),
              const SizedBox(height: 16),
              _buildRecentSalesCard(summary.recentSales, settingsLocalSymbol),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTopProductsCard(summary.topProducts)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRecentSalesCard(
                  summary.recentSales,
                  settingsLocalSymbol,
                ),
              ),
            ],
          ),
        const SizedBox(height: 32),

        // 7. Logout Button
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton(
            text: 'تسجيل الخروج',
            variant: AppButtonVariant.danger,
            onPressed: widget.onLogout,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String number,
    required String label,
    required Color fromColor,
    required Color toColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fromColor, toColor],
        ),
        borderRadius: AppDimens.border2Xl,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.p6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: AppTextStyles.xxxlBold(AppColors.white),
              ),
              Text(
                label,
                style: AppTextStyles.sm(AppColors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard({
    required String title,
    required Color titleColor,
    required double usdAmount,
    required double localAmount,
    required Color rowBg,
    required Color amountColor,
    required String settingsLocalSymbol,
    required String settingsLocalName,
    BoxBorder? border,
  }) {
    return AppCard(
      border: border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.lgBold(titleColor),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rowBg,
              borderRadius: AppDimens.borderLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('دولار', style: AppTextStyles.sm(AppColors.gray600)),
                Text(
                  '\$${MoneyFormatter.formatAmount(usdAmount)}',
                  style: AppTextStyles.xlBold(amountColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rowBg,
              borderRadius: AppDimens.borderLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  MoneyFormatter.currencyName('LOCAL', settingsLocalName),
                  style: AppTextStyles.sm(AppColors.gray600),
                ),
                Text(
                  '${MoneyFormatter.formatAmount(localAmount)} ${MoneyFormatter.currencySymbol('LOCAL', settingsLocalSymbol)}',
                  style: AppTextStyles.xlBold(amountColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard({
    required String title,
    required Color titleColor,
    required Color textColor,
    required double usdAmount,
    required double localAmount,
    required Color fromColor,
    required Color toColor,
    required Color borderColor,
    required String settingsLocalSymbol,
    required String settingsLocalName,
    required VoidCallback onTap,
  }) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [fromColor, toColor],
      ),
      border: Border.all(color: borderColor, width: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.lgBold(titleColor),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('دولار:', style: AppTextStyles.base(textColor)),
              Text(
                '\$${MoneyFormatter.formatAmount(usdAmount)}',
                style: AppTextStyles.baseBold(textColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${MoneyFormatter.currencyName('LOCAL', settingsLocalName)}:',
                style: AppTextStyles.base(textColor),
              ),
              Text(
                '${MoneyFormatter.formatAmount(localAmount)} ${MoneyFormatter.currencySymbol('LOCAL', settingsLocalSymbol)}',
                style: AppTextStyles.baseBold(textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                'عرض التفاصيل ←',
                style: AppTextStyles.baseMedium(titleColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsCard(List<dynamic> topProducts) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🏆 أكثر المواد مبيعاً',
            style: AppTextStyles.lgBold(AppColors.gray800),
          ),
          const SizedBox(height: 16),
          if (topProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'لا توجد بيانات بعد',
                style: AppTextStyles.base(AppColors.gray500),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...List.generate(topProducts.length, (i) {
              final p = topProducts[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: AppDimens.borderLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${i + 1}. ${p.productName}',
                      style: AppTextStyles.baseMedium(AppColors.gray800),
                    ),
                    AppBadge(
                      text: '${p.salesCount} بيع',
                      variant: AppBadgeVariant.info,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentSalesCard(List<dynamic> recentSales, String localSymbol) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🆕 آخر العمليات',
            style: AppTextStyles.lgBold(AppColors.gray800),
          ),
          const SizedBox(height: 16),
          if (recentSales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'لا توجد عمليات بعد',
                style: AppTextStyles.base(AppColors.gray500),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...recentSales.map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: AppDimens.borderLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.customerName,
                          style: AppTextStyles.baseMedium(AppColors.gray800),
                        ),
                        Text(
                          s.productName,
                          style: AppTextStyles.sm(AppColors.gray600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${MoneyFormatter.formatAmount(s.totalPrice)} ${MoneyFormatter.currencySymbol(s.currency, localSymbol)}',
                          style: AppTextStyles.baseBold(AppColors.green700),
                        ),
                        Text(
                          DateFormatter.formatDateShort(s.createdAt),
                          style: AppTextStyles.xs(AppColors.gray500),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
