/// Domain-level exceptions. The data layer throws these; the presentation
/// layer catches them and maps them to user-facing messages. No Dio/JSON
/// knowledge leaks into domain or presentation.
class SessionExpired implements Exception {
  const SessionExpired();
  @override
  String toString() => 'SessionExpired';
}

class SubscriptionStopped implements Exception {
  const SubscriptionStopped(this.code, this.whatsapp);
  final String? code;
  final String? whatsapp;
  @override
  String toString() => 'SubscriptionStopped(code=$code, whatsapp=$whatsapp)';
}

class RateLimited implements Exception {
  const RateLimited(this.retryAfterSeconds);
  final int retryAfterSeconds;
  @override
  String toString() => 'RateLimited(retryAfterSeconds=$retryAfterSeconds)';
}

class ApiError implements Exception {
  const ApiError(this.message);
  final String message;
  @override
  String toString() => 'ApiError($message)';
}

class NetworkError implements Exception {
  const NetworkError([this.message]);
  final String? message;
  @override
  String toString() => 'NetworkError($message)';
}

class NotFound implements Exception {
  const NotFound([this.message]);
  final String? message;
  @override
  String toString() => 'NotFound($message)';
}

class Conflict implements Exception {
  const Conflict([this.message]);
  final String? message;
  @override
  String toString() => 'Conflict($message)';
}