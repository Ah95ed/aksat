import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../domain/entities/store_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final SettingsRepository _repository;
  ViewState state = ViewState.idle;
  StoreSettings settings = const StoreSettings();
  String? errorMessage;

  Future<void> load() async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      settings = await _repository.fetch();
      state = ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'تعذر تحميل الإعدادات.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> update(StoreSettings value) async {
    try {
      settings = await _repository.update(value);
      state = ViewState.success;
      notifyListeners();
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر حفظ الإعدادات.';
    }
    state = ViewState.error;
    notifyListeners();
    return false;
  }
}
