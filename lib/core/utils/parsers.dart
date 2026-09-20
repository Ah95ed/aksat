library;

/// Type-tolerant numeric parsers. The API returns financial values and IDs
/// as strings ("25000.00", "22"), so we NEVER assume the Dart type.

/// Parses anything to double. Returns 0 for null/unparseable.
double toNum(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

/// Parses anything to int. Returns 0 for null/unparseable.
int toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

/// Parses anything to a non-negative int id. Returns 0 for null/unparseable.
int toId(dynamic v) {
  final parsed = int.tryParse(v?.toString() ?? '');
  return parsed == null ? 0 : (parsed < 0 ? 0 : parsed);
}

/// Returns the string form, or '' for null.
String toStr(dynamic v) => v?.toString() ?? '';

/// Returns true when v is truthy (true, "true", 1, "1").
bool toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase().trim();
  return s == 'true' || s == '1' || s == 'yes';
}
