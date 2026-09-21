import 'package:intl/intl.dart';
import 'parsers.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,##0.##', 'en_US');

  /// Formats amount: null/undefined -> "0", otherwise Latin number with comma
  /// thousand separators, max 2 decimals, no extra trailing zeros.
  /// Example: 25000 -> "25,000", 12.30 -> "12.3", 0 -> "0".
  static String formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final val = toNum(amount);
    return _formatter.format(val);
  }

  /// Returns currency symbol ($ for USD, or settings.currency_symbol / 'د.ع')
  static String currencySymbol(String? currency, [dynamic localSymbolOrSettings]) {
    if (currency == 'USD') return '\$';
    if (localSymbolOrSettings is String && localSymbolOrSettings.trim().isNotEmpty) {
      return localSymbolOrSettings.trim();
    }
    if (localSymbolOrSettings != null) {
      try {
        final sym = (localSymbolOrSettings as dynamic).currencySymbol;
        if (sym != null && sym.toString().trim().isNotEmpty) return sym.toString().trim();
      } catch (_) {}
      try {
        final sym = (localSymbolOrSettings as dynamic)['currency_symbol'];
        if (sym != null && sym.toString().trim().isNotEmpty) return sym.toString().trim();
      } catch (_) {}
    }
    return 'د.ع';
  }

  /// Returns currency name ('دولار' for USD, or settings.currency_name / 'دينار')
  static String currencyName(String? currency, [dynamic localNameOrSettings]) {
    if (currency == 'USD') return 'دولار';
    if (localNameOrSettings is String && localNameOrSettings.trim().isNotEmpty) {
      return localNameOrSettings.trim();
    }
    if (localNameOrSettings != null) {
      try {
        final name = (localNameOrSettings as dynamic).currencyName;
        if (name != null && name.toString().trim().isNotEmpty) return name.toString().trim();
      } catch (_) {}
      try {
        final name = (localNameOrSettings as dynamic)['currency_name'];
        if (name != null && name.toString().trim().isNotEmpty) return name.toString().trim();
      } catch (_) {}
    }
    return 'دينار';
  }

  /// Converts between USD and LOCAL based on exchange rate.
  static double convertCurrency(
    dynamic amount,
    String? fromCurrency,
    String? toCurrency,
    dynamic exchangeRate,
  ) {
    final amt = toNum(amount);
    if (fromCurrency == toCurrency) return amt;

    final rate = toNum(exchangeRate);
    final effectiveRate = rate > 0 ? rate : 1.0;

    if (fromCurrency == 'USD' && toCurrency == 'LOCAL') {
      return amt * effectiveRate;
    }
    if (fromCurrency == 'LOCAL' && toCurrency == 'USD') {
      return amt / effectiveRate;
    }
    return amt;
  }

  /// Profit percentage: (price - cost) / cost * 100
  static String profitPercentage(dynamic price, dynamic cost) {
    final p = toNum(price);
    final c = toNum(cost);
    if (c <= 0) return '0.0';
    return (((p - c) / c) * 100).toStringAsFixed(1);
  }

  /// Profit margin: profit / revenue * 100
  static String profitMargin(dynamic profit, dynamic revenue) {
    final p = toNum(profit);
    final r = toNum(revenue);
    if (r <= 0) return '0.0';
    return ((p / r) * 100).toStringAsFixed(1);
  }
}