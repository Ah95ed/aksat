import 'package:intl/intl.dart';

/// Central date formatting. The API sends `YYYY-MM-DD` on write and
/// `YYYY-MM-DD HH:MM:SS` on read.

String formatDate(dynamic v) {
  final parsed = DateTime.tryParse(v?.toString() ?? '');
  if (parsed == null) return v?.toString() ?? '';
  return DateFormat('yyyy-MM-dd').format(parsed);
}

String formatDateTime(dynamic v) {
  final parsed = DateTime.tryParse(v?.toString() ?? '');
  if (parsed == null) return v?.toString() ?? '';
  return DateFormat('yyyy-MM-dd HH:mm').format(parsed);
}

String formatDateTimeFull(dynamic v) {
  final parsed = DateTime.tryParse(v?.toString() ?? '');
  if (parsed == null) return v?.toString() ?? '';
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsed);
}

/// Returns today as the API expects it.
String todayString() => DateFormat('yyyy-MM-dd').format(DateTime.now());

bool isOverdue(String? dueDate) {
  final parsed = DateTime.tryParse(dueDate ?? '');
  if (parsed == null) return false;
  final today = DateTime.now();
  return parsed.isBefore(DateTime(today.year, today.month, today.day));
}