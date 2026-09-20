import '../entities/store_settings.dart';

abstract interface class SettingsRepository {
  Future<StoreSettings> fetch();
  Future<StoreSettings> update(StoreSettings settings);
}
