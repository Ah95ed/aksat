import 'package:url_launcher/url_launcher.dart';

class WhatsAppLauncher {
  WhatsAppLauncher._();

  static const String defaultTemplate =
      'السلام عليكم {customer_name}،\n'
      'نذكركم بقسط {product_name}\n'
      'المبلغ: {amount} {currency}\n'
      'تاريخ الاستحقاق: {due_date}\n'
      'شكراً لتعاملكم معنا.';

  /// Cleans phone and replaces leading 0 with 964 (Iraq default)
  static String formatPhoneForWhatsApp(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    var cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('00')) {
      cleaned = cleaned.substring(2);
    }
    if (cleaned.startsWith('0')) {
      cleaned = '964${cleaned.substring(1)}';
    } else if (cleaned.length == 10 && cleaned.startsWith('7')) {
      cleaned = '964$cleaned';
    }
    return cleaned;
  }

  /// Cleans phone to digits only without modifying leading zero
  static String cleanDigitsOnly(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Builds message using template with placeholders
  static String buildMessage({
    String? template,
    required String customerName,
    required String productName,
    required String amount,
    required String currency,
    required String dueDate,
  }) {
    final tpl = (template != null && template.trim().isNotEmpty)
        ? template
        : defaultTemplate;

    return tpl
        .replaceAll('{customer_name}', customerName)
        .replaceAll('{product_name}', productName)
        .replaceAll('{amount}', amount)
        .replaceAll('{currency}', currency)
        .replaceAll('{due_date}', dueDate);
  }

  /// Alias for buildMessage
  static String replacePlaceholders(
    String? template, {
    required String customerName,
    required String productName,
    required String amount,
    required String currency,
    required String dueDate,
  }) => buildMessage(
    template: template,
    customerName: customerName,
    productName: productName,
    amount: amount,
    currency: currency,
    dueDate: dueDate,
  );

  /// Launches WhatsApp via app protocol, falling back to https://wa.me
  static Future<bool> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = formatPhoneForWhatsApp(phone);
    if (cleanPhone.isEmpty) return false;

    final encodedMessage = Uri.encodeComponent(message);
    final appUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage');
    final apiUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMessage');
    final webUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    // 1. Try native app scheme
    try {
      if (await canLaunchUrl(appUri)) {
        final ok = await launchUrl(appUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
      }
    } catch (_) {}

    // 2. Try wa.me
    try {
      if (await canLaunchUrl(webUri)) {
        final ok = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
      }
    } catch (_) {}

    // 3. Try api.whatsapp.com
    try {
      if (await canLaunchUrl(apiUri)) {
        final ok = await launchUrl(apiUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
      }
    } catch (_) {}

    // 4. Force launch without pre-check (handles platforms where canLaunchUrl returns false)
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        return await launchUrl(webUri);
      } catch (_) {
        return false;
      }
    }
  }

  /// Direct phone call
  static Future<bool> makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }
}
