import 'package:flutter_test/flutter_test.dart';

import 'package:aksat/core/network/api_exceptions.dart';
import 'package:aksat/core/network/api_response_handler.dart';

void main() {
  test('accepts a successful API response', () {
    final result = ApiResponseHandler.handle(200, {
      'success': true,
      'data': {'value': 1},
      'message': 'ok',
    });

    expect(result['success'], isTrue);
  });

  test('maps 401 to SessionExpired', () {
    expect(
      () => ApiResponseHandler.handle(401, {'success': false}),
      throwsA(isA<SessionExpired>()),
    );
  });

  test('maps 403 details to SubscriptionStopped', () {
    expect(
      () => ApiResponseHandler.handle(403, {
        'success': false,
        'data': {'code': 'SUBSCRIPTION_STOPPED', 'whatsapp': '07700000000'},
      }),
      throwsA(
        isA<SubscriptionStopped>().having(
          (error) => error.code,
          'code',
          'SUBSCRIPTION_STOPPED',
        ),
      ),
    );
  });

  test('maps 429 retry duration', () {
    expect(
      () => ApiResponseHandler.handle(429, {
        'success': false,
        'data': {'retry_after_seconds': 42},
      }),
      throwsA(
        isA<RateLimited>().having(
          (error) => error.retryAfterSeconds,
          'retryAfterSeconds',
          42,
        ),
      ),
    );
  });

  test('maps success false even on HTTP 200 to ApiError', () {
    expect(
      () => ApiResponseHandler.handle(200, {
        'success': false,
        'message': 'بيانات غير صحيحة',
      }),
      throwsA(isA<ApiError>()),
    );
  });
}
