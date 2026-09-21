class UpcomingBreakdown {
  const UpcomingBreakdown({
    required this.count,
    required this.usd,
    required this.local,
  });

  final int count;
  final double usd;
  final double local;
}

class TopProductItem {
  const TopProductItem({
    required this.productName,
    required this.salesCount,
  });

  final String productName;
  final int salesCount;
}

class RecentSaleItem {
  const RecentSaleItem({
    required this.id,
    required this.productName,
    required this.totalPrice,
    required this.currency,
    required this.createdAt,
    required this.customerName,
  });

  final int id;
  final String productName;
  final double totalPrice;
  final String currency;
  final String createdAt;
  final String customerName;
}

class LowStockItem {
  const LowStockItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.lowStockThreshold,
    required this.price,
    required this.currency,
  });

  final int productId;
  final String productName;
  final int quantity;
  final int lowStockThreshold;
  final double price;
  final String currency;
}

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
    required this.upcomingWeek,
    required this.upcomingMonth,
    required this.topProducts,
    required this.recentSales,
    required this.lowStockItems,
  });

  final int totalCustomers;
  final int totalProducts;
  final int activeSales;
  final int completedSales;
  final Map<String, double> collected;
  final Map<String, double> remaining;
  final int lateInstallments;
  final Map<String, double> lateAmount;
  final UpcomingBreakdown upcomingWeek;
  final UpcomingBreakdown upcomingMonth;
  final List<TopProductItem> topProducts;
  final List<RecentSaleItem> recentSales;
  final List<LowStockItem> lowStockItems;
}
