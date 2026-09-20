class StoreSettings {
  const StoreSettings({
    this.storeName = '',
    this.currencyName = '',
    this.currencySymbol = '',
    this.exchangeRate = '',
    this.whatsappTemplate = '',
    this.subscriptionRemainingDays,
  });

  final String storeName;
  final String currencyName;
  final String currencySymbol;
  final String exchangeRate;
  final String whatsappTemplate;
  final int? subscriptionRemainingDays;
}
