import '../entities/report_result.dart';

abstract interface class ReportsRepository {
  Future<ReportResult> fetch({
    required String type,
    required String period,
    required String currency,
    String? groupBy,
    String? productId,
    String? from,
    String? to,
  });
}
