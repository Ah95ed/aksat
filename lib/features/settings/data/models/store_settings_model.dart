import '../../../../core/utils/parsers.dart';
import '../../domain/entities/store_settings.dart';

class StoreSettingsModel extends StoreSettings {
  const StoreSettingsModel({
    super.storeName,
    super.currencyName,
    super.currencySymbol,
    super.exchangeRate,
    super.whatsappTemplate,
    super.subscriptionRemainingDays,
  });

  factory StoreSettingsModel.fromJson(Map<String, dynamic> json) =>
      StoreSettingsModel(
        storeName: toStr(json['store_name']),
        currencyName: toStr(json['currency_name']),
        currencySymbol: toStr(json['currency_symbol']),
        exchangeRate: toStr(json['exchange_rate']),
        whatsappTemplate: toStr(json['whatsapp_template']),
        subscriptionRemainingDays: json['subscription_remaining_days'] == null
            ? null
            : toInt(json['subscription_remaining_days']),
      );

  Map<String, dynamic> toJson() => {
    'store_name': storeName,
    'currency_name': currencyName,
    'currency_symbol': currencySymbol,
    'exchange_rate': exchangeRate,
    'whatsapp_template': whatsappTemplate,
  };
}
