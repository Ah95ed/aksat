import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../reports/domain/entities/report_result.dart';
import '../../../reports/domain/repositories/reports_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._repository, [this._reportsRepository]);

  final DashboardRepository _repository;
  final ReportsRepository? _reportsRepository;

  ViewState state = ViewState.idle;
  DashboardSummary? summary;
  ReportResult? monthlyProfit;
  String? errorMessage;

  Future<void> load() async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _repository.fetchSummary(),
        if (_reportsRepository != null)
          _reportsRepository.fetch(
            type: 'summary',
            period: 'month',
            currency: 'all',
          ).catchError((_) => const ReportResult(type: 'summary', data: null))
        else
          Future.value(null),
      ]);

      summary = futures[0] as DashboardSummary?;
      if (futures.length > 1) {
        monthlyProfit = futures[1] as ReportResult?;
      }
      state = ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل بيانات لوحة التحكم.';
      state = ViewState.error;
    }
    notifyListeners();
  }
}
