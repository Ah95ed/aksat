import 'package:flutter/material.dart';

import '../storage/prefs_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) : mode = ThemeMode.light;

  final PrefsService _prefs;
  ThemeMode mode = ThemeMode.light;

  bool get isDark => false;

  Future<void> toggle() async {}

  Future<void> setMode(ThemeMode value) async {
    mode = ThemeMode.light;
    await _prefs.setThemeMode('light');
    notifyListeners();
  }
}
