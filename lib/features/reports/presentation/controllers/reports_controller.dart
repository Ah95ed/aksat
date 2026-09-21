import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/report_result.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsController extends ChangeNotifier {
  ReportsController(this._repository);

  final ReportsRepository _repository;
  ViewState state = ViewState.idle;

  String period = 'month';
  String currency = 'all';
  String groupBy = 'month';
  String from = '';
  String to = '';
  String activeTab = 'summary';

  Map<String, dynamic>? summary;
  List<Map<String, dynamic>> byProduct = [];
  List<Map<String, dynamic>> topSelling = [];
  List<Map<String, dynamic>> timeline = [];

  String? errorMessage;

  Future<void> loadAll() async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      Future<ReportResult> safeFetch(String type, {String? groupBy}) async {
        try {
          return await _repository.fetch(
            type: type,
            period: period,
            currency: currency,
            groupBy: groupBy,
            from: period == 'custom' && from.isNotEmpty ? from : null,
            to: period == 'custom' && to.isNotEmpty ? to : null,
          );
        } catch (e) {
          if (e is SessionExpired || e is SubscriptionStopped) rethrow;
          if (kDebugMode) debugPrint('Report fetch error for $type: $e');
          return ReportResult(type: type, data: null);
        }
      }

      final results = await Future.wait([
        safeFetch('summary'),
        safeFetch('by_product'),
        safeFetch('top_selling'),
        safeFetch('timeline', groupBy: groupBy),
      ]);

      final sData = results[0].data;
      if (sData is Map) {
        summary = Map<String, dynamic>.from(
          sData.map((k, v) => MapEntry(k.toString(), v)),
        );
      } else {
        summary = null;
      }

      final bpData = results[1].data;
      if (bpData is List) {
        byProduct = bpData
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m.map((k, v) => MapEntry(k.toString(), v))))
            .toList();
      } else {
        byProduct = [];
      }

      final tsData = results[2].data;
      if (tsData is List) {
        topSelling = tsData
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m.map((k, v) => MapEntry(k.toString(), v))))
            .toList();
      } else {
        topSelling = [];
      }

      final tlData = results[3].data;
      if (tlData is List) {
        timeline = tlData
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m.map((k, v) => MapEntry(k.toString(), v))))
            .toList();
      } else {
        timeline = [];
      }

      state = ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (e) {
      errorMessage = 'تعذر تحميل التقارير.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadTimeline() async {
    try {
      final res = await _repository.fetch(
        type: 'timeline',
        period: period,
        currency: currency,
        groupBy: groupBy,
        from: period == 'custom' && from.isNotEmpty ? from : null,
        to: period == 'custom' && to.isNotEmpty ? to : null,
      );
      if (res.data is List) {
        timeline = (res.data as List)
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m.map((k, v) => MapEntry(k.toString(), v))))
            .toList();
      }
      notifyListeners();
    } catch (_) {}
  }

  void setActiveTab(String tab) {
    activeTab = tab;
    notifyListeners();
  }

  Future<void> setPeriod(String p) async {
    period = p;
    await loadAll();
  }

  Future<void> setCurrency(String c) async {
    currency = c;
    await loadAll();
  }

  Future<void> setGroupBy(String g) async {
    groupBy = g;
    await loadTimeline();
  }

  Future<void> setCustomDates(String f, String t) async {
    from = f;
    to = t;
    if (period == 'custom') {
      await loadAll();
    }
  }
}
