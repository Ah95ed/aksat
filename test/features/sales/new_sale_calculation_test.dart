import 'package:aksat/core/utils/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewSale - Financial Calculations', () {
    test('calculates remaining amount after down payment', () {
      const double totalPrice = 1200.0;
      const double downPayment = 200.0;
      final remaining = (totalPrice - downPayment).clamp(0.0, double.infinity);
      expect(remaining, 1000.0);
    });

    test('calculates equal installment amount given remaining and count', () {
      const double remaining = 1000.0;
      const int installmentsCount = 10;
      final installmentValue = installmentsCount > 0 ? remaining / installmentsCount : 0.0;
      expect(installmentValue, 100.0);
    });

    test('handles division with decimals in installments', () {
      const double remaining = 1000.0;
      const int installmentsCount = 3;
      final installmentValue = remaining / installmentsCount;
      expect(MoneyFormatter.formatAmount(installmentValue), '333.33');
    });

    test('calculates total profit for sale with quantity', () {
      const double purchasePricePerUnit = 400.0;
      const double sellingPriceTotal = 1000.0;
      const int quantity = 2;

      final totalCost = purchasePricePerUnit * quantity; // 800
      final totalProfit = sellingPriceTotal - totalCost; // 200

      expect(totalCost, 800.0);
      expect(totalProfit, 200.0);

      // Profit percentage relative to cost: (200 / 800) * 100 = 25.0%
      expect(MoneyFormatter.profitPercentage(sellingPriceTotal, totalCost), '25.0');

      // Profit margin relative to revenue: (200 / 1000) * 100 = 20.0%
      expect(MoneyFormatter.profitMargin(totalProfit, sellingPriceTotal), '20.0');
    });

    test('validates down payment does not exceed total price', () {
      const double totalPrice = 500.0;
      const double downPayment = 600.0;
      final isValid = downPayment <= totalPrice;
      expect(isValid, isFalse);
    });
  });
}
