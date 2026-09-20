import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/report_result.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsController extends ChangeNotifier {
  ReportsController(this._repository);

  final ReportsRepository _repository;
  ViewState state = ViewState.idle;
  String type = 'summary';
  String period = 'month';
  String currency = 'all';
  String groupBy = 'month';
  ReportResult? result;
  String? errorMessage;

  Future<void> load({String? selectedType}) async {
    type = selectedType ?? type;
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      result = await _repository.fetch(
        type: type,
        period: period,
        currency: currency,
        groupBy: type == 'timeline' ? groupBy : null,
      );
      state = ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل التقرير.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> setPeriod(String value) async {
    period = value;
    await load();
  }

  Future<void> setCurrency(String value) async {
    currency = value;
    await load();
  }
}
