/// Central configuration: single source of truth for network timeouts and base URL.
/// The base URL can be changed here without touching any other file.
class AppConfig {
  AppConfig._();

  /// REST API base URL. Per docs it changes per customer domain.
  /// Must end with a trailing slash so Dio joins paths like `products.php`.
  static const String baseUrl = 'https://aksat.store/api/';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Token lifetime in hours (24 per docs). Used by AuthController for the
  /// auto-logout countdown shown in the UI.
  static const int tokenLifetimeHours = 24;
}