import '../../../../core/utils/parsers.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalCustomers,
    required super.totalProducts,
    required super.activeSales,
    required super.completedSales,
    required super.collected,
    required super.remaining,
    required super.lateInstallments,
    required super.lateAmount,
    required super.upcomingWeek,
    required super.upcomingMonth,
    required super.topProducts,
    required super.recentSales,
    required super.lowStockItems,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> money(dynamic value) {
      final source = value is Map ? value : const <String, dynamic>{};
      return {'USD': toNum(source['USD']), 'LOCAL': toNum(source['LOCAL'])};
    }

    UpcomingBreakdown parseUpcoming(dynamic value) {
      final source = value is Map ? value : const <String, dynamic>{};
      return UpcomingBreakdown(
        count: toInt(source['count']),
        usd: toNum(source['USD']),
        local: toNum(source['LOCAL']),
      );
    }

    final topList = (json['top_products'] as List<dynamic>? ?? const [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return TopProductItem(
            productName: toStr(m['product_name']),
            salesCount: toInt(m['sales_count']),
          );
        })
        .toList();

    final recentList = (json['recent_sales'] as List<dynamic>? ?? const [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return RecentSaleItem(
            id: toId(m['id']),
            productName: toStr(m['product_name']),
            totalPrice: toNum(m['total_price']),
            currency: toStr(m['currency']),
            createdAt: toStr(m['created_at']),
            customerName: toStr(m['customer_name']),
          );
        })
        .toList();

    final lowStockList = (json['low_stock_items'] as List<dynamic>? ?? const [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return LowStockItem(
            productId: toId(m['product_id']),
            productName: toStr(m['product_name']),
            quantity: toInt(m['quantity']),
            lowStockThreshold: toInt(m['low_stock_threshold']),
            price: toNum(m['price']),
            currency: toStr(m['currency']),
          );
        })
        .toList();

    return DashboardSummaryModel(
      totalCustomers: toInt(json['total_customers']),
      totalProducts: toInt(json['total_products']),
      activeSales: toInt(json['active_sales']),
      completedSales: toInt(json['completed_sales']),
      collected: money(json['collected']),
      remaining: money(json['remaining']),
      lateInstallments: toInt(json['late_installments']),
      lateAmount: money(json['late_amount']),
      upcomingWeek: parseUpcoming(json['upcoming_week']),
      upcomingMonth: parseUpcoming(json['upcoming_month']),
      topProducts: topList,
      recentSales: recentList,
      lowStockItems: lowStockList,
    );
  }
}
