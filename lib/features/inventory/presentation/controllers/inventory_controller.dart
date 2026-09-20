import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_movement.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryController extends ChangeNotifier {
  InventoryController(this._repository);

  final InventoryRepository _repository;
  ViewState state = ViewState.idle;
  List<InventoryItem> items = const [];
  String? errorMessage;
  bool lowStockOnly = false;

  Future<void> load({bool? lowStock}) async {
    lowStockOnly = lowStock ?? lowStockOnly;
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      items = await _repository.fetchAll(lowStock: lowStockOnly);
      state = items.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل المخزون.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> save({
    required String productId,
    required int quantity,
    required String action,
    required int lowStockThreshold,
    String? notes,
  }) async {
    try {
      await _repository.save(
        productId: productId,
        quantity: quantity,
        action: action,
        lowStockThreshold: lowStockThreshold,
        notes: notes,
      );
      await load();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر تحديث المخزون.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }

  Future<List<InventoryMovement>> movements(String productId) =>
      _repository.fetchMovements(productId);

  Future<bool> updateSettings({
    required String productId,
    required int lowStockThreshold,
    String? notes,
  }) async {
    try {
      await _repository.updateSettings(
        productId: productId,
        lowStockThreshold: lowStockThreshold,
        notes: notes,
      );
      await load();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر حفظ إعدادات المخزون.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }

  Future<bool> disable(String productId) async {
    try {
      await _repository.disable(productId);
      await load();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر إيقاف تتبع المخزون.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }
}
