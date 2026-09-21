import 'package:aksat/core/utils/money_formatter.dart';
import 'package:aksat/features/settings/domain/entities/store_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormatter - formatAmount', () {
    test('formats null and 0 as "0"', () {
      expect(MoneyFormatter.formatAmount(null), '0');
      expect(MoneyFormatter.formatAmount(0), '0');
      expect(MoneyFormatter.formatAmount('0'), '0');
    });

    test('formats numbers with commas and appropriate decimal places', () {
      expect(MoneyFormatter.formatAmount(25000), '25,000');
      expect(MoneyFormatter.formatAmount('1250000'), '1,250,000');
      expect(MoneyFormatter.formatAmount(12.30), '12.3');
      expect(MoneyFormatter.formatAmount(12.345), '12.35');
      expect(MoneyFormatter.formatAmount('100.5'), '100.5');
    });
  });

  group('MoneyFormatter - currencySymbol and currencyName', () {
    test('returns dollar for USD', () {
      expect(MoneyFormatter.currencySymbol('USD'), '\$');
      expect(MoneyFormatter.currencyName('USD'), 'دولار');
    });

    test('returns default Iraqi Dinar when no settings provided', () {
      expect(MoneyFormatter.currencySymbol('LOCAL'), 'د.ع');
      expect(MoneyFormatter.currencyName('LOCAL'), 'دينار');
    });

    test('returns custom symbol when passed as String', () {
      expect(MoneyFormatter.currencySymbol('LOCAL', 'ر.س'), 'ر.س');
      expect(MoneyFormatter.currencyName('LOCAL', 'ريال'), 'ريال');
    });

    test('extracts custom symbol and name from StoreSettings entity', () {
      const settings = StoreSettings(
        storeName: 'متجر الاختبار',
        currencyName: 'ليرة',
        currencySymbol: '₺',
        exchangeRate: '35.0',
        whatsappTemplate: '',
      );
      expect(MoneyFormatter.currencySymbol('LOCAL', settings), '₺');
      expect(MoneyFormatter.currencyName('LOCAL', settings), 'ليرة');
    });

    test('extracts custom symbol and name from map', () {
      final map = {
        'currency_name': 'درهم',
        'currency_symbol': 'د.إ',
      };
      expect(MoneyFormatter.currencySymbol('LOCAL', map), 'د.إ');
      expect(MoneyFormatter.currencyName('LOCAL', map), 'درهم');
    });
  });

  group('MoneyFormatter - convertCurrency', () {
    test('converts USD to LOCAL correctly', () {
      // 100 USD at 1500 IQD rate = 150,000 LOCAL
      expect(MoneyFormatter.convertCurrency(100, 'USD', 'LOCAL', 1500), 150000);
      expect(MoneyFormatter.convertCurrency('50', 'USD', 'LOCAL', '1400'), 70000);
    });

    test('converts LOCAL to USD correctly', () {
      // 150,000 LOCAL at 1500 IQD rate = 100 USD
      expect(MoneyFormatter.convertCurrency(150000, 'LOCAL', 'USD', 1500), 100);
    });

    test('returns same amount if currencies match', () {
      expect(MoneyFormatter.convertCurrency(500, 'USD', 'USD', 1500), 500);
      expect(MoneyFormatter.convertCurrency(500, 'LOCAL', 'LOCAL', 1500), 500);
    });
  });

  group('MoneyFormatter - profit calculations', () {
    test('profitPercentage calculates (price - cost) / cost * 100', () {
      expect(MoneyFormatter.profitPercentage(120, 100), '20.0');
      expect(MoneyFormatter.profitPercentage(150, 100), '50.0');
      expect(MoneyFormatter.profitPercentage(100, 0), '0.0');
    });

    test('profitMargin calculates profit / revenue * 100', () {
      expect(MoneyFormatter.profitMargin(20, 100), '20.0');
      expect(MoneyFormatter.profitMargin(50, 200), '25.0');
      expect(MoneyFormatter.profitMargin(10, 0), '0.0');
    });
  });
}
