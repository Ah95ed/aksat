import 'dart:io';

import 'package:intl/intl.dart';

import 'parsers.dart';

/// Single formatter for all money display. Never build amounts inline.
///
/// Rules:
///   - USD uses `$` symbol.
///   - LOCAL uses `currency_symbol` from settings (e.g. 'د.ع').
///   - Never mix USD and LOCAL in one number.
///   - Input may be a string, int, or double.
class MoneyFormatter {
  MoneyFormatter._();

  static String format(
    dynamic amount, {
    required String currency,
    String? localSymbol,
    int decimals = 2,
  }) {
    final value = toNum(amount);
    final symbol = currency == 'USD' ? '\$' : (localSymbol ?? 'د.ع');
    final locale = Platform.localeName;
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
      locale: locale.isNotEmpty ? locale : 'en_US',
    );
    return formatter.format(value);
  }

  /// Compact form for dashboard cards (e.g. "1.2M" / "450").
  static String compact(
    dynamic amount, {
    required String currency,
    String? localSymbol,
  }) {
    final value = toNum(amount);
    final symbol = currency == 'USD' ? '\$' : (localSymbol ?? 'د.ع');
    final formatter = NumberFormat.compactCurrency(
      symbol: symbol,
      locale: Platform.localeName,
    );
    return formatter.format(value);
  }
}