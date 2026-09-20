import 'package:flutter/material.dart';

import '../storage/prefs_service.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) : locale = Locale(_prefs.getLocale() ?? 'ar');

  final PrefsService _prefs;
  Locale locale;

  Future<void> setLocale(String languageCode) async {
    if (locale.languageCode == languageCode) return;
    locale = Locale(languageCode);
    await _prefs.setLocale(languageCode);
    notifyListeners();
  }
}
