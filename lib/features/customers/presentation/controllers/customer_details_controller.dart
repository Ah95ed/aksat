import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/state/view_state.dart';
import '../../../installments/domain/repositories/installments_repository.dart';
import '../../domain/entities/customer_detail.dart';
import '../../domain/repositories/customers_repository.dart';

class CustomerDetailsController extends ChangeNotifier {
  CustomerDetailsController({
    required this.customersRepository,
    required this.installmentsRepository,
  });

  final CustomersRepository customersRepository;
  final InstallmentsRepository installmentsRepository;

  ViewState state = ViewState.idle;
  CustomerDetail? customer;
  String? errorMessage;
  final Map<String, String> displayCurrency = {};

  Future<void> load(String customerId) async {
    state = ViewState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      customer = await customersRepository.fetchById(customerId);
      state = ViewState.success;
    } on ApiError catch (error) {
      errorMessage = error.message;
      state = ViewState.error;
    } on NetworkError catch (error) {
      errorMessage = error.message ?? 'تعذر الاتصال بالخادم.';
      state = ViewState.error;
    } catch (_) {
      errorMessage = 'فشل تحميل بيانات المشتري.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  void toggleCurrency(String saleId) {
    if (displayCurrency[saleId] == 'OTHER') {
      displayCurrency[saleId] = 'ORIGINAL';
    } else {
      displayCurrency[saleId] = 'OTHER';
    }
    notifyListeners();
  }

  Future<bool> payInstallment(String installmentId, String customerId) async {
    try {
      await installmentsRepository.update(
        id: installmentId,
        action: 'pay',
      );
      await load(customerId);
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'فشل تسديد القسط';
    }
    notifyListeners();
    return false;
  }

  Future<bool> unpayInstallment(String installmentId, String customerId) async {
    try {
      await installmentsRepository.update(
        id: installmentId,
        action: 'unpay',
      );
      await load(customerId);
      return true;
    } on ApiError catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'فشل إلغاء تسديد القسط';
    }
    notifyListeners();
    return false;
  }
}
