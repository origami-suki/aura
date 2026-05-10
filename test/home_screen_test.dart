import 'package:aura_weather/models/indices.dart';
import 'package:aura_weather/models/location.dart';
import 'package:aura_weather/models/weather_daily.dart';
import 'package:aura_weather/models/weather_hourly.dart';
import 'package:aura_weather/models/weather_now.dart';
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

  testWidgets('HomeScreen preserves loaded weather sections and actions', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHomeScreen(_loadedWeatherState()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.text('Testville'), findsOneWidget);
    expect(find.text('24°'), findsWidgets);
    expect(find.text('Feels like 26°'), findsOneWidget);
    expect(find.text('High 29° · Low 18°'), findsOneWidget);
    expect(find.text('Hourly forecast'), findsOneWidget);
    expect(find.text('10-Day forecast'), findsOneWidget);
    expect(find.text('Current details'), findsOneWidget);
    expect(find.text('Precipitation'), findsOneWidget);
    expect(find.text('Wind'), findsOneWidget);
    expect(find.text('Sunrise & Sunset'), findsOneWidget);
    expect(find.text('Visibility'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('UV Index'), findsOneWidget);
    expect(find.text('Pressure'), findsOneWidget);
    expect(find.text('Air Quality'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.location_on_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Choose location'), findsOneWidget);
    expect(find.text('Search city name...'), findsOneWidget);
    expect(find.text('Start with a city name'), findsOneWidget);
  });

  testWidgets('HomeScreen preserves loading and retry states', (tester) async {
    await tester.pumpWidget(_buildHomeScreen(WeatherUiState()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final viewModel = _FakeWeatherViewModel(
      WeatherUiState(
        isLoading: false,
        errorMessage: 'Unable to load test weather.',
      ),
    );

    await tester.pumpWidget(_buildHomeScreenWithViewModel(viewModel));

    expect(find.text('Unable to load test weather.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(viewModel.retryCount, 1);
  });

  testWidgets('HomeScreen theme menu exposes theme options and previews', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHomeScreen(_loadedWeatherState()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Weather backgrounds'), findsOneWidget);
    expect(find.text('Clear day'), findsOneWidget);
    expect(find.text('Cloud'), findsOneWidget);
    expect(find.text('Rain'), findsOneWidget);
    expect(find.text('Mist'), findsOneWidget);
    expect(find.text('Night'), findsOneWidget);
  });

  testWidgets('selecting a HomeScreen theme updates controller selection', (
    tester,
  ) async {
    final themeModeController = ThemeModeController();

    await tester.pumpWidget(
      _buildHomeScreen(_loadedWeatherState(), themeModeController),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(_themeModeSegment(tester).selected, {ThemeMode.system});

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(themeModeController.themeMode, ThemeMode.dark);
    expect(_themeModeSegment(tester).selected, {ThemeMode.dark});
  });
}

Widget _buildHomeScreen(
  WeatherUiState state, [
  ThemeModeController? themeModeController,
]) {
  return _buildHomeScreenWithViewModel(
    _FakeWeatherViewModel(state),
    themeModeController: themeModeController,
  );
}

Widget _buildHomeScreenWithViewModel(
  WeatherViewModel viewModel, {
  ThemeModeController? themeModeController,
}) {
  final controller = themeModeController ?? ThemeModeController();

  return ChangeNotifierProvider<ThemeModeController>.value(
    value: controller,
    child: Consumer<ThemeModeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeController.themeMode,
          home: ChangeNotifierProvider<WeatherViewModel>.value(
            value: viewModel,
            child: const HomeScreen(),
          ),
        );
      },
    ),
  );
}

SegmentedButton<ThemeMode> _themeModeSegment(WidgetTester tester) {
  return tester.widget<SegmentedButton<ThemeMode>>(
    find.byWidgetPredicate((widget) => widget is SegmentedButton<ThemeMode>),
  );
}

WeatherUiState _loadedWeatherState() {
  return WeatherUiState(
    isLoading: false,
    location: LocationResponse(
      deviceId: 'test-device',
      longitude: 116.40,
      latitude: 39.90,
      cityName: 'Testville',
      updatedAt: '2026-05-09T00:00:00Z',
    ),
    weatherNow: WeatherNow(
      temp: 24,
      feelsLike: 26,
      condition: 'Clear',
      icon: '100',
      precip: 0,
      windSpeed: 12,
      windDir: 'East',
      visibility: 10,
      humidity: 61,
      dewPoint: 16,
      pressure: 1012,
    ),
    hourlyForecast: [
      HourlyForecast(time: '09:00', icon: '100', temp: 24),
      HourlyForecast(time: '10:00', icon: '101', temp: 25),
    ],
    dailyForecast: [
      DailyForecast(
        date: '05/09',
        dayOfWeek: 'Today',
        tempMax: 29,
        tempMin: 18,
        icon: '100',
        pop: 10,
        precip: 0.2,
        sunrise: '05:03',
        sunset: '19:18',
        uvIndex: 6,
      ),
      DailyForecast(
        date: '05/10',
        dayOfWeek: 'Sun',
        tempMax: 27,
        tempMin: 17,
        icon: '305',
        pop: 40,
        precip: 2.5,
        sunrise: '05:02',
        sunset: '19:19',
        uvIndex: 4,
      ),
    ],
    aqiNow: AqiNow(aqi: 42, category: 'Good'),
  );
}

class _FakeWeatherViewModel extends WeatherViewModel {
  _FakeWeatherViewModel(this._state) : super(autoLoad: false);

  final WeatherUiState _state;
  int retryCount = 0;

  @override
  WeatherUiState get uiState => _state;

  @override
  Future<void> loadWeatherData() async {
    retryCount += 1;
  }

  @override
  Future<void> searchCities(String query, {String lang = 'zh'}) async {}

  @override
  void clearCitySearch() {}

  @override
  Future<void> selectCity(CitySearchResult result) async {}
}
