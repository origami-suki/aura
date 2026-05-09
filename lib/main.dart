import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/theme_mode_controller.dart';
import 'viewmodels/weather_view_model.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeModeController()..load()),
      ],
      child: const AuraWeatherApp(),
    ),
  );
}

class AuraWeatherApp extends StatelessWidget {
  const AuraWeatherApp({super.key});

  static const Color _weatherSeed = Color(0xFF2F6FED);

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeController>().themeMode;

    return MaterialApp(
      title: 'Aura Weather',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: _weatherSeed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );
    final colorScheme = brightness == Brightness.light
        ? _buildLightSurfaceScheme(baseColorScheme)
        : baseColorScheme;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  ColorScheme _buildLightSurfaceScheme(ColorScheme colorScheme) {
    return colorScheme.copyWith(
      surface: const Color(0xFFF4F7FB),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFBFCFE),
      surfaceContainer: Colors.white,
      surfaceContainerHigh: const Color(0xFFF0F4FA),
      surfaceContainerHighest: const Color(0xFFE8EFF7),
      outlineVariant: const Color(0xFFD7E0EC),
      surfaceTint: _weatherSeed,
    );
  }
}
