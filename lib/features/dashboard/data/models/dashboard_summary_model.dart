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
    required super.upcomingWeekCount,
    required super.upcomingMonthCount,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> money(dynamic value) {
      final source = value is Map ? value : const <String, dynamic>{};
      return {'USD': toNum(source['USD']), 'LOCAL': toNum(source['LOCAL'])};
    }

    final week = json['upcoming_week'] as Map<String, dynamic>? ?? const {};
    final month = json['upcoming_month'] as Map<String, dynamic>? ?? const {};
    return DashboardSummaryModel(
      totalCustomers: toInt(json['total_customers']),
      totalProducts: toInt(json['total_products']),
      activeSales: toInt(json['active_sales']),
      completedSales: toInt(json['completed_sales']),
      collected: money(json['collected']),
      remaining: money(json['remaining']),
      lateInstallments: toInt(json['late_installments']),
      lateAmount: money(json['late_amount']),
      upcomingWeekCount: toInt(week['count']),
      upcomingMonthCount: toInt(month['count']),
    );
  }
}
