import 'dart:io';

import 'package:dio/dio.dart';

import 'api_exceptions.dart';

/// Applies the response rules in ONE place so every data source benefits.
///
/// Rules (from Section 10.1):
///   401  -> SessionExpired
///   403  -> SubscriptionStopped (with code + whatsapp if present)
///   429  -> RateLimited(retry_after_seconds)
///   409  -> Conflict
///   404  -> NotFound
///   any other non-2xx -> ApiError
///   success != true (even on HTTP 200) -> ApiError(message)
///   connection/timeout errors -> NetworkError
class ApiResponseHandler {
  ApiResponseHandler._();

  static const String networkErrorMessage = 'تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت.';

  /// Returns the decoded body map on success, otherwise throws.
  static Map<String, dynamic> handle(
    int? statusCode,
    dynamic body, [
    String? fallbackMessage,
  ]) {
    if (statusCode == null) throw const NetworkError(networkErrorMessage);

    if (body is! Map) {
      if (statusCode >= 500) {
        throw ApiError(fallbackMessage ?? 'حدث خطأ في الخادم');
      }
      if (statusCode == 401) throw const SessionExpired();
      if (statusCode == 403) throw const SubscriptionStopped(null, null);
      if (statusCode == 429) throw const RateLimited(900);
      if (statusCode == 404) throw const NotFound();
      if (statusCode == 409) throw const Conflict();
      throw ApiError(fallbackMessage ?? 'حدث خطأ غير معروف');
    }

    final Map<String, dynamic> data = body is Map<String, dynamic>
        ? body
        : Map<String, dynamic>.from(body.map((k, v) => MapEntry(k.toString(), v)));

    if (statusCode == 401) throw const SessionExpired();
    if (statusCode == 403) {
      final d = data['data'] as Map<String, dynamic>?;
      throw SubscriptionStopped(
        d?['code']?.toString(),
        d?['whatsapp']?.toString(),
      );
    }
    if (statusCode == 429) {
      final d = data['data'] as Map<String, dynamic>?;
      final secs =
          int.tryParse((d?['retry_after_seconds'] ?? 900).toString()) ?? 900;
      throw RateLimited(secs);
    }
    if (statusCode == 404) throw NotFound(data['message']?.toString());
    if (statusCode == 409) throw Conflict(data['message']?.toString());

    // success:false is used even on HTTP 200 for validation errors.
    if (data['success'] != true) {
      throw ApiError(data['message']?.toString() ?? 'حدث خطأ');
    }

    return data;
  }
}

/// Maps Dio exceptions to domain exceptions.
Exception mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return const NetworkError(ApiResponseHandler.networkErrorMessage);
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      final body = e.response?.data;
      return _mapBadResponse(code, body);
    case DioExceptionType.unknown:
    default:
      if (e.error is SocketException) {
        return const NetworkError(ApiResponseHandler.networkErrorMessage);
      }
      return NetworkError(e.message ?? ApiResponseHandler.networkErrorMessage);
  }
}

Exception _mapBadResponse(int? code, dynamic body) {
  if (code == 401) return const SessionExpired();
  if (code == 403) {
    final d = body is Map ? body['data'] as Map<String, dynamic>? : null;
    return SubscriptionStopped(
      d?['code']?.toString(),
      d?['whatsapp']?.toString(),
    );
  }
  if (code == 429) {
    final d = body is Map ? body['data'] as Map<String, dynamic>? : null;
    return RateLimited(
      int.tryParse((d?['retry_after_seconds'] ?? 900).toString()) ?? 900,
    );
  }
  if (code == 404) return const NotFound();
  if (code == 409) return const Conflict();
  if (code == 500) return const ApiError('حدث خطأ في الخادم');
  return ApiError(
    body is Map ? body['message']?.toString() ?? 'حدث خطأ' : 'حدث خطأ',
  );
}
