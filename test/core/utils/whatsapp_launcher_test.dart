import 'package:aksat/core/utils/whatsapp_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhatsAppLauncher - formatPhoneForWhatsApp', () {
    test('converts Iraqi local numbers with leading 0 to international format (964...) ', () {
      expect(WhatsAppLauncher.formatPhoneForWhatsApp('07701234567'), '9647701234567');
      expect(WhatsAppLauncher.formatPhoneForWhatsApp('0780 123 4567'), '9647801234567');
      expect(WhatsAppLauncher.formatPhoneForWhatsApp('7701234567'), '9647701234567');
      expect(WhatsAppLauncher.formatPhoneForWhatsApp('009647701234567'), '9647701234567');
    });

    test('preserves international number without leading 0', () {
      expect(WhatsAppLauncher.formatPhoneForWhatsApp('9647701234567'), '9647701234567');
      expect(WhatsAppLauncher.formatPhoneForWhatsApp('+9647701234567'), '9647701234567');
    });

    test('handles empty or null input', () {
      expect(WhatsAppLauncher.formatPhoneForWhatsApp(null), '');
      expect(WhatsAppLauncher.formatPhoneForWhatsApp(''), '');
    });
  });

  group('WhatsAppLauncher - cleanDigitsOnly', () {
    test('strips all non-digit characters without prepending country code', () {
      expect(WhatsAppLauncher.cleanDigitsOnly('0770-123-4567'), '07701234567');
      expect(WhatsAppLauncher.cleanDigitsOnly('+964 (770) 123-4567'), '9647701234567');
    });
  });

  group('WhatsAppLauncher - buildMessage and replacePlaceholders', () {
    test('substitutes all placeholders with given values in custom template', () {
      const template = 'مرحبا {customer_name}، نود تذكيركم بقسط {product_name} بمبلغ {amount} {currency} المستحق في {due_date}.';
      final result = WhatsAppLauncher.buildMessage(
        template: template,
        customerName: 'أحمد علي',
        productName: 'iPhone 15 Pro',
        amount: '120,000',
        currency: 'د.ع',
        dueDate: '2026/09/25',
      );

      expect(
        result,
        'مرحبا أحمد علي، نود تذكيركم بقسط iPhone 15 Pro بمبلغ 120,000 د.ع المستحق في 2026/09/25.',
      );
    });

    test('falls back to defaultTemplate when template is null or empty', () {
      final result = WhatsAppLauncher.buildMessage(
        template: null,
        customerName: 'سارة محمد',
        productName: 'ثلاجة LG',
        amount: '150',
        currency: '\$',
        dueDate: '2026/10/01',
      );

      expect(result.contains('السلام عليكم سارة محمد'), isTrue);
      expect(result.contains('نذكركم بقسط ثلاجة LG'), isTrue);
      expect(result.contains('المبلغ: 150 \$'), isTrue);
      expect(result.contains('تاريخ الاستحقاق: 2026/10/01'), isTrue);
    });
  });
}
