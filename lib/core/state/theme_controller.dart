import 'package:flutter/material.dart';

import '../storage/prefs_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) : mode = _parse(_prefs.getThemeMode());

  final PrefsService _prefs;
  ThemeMode mode;

  Future<void> setMode(ThemeMode value) async {
    if (mode == value) return;
    mode = value;
    await _prefs.setThemeMode(_name(value));
    notifyListeners();
  }

  static ThemeMode _parse(String value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String _name(ThemeMode value) => switch (value) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
