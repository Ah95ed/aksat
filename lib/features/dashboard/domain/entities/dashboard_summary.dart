class DashboardSummary {
  const DashboardSummary({
    required this.totalCustomers,
    required this.totalProducts,
    required this.activeSales,
    required this.completedSales,
    required this.collected,
    required this.remaining,
    required this.lateInstallments,
    required this.lateAmount,
    required this.upcomingWeekCount,
    required this.upcomingMonthCount,
  });

  final int totalCustomers;
  final int totalProducts;
  final int activeSales;
  final int completedSales;
  final Map<String, double> collected;
  final Map<String, double> remaining;
  final int lateInstallments;
  final Map<String, double> lateAmount;
  final int upcomingWeekCount;
  final int upcomingMonthCount;
}
