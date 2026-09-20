import '../../domain/entities/store_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/store_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._remote);

  final SettingsRemoteDataSource _remote;

  @override
  Future<StoreSettings> fetch() => _remote.fetch();

  @override
  Future<StoreSettings> update(StoreSettings settings) => _remote.update(
    StoreSettingsModel(
      storeName: settings.storeName,
      currencyName: settings.currencyName,
      currencySymbol: settings.currencySymbol,
      exchangeRate: settings.exchangeRate,
      whatsappTemplate: settings.whatsappTemplate,
      subscriptionRemainingDays: settings.subscriptionRemainingDays,
    ),
  );
}
