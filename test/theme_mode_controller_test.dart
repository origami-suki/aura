import 'package:aura_weather/viewmodels/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to system and can set light dark and system', () async {
    final controller = ThemeModeController();

    await controller.load();

    expect(controller.themeMode, ThemeMode.system);

    await controller.setThemeMode(ThemeMode.light);
    expect(controller.themeMode, ThemeMode.light);

    await controller.setThemeMode(ThemeMode.dark);
    expect(controller.themeMode, ThemeMode.dark);

    await controller.setThemeMode(ThemeMode.system);
    expect(controller.themeMode, ThemeMode.system);
  });

  test('loads persisted mode from shared preferences', () async {
    SharedPreferences.setMockInitialValues({
      ThemeModeController.preferenceKey: ThemeMode.dark.name,
    });
    final controller = ThemeModeController();

    await controller.load();

    expect(controller.themeMode, ThemeMode.dark);
  });
}
