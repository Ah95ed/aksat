import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/installment.dart';
import '../../domain/repositories/installments_repository.dart';

class InstallmentsController extends ChangeNotifier {
  InstallmentsController(this._repository);

  final InstallmentsRepository _repository;
  ViewState state = ViewState.idle;
  List<Installment> installments = const [];
  String filter = 'all';
  String? errorMessage;

  Future<void> load([String? selectedFilter]) async {
    filter = selectedFilter ?? filter;
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      installments = await _repository.fetch(filter);
      state = installments.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل الأقساط.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> update(
    Installment installment,
    String action, {
    String? notes,
  }) async {
    try {
      await _repository.update(
        id: installment.id,
        action: action,
        notes: notes,
        paidDate: action == 'pay'
            ? DateTime.now().toIso8601String().substring(0, 10)
            : null,
      );
      await load();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر تحديث القسط.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }
}
