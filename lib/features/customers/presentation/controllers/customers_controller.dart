import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';

class CustomersController extends ChangeNotifier {
  CustomersController(this._repository);

  final CustomersRepository _repository;
  ViewState state = ViewState.idle;
  List<Customer> customers = const [];
  String? errorMessage;
  Timer? _searchTimer;

  Future<void> load({String? search}) async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      customers = await _repository.fetchAll(search: search);
      state = customers.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل المشترين.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  void search(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(
      const Duration(milliseconds: 350),
      () => load(search: value.trim()),
    );
  }

  Future<bool> save(Customer customer) async {
    try {
      final saved = customer.id.isEmpty
          ? await _repository.create(customer)
          : await _repository.update(customer);
      final index = customers.indexWhere((item) => item.id == saved.id);
      customers = index == -1 ? [saved, ...customers] : [...customers]
        ..[index] = saved;
      state = ViewState.success;
      notifyListeners();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
    } catch (_) {
      errorMessage = 'تعذر حفظ المشتري.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }

  Future<bool> remove(String id) async {
    try {
      await _repository.delete(id);
      customers = customers.where((item) => item.id != id).toList();
      state = customers.isEmpty ? ViewState.empty : ViewState.success;
      notifyListeners();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر حذف المشتري.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
