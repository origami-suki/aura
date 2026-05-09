import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeController extends ChangeNotifier {
  ThemeModeController({SharedPreferences? preferences})
    : _preferences = preferences;

  static const preferenceKey = 'theme_mode';

  SharedPreferences? _preferences;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final preferences = await _ensurePreferences();
    final storedMode = _themeModeFromName(preferences.getString(preferenceKey));

    if (storedMode == _themeMode) return;

    _themeMode = storedMode;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) {
      await _persist(mode);
      return;
    }

    _themeMode = mode;
    notifyListeners();
    await _persist(mode);
  }

  Future<SharedPreferences> _ensurePreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> _persist(ThemeMode mode) async {
    final preferences = await _ensurePreferences();
    await preferences.setString(preferenceKey, mode.name);
  }

  ThemeMode _themeModeFromName(String? name) {
    return switch (name) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
