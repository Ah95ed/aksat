import 'package:aksat/core/utils/parsers.dart';
import 'package:aksat/features/reports/data/models/report_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dashboard - Monthly Profit extraction', () {
    test('extracts expected_profit correctly from ReportResultModel', () {
      final report = ReportResultModel.fromResponse('summary', {
        'success': true,
        'data': {
          'USD': {
            'expected_profit': 450.5,
            'total_revenue': 1200,
          },
          'LOCAL': {
            'expected_profit': '250000',
            'total_revenue': '750000',
          },
        },
      });

      double extractExpectedProfit(dynamic p, String currency) {
        if (p == null) return 0.0;
        dynamic map = p.data;
        if (map is Map) {
          final curData = map[currency] ?? map[currency.toLowerCase()];
          if (curData is Map) {
            return toNum(curData['expected_profit'] ?? curData['expectedProfit']);
          }
        }
        return 0.0;
      }

      expect(extractExpectedProfit(report, 'USD'), 450.5);
      expect(extractExpectedProfit(report, 'LOCAL'), 250000.0);
    });

    test('returns 0.0 safely when report or currency is null or missing', () {
      double extractExpectedProfit(dynamic p, String currency) {
        if (p == null) return 0.0;
        dynamic map = p.data;
        if (map is Map) {
          final curData = map[currency];
          if (curData is Map) {
            return toNum(curData['expected_profit']);
          }
        }
        return 0.0;
      }

      expect(extractExpectedProfit(null, 'USD'), 0.0);
      final emptyReport = ReportResultModel.fromResponse('summary', {
        'success': true,
        'data': {},
      });
      expect(extractExpectedProfit(emptyReport, 'USD'), 0.0);
    });
  });
}
