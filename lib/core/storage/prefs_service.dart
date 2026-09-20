import 'package:shared_preferences/shared_preferences.dart';

/// Simple prefs: theme mode, locale, and any future user preference.
/// Never store secrets here.
class PrefsService {
  const PrefsService(this._prefs);

  final SharedPreferences _prefs;

  SharedPreferences get preferences => _prefs;

  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyFirstLaunch = 'first_launch';

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';

  Future<void> setLocale(String code) => _prefs.setString(_keyLocale, code);

  String? getLocale() => _prefs.getString(_keyLocale);

  Future<void> setFirstLaunch(bool value) =>
      _prefs.setBool(_keyFirstLaunch, value);

  bool isFirstLaunch() => _prefs.getBool(_keyFirstLaunch) ?? true;
}
