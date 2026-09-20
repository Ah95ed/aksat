import '../../domain/entities/report_result.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._remote);
  final ReportsRemoteDataSource _remote;

  @override
  Future<ReportResult> fetch({
    required String type,
    required String period,
    required String currency,
    String? groupBy,
    String? productId,
    String? from,
    String? to,
  }) => _remote.fetch(
    type: type,
    period: period,
    currency: currency,
    groupBy: groupBy,
    productId: productId,
    from: from,
    to: to,
  );
}
