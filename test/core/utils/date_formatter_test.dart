import 'package:aksat/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatter - formatDateShort & formatDateNumeric', () {
    test('formatDateShort returns dd/MM/yyyy', () {
      final date = DateTime(2026, 9, 5);
      expect(DateFormatter.formatDateShort(date), '05/09/2026');
      expect(DateFormatter.formatDateShort('2026-09-05'), '05/09/2026');
      expect(DateFormatter.formatDateShort(null), '-');
      expect(DateFormatter.formatDateShort(''), '-');
    });

    test('formatDateNumeric returns yyyy/M/d without zero padding', () {
      final date = DateTime(2026, 9, 5);
      expect(DateFormatter.formatDateNumeric(date), '2026/9/5');
      expect(DateFormatter.formatDateNumeric('2026-09-05'), '2026/9/5');
      expect(DateFormatter.formatDateNumeric(null), '-');
    });
  });

  group('DateFormatter - formatPeriod', () {
    test('formats weekly timeline periods', () {
      expect(DateFormatter.formatPeriod('2025-W03'), '2025 الأسبوع 03');
      expect(DateFormatter.formatPeriod('2026-W45'), '2026 الأسبوع 45');
    });

    test('formats monthly timeline periods YYYY-MM', () {
      expect(DateFormatter.formatPeriod('2026-09'), 'سبتمبر 2026');
      expect(DateFormatter.formatPeriod('2025-01'), 'يناير 2025');
    });

    test('formats yearly timeline periods YYYY', () {
      expect(DateFormatter.formatPeriod('2026'), '2026');
    });

    test('handles empty or null', () {
      expect(DateFormatter.formatPeriod(null), '-');
      expect(DateFormatter.formatPeriod(''), '-');
    });
  });

  group('DateFormatter - daysUntil & daysUntilText', () {
    test('daysUntilText returns correct relative Arabic text', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Today
      expect(DateFormatter.daysUntilText(today), 'اليوم');

      // Tomorrow
      final tomorrow = today.add(const Duration(days: 1));
      expect(DateFormatter.daysUntilText(tomorrow), 'غداً');

      // Within 7 days
      final in3Days = today.add(const Duration(days: 3));
      expect(DateFormatter.daysUntilText(in3Days), 'خلال 3 أيام');

      // More than 7 days
      final in15Days = today.add(const Duration(days: 15));
      expect(DateFormatter.daysUntilText(in15Days), 'خلال 15 يوم');

      // Late / overdue
      final past5Days = today.subtract(const Duration(days: 5));
      expect(DateFormatter.daysUntilText(past5Days), 'متأخر 5 يوم');
    });
  });

  group('DateFormatter - installment preview dates', () {
    test('previewFirstInstallmentDate calculates weekly (+7 days) and monthly (+1 month)', () {
      final baseDate = DateTime(2026, 1, 10);
      expect(
        DateFormatter.previewFirstInstallmentDate(baseDate, 'weekly'),
        '17/01/2026',
      );
      expect(
        DateFormatter.previewFirstInstallmentDate(baseDate, 'monthly'),
        '10/02/2026',
      );
    });

    test('previewLastInstallmentDate calculates total count correctly', () {
      final baseDate = DateTime(2026, 1, 1);
      // 4 weekly installments = 28 days -> 29/01/2026
      expect(
        DateFormatter.previewLastInstallmentDate(baseDate, 'weekly', 4),
        '29/01/2026',
      );
      // 3 monthly installments = 3 months -> 01/04/2026
      expect(
        DateFormatter.previewLastInstallmentDate(baseDate, 'monthly', 3),
        '01/04/2026',
      );
    });
  });
}
