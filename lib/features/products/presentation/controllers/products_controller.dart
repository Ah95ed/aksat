import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

class ProductsController extends ChangeNotifier {
  ProductsController(this._repository);

  final ProductsRepository _repository;
  ViewState state = ViewState.idle;
  List<Product> products = const [];
  String? errorMessage;

  Future<void> load() async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      products = await _repository.fetchAll();
      state = products.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل المواد.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> save(Product product) async {
    try {
      final saved = product.id.isEmpty
          ? await _repository.create(product)
          : await _repository.update(product);
      final index = products.indexWhere((item) => item.id == saved.id);
      products = index == -1 ? [saved, ...products] : [...products]
        ..[index] = saved;
      state = ViewState.success;
      notifyListeners();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
    } catch (_) {
      errorMessage = 'تعذر حفظ المادة.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }

  Future<bool> remove(String id) async {
    try {
      await _repository.delete(id);
      products = products.where((item) => item.id != id).toList();
      state = products.isEmpty ? ViewState.empty : ViewState.success;
      notifyListeners();
      return true;
    } on Conflict catch (error) {
      errorMessage = error.message ?? 'لا يمكن حذف مادة مرتبطة بمبيعات سابقة.';
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر حذف المادة.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }
}
