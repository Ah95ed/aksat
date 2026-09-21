import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'إبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    final str = date.toString().trim();
    if (str.isEmpty || str == '-') return null;
    return DateTime.tryParse(str);
  }

  /// Returns "dd/MM/yyyy" (e.g. "05/09/2026"). Returns "-" if null or invalid.
  static String formatDateShort(dynamic date) {
    final d = _parseDate(date);
    if (d == null) return '-';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  /// Returns "yyyy/M/d" (no zero padding, e.g. "2026/9/5" for sale date).
  static String formatDateNumeric(dynamic date) {
    final d = _parseDate(date);
    if (d == null) return '-';
    return '${d.year}/${d.month}/${d.day}';
  }

  /// Returns localized full Arabic date (e.g. in ar-EG).
  static String formatDate(dynamic date) {
    final d = _parseDate(date);
    if (d == null) return '-';
    try {
      return DateFormat.yMMMMd('ar_EG').format(d);
    } catch (_) {
      return '${d.day} ${arabicMonths[d.month - 1]} ${d.year}';
    }
  }

  /// Formats timeline period from reports.php:
  /// - Contains "-W": replace "-W" with " الأسبوع " (e.g. "2025-W03" -> "2025 الأسبوع 03")
  /// - Length 7 (YYYY-MM): "شهر سنة" (e.g. "سبتمبر 2026")
  /// - Length 4 (YYYY): as is
  /// - Other: full Arabic date
  static String formatPeriod(String? period) {
    if (period == null || period.trim().isEmpty) return '-';
    final p = period.trim();

    if (p.contains('-W')) {
      return p.replaceAll('-W', ' الأسبوع ');
    }

    if (p.length == 7 && p.contains('-')) {
      final parts = p.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final monthNum = int.tryParse(parts[1]) ?? 1;
        if (monthNum >= 1 && monthNum <= 12) {
          return '${arabicMonths[monthNum - 1]} $year';
        }
      }
    }

    if (p.length == 4 && int.tryParse(p) != null) {
      return p;
    }

    final d = DateTime.tryParse(p);
    if (d != null) {
      return formatDate(d);
    }

    return p;
  }

  /// Difference in days between today (00:00) and target date (00:00).
  static int daysUntil(dynamic date) {
    final d = _parseDate(date);
    if (d == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    return target.difference(today).inDays;
  }

  /// Text for days until due:
  /// < 0 -> "متأخر {n} يوم"
  /// 0 -> "اليوم"
  /// 1 -> "غداً"
  /// <= 7 -> "خلال {n} أيام"
  /// else -> "خلال {n} يوم"
  static String daysUntilText(dynamic date) {
    final days = daysUntil(date);
    if (days < 0) return 'متأخر ${days.abs()} يوم';
    if (days == 0) return 'اليوم';
    if (days == 1) return 'غداً';
    if (days <= 7) return 'خلال $days أيام';
    return 'خلال $days يوم';
  }

  /// Local device date formatted as "YYYY-MM-DD"
  static String todayYmd() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Preview first installment date for NewSale:
  /// sale_date + 7 days (weekly) or + 1 month (monthly)
  static String previewFirstInstallmentDate(dynamic saleDate, String installmentType) {
    final d = _parseDate(saleDate) ?? DateTime.now();
    DateTime next;
    if (installmentType == 'weekly') {
      next = d.add(const Duration(days: 7));
    } else {
      next = DateTime(d.year, d.month + 1, d.day);
    }
    return formatDateShort(next);
  }

  /// Preview last installment date for NewSale:
  /// sale_date + (7 * count) days (weekly) or + count months (monthly)
  static String previewLastInstallmentDate(
    dynamic saleDate,
    String installmentType,
    int installmentsCount,
  ) {
    final d = _parseDate(saleDate) ?? DateTime.now();
    DateTime last;
    final count = installmentsCount > 0 ? installmentsCount : 1;
    if (installmentType == 'weekly') {
      last = d.add(Duration(days: 7 * count));
    } else {
      last = DateTime(d.year, d.month + count, d.day);
    }
    return formatDateShort(last);
  }
}