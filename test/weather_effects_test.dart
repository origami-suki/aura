import 'package:aura_weather/models/weather_now.dart';
import 'package:aura_weather/ui/weather_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const lightSurface = Color(0xFFF4F7FB);
  final lightScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2F6FED),
  ).copyWith(surface: lightSurface, surfaceContainer: Colors.white);

  final lightPalettes = [
    _AtmospherePaletteCase(
      description: 'clear-day',
      weather: _weather(condition: 'Clear', icon: '100'),
      colors: [
        const Color(0xFFA9DDF7),
        const Color(0xFFFFE2A1),
        Color.alphaBlend(const Color(0xFFFFF7E6).withAlpha(226), lightSurface),
      ],
    ),
    _AtmospherePaletteCase(
      description: 'cloud',
      weather: _weather(condition: 'Cloudy', icon: '101'),
      colors: [
        const Color(0xFFB9CAD6),
        const Color(0xFFD8E2EA),
        Color.alphaBlend(const Color(0xFFF3F7FA).withAlpha(218), lightSurface),
      ],
    ),
    _AtmospherePaletteCase(
      description: 'rain',
      weather: _weather(condition: 'Rain', icon: '305'),
      colors: [
        const Color(0xFF92AFC2),
        const Color(0xFFC2D5E1),
        Color.alphaBlend(const Color(0xFFEAF2F7).withAlpha(218), lightSurface),
      ],
    ),
    _AtmospherePaletteCase(
      description: 'mist',
      weather: _weather(condition: 'Haze', icon: '501'),
      colors: [
        const Color(0xFFCAD7DE),
        const Color(0xFFE1E9EE),
        Color.alphaBlend(const Color(0xFFF7FAFC).withAlpha(224), lightSurface),
      ],
    ),
  ];

  for (final palette in lightPalettes) {
    testWidgets(
      'WeatherAtmosphere renders soft light ${palette.description} gradient',
      (tester) async {
        await tester.pumpWidget(
          _buildAtmosphere(weather: palette.weather, colorScheme: lightScheme),
        );

        final gradient = _weatherGradient(tester);

        expect(gradient.colors, palette.colors);
        expect(gradient.stops, const [0, 0.48, 1]);
      },
    );
  }

  test('WeatherAtmosphere preview palettes expose compact source values', () {
    final previews = WeatherAtmosphere.previewPalettes(lightScheme);

    expect(previews.map((palette) => palette.label), [
      'Clear day',
      'Cloud',
      'Rain',
      'Mist',
      'Night',
    ]);
    expect(previews.first.colors, lightPalettes.first.colors);
    expect(previews[1].colors, lightPalettes[1].colors);
    expect(previews[2].colors, lightPalettes[2].colors);
    expect(previews[3].colors, lightPalettes[3].colors);
    expect(previews.last.colors, [
      const Color(0xFF171D52),
      const Color(0xFF3F4DBA),
      Color.alphaBlend(const Color(0xFF5E68BD).withAlpha(166), lightSurface),
    ]);
  });

  testWidgets('WeatherAtmosphere keeps dark weather gradient unchanged', (
    tester,
  ) async {
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F6FED),
      brightness: Brightness.dark,
    );

    await tester.pumpWidget(
      _buildAtmosphere(
        weather: _weather(condition: 'Clear', icon: '100'),
        colorScheme: darkScheme,
      ),
    );

    final gradient = _weatherGradient(tester);

    expect(gradient.colors, [
      const Color(0xFF171D52),
      const Color(0xFF3F4DBA),
      Color.alphaBlend(
        const Color(0xFF5E68BD).withAlpha(166),
        darkScheme.surface,
      ),
    ]);
  });
}

Widget _buildAtmosphere({
  required WeatherNow weather,
  required ColorScheme colorScheme,
}) {
  return MaterialApp(
    theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
    home: WeatherAtmosphere(weather: weather, child: const SizedBox.expand()),
  );
}

LinearGradient _weatherGradient(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.byWidgetPredicate((widget) {
      if (widget is! AnimatedContainer) {
        return false;
      }

      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.gradient is LinearGradient;
    }),
  );

  return (container.decoration! as BoxDecoration).gradient! as LinearGradient;
}

WeatherNow _weather({required String condition, required String icon}) {
  return WeatherNow(
    temp: 24,
    feelsLike: 26,
    condition: condition,
    icon: icon,
    precip: 0,
    windSpeed: 12,
    windDir: 'East',
    visibility: 10,
    humidity: 61,
    dewPoint: 16,
    pressure: 1012,
  );
}

class _AtmospherePaletteCase {
  final String description;
  final WeatherNow weather;
  final List<Color> colors;

  const _AtmospherePaletteCase({
    required this.description,
    required this.weather,
    required this.colors,
  });
}
