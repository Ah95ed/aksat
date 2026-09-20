import 'dart:io';

import 'package:dio/dio.dart';

import 'api_exceptions.dart';

/// Applies the response rules in ONE place so every data source benefits.
///
/// Rules (from API docs):
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

  /// Returns the decoded body map on success, otherwise throws.
  /// [body] may be null when the server returns an empty/invalid response.
  static Map<String, dynamic> handle(
    int? statusCode,
    dynamic body, [
    String? fallbackMessage,
  ]) {
    if (statusCode == null) throw const NetworkError('No response');

    // Transport-level failures (no body at all) are treated as network errors
    // for 5xx, but 4xx with a JSON body still goes through the success check.
    if (body is! Map<String, dynamic>) {
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

    final data = body;

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

/// Maps Dio exceptions to our domain exceptions.
Exception mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkError('انتهت مهلة الاتصال');
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return NetworkError(e.error?.toString() ?? 'اضطراب في الاتصال');
    case DioExceptionType.badResponse:
      // A bad response still carries a status code and possibly a body.
      final code = e.response?.statusCode;
      final body = e.response?.data;
      return _mapBadResponse(code, body);
    case DioExceptionType.unknown:
    default:
      if (e.error is SocketException) {
        return const NetworkError('لا توجد اتصال إلى الإنترنت');
      }
      return NetworkError(e.message ?? 'حدث خطأ في الاتصال');
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
