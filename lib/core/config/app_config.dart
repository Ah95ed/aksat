class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://aksat.store/api/';

  static const String supportPhone = '07706118992';
  static const String whatsappPhone = '9647706118992';
  static const String supportWhatsAppUrl = 'https://wa.me/9647706118992';
  static const String version = 'v1.0.0';
  static const String appVersion = '1.0.0';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const int tokenLifetimeHours = 24;
}