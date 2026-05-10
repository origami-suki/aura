import 'package:aura_weather/main.dart';
import 'package:aura_weather/models/location.dart';
import 'package:aura_weather/ui/home_screen.dart';
import 'package:aura_weather/viewmodels/theme_mode_controller.dart';
import 'package:aura_weather/viewmodels/weather_ui_state.dart';
import 'package:aura_weather/viewmodels/weather_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AuraWeatherApp light theme softens scaffold and card surfaces', (
    tester,
  ) async {
    final controller = ThemeModeController();
    await controller.setThemeMode(ThemeMode.light);

    await tester.pumpWidget(_buildApp(controller));

    final theme = Theme.of(tester.element(find.byType(HomeScreen)));

    expect(theme.scaffoldBackgroundColor, const Color(0xFFF4F7FB));
    expect(theme.colorScheme.surface, const Color(0xFFF4F7FB));
    expect(theme.colorScheme.surfaceContainer, Colors.white);
    expect(theme.colorScheme.surfaceContainerHigh, const Color(0xFFF0F4FA));
    expect(theme.colorScheme.outlineVariant, const Color(0xFFD7E0EC));
  });

  testWidgets('AuraWeatherApp dark theme keeps generated surface palette', (
    tester,
  ) async {
    final controller = ThemeModeController();
    await controller.setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(_buildApp(controller));

    final colorScheme = Theme.of(
      tester.element(find.byType(HomeScreen)),
    ).colorScheme;
    final generatedDarkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F6FED),
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );

    expect(colorScheme.surface, generatedDarkScheme.surface);
    expect(colorScheme.surfaceContainer, generatedDarkScheme.surfaceContainer);
    expect(colorScheme.outlineVariant, generatedDarkScheme.outlineVariant);
  });
}

Widget _buildApp(ThemeModeController controller) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<WeatherViewModel>.value(
        value: _FakeWeatherViewModel(
          WeatherUiState(isLoading: false, errorMessage: 'Theme probe'),
        ),
      ),
      ChangeNotifierProvider<ThemeModeController>.value(value: controller),
    ],
    child: const AuraWeatherApp(),
  );
}

class _FakeWeatherViewModel extends WeatherViewModel {
  _FakeWeatherViewModel(this._state) : super(autoLoad: false);

  final WeatherUiState _state;

  @override
  WeatherUiState get uiState => _state;

  @override
  Future<void> loadWeatherData() async {}

  @override
  Future<void> searchCities(String query, {String lang = 'zh'}) async {}

  @override
  void clearCitySearch() {}

  @override
  Future<void> selectCity(CitySearchResult result) async {}
}
