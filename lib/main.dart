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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _weatherSeed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );

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
}
