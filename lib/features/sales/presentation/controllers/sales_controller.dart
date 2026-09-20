import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';

class SalesController extends ChangeNotifier {
  SalesController(this._repository);
  final SalesRepository _repository;
  ViewState state = ViewState.idle;
  List<Sale> sales = const [];
  String? errorMessage;
  Map<String, dynamic>? lastCreated;

  Future<void> load() async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      sales = await _repository.fetchAll();
      state = sales.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل المبيعات.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      lastCreated = await _repository.create(data);
      await load();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر تسجيل البيع.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }

  Future<bool> remove(String id) async {
    try {
      await _repository.delete(id);
      sales = sales.where((sale) => sale.id != id).toList();
      state = sales.isEmpty ? ViewState.empty : ViewState.success;
      notifyListeners();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر حذف البيع.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }
}
