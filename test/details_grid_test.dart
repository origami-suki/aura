import 'package:aura_weather/models/weather_daily.dart';
import 'package:aura_weather/models/weather_now.dart';
import 'package:aura_weather/ui/details_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('precipitation card displays today forecast precipitation', (tester) async {
    final weather = WeatherNow(
      temp: 20,
      feelsLike: 20,
      condition: 'Cloudy',
      icon: '101',
      precip: 0,
      windSpeed: 12,
      windDir: 'East',
      visibility: 10,
      humidity: 60,
      dewPoint: 12,
      pressure: 1008,
    );

    final today = DailyForecast(
      date: '05/09',
      dayOfWeek: 'Today',
      tempMax: 24,
      tempMin: 16,
      icon: '305',
      pop: 0,
      precip: 2.5,
      sunrise: '05:03',
      sunset: '19:18',
      uvIndex: 6,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DetailsStaggeredGrid(weather: weather, todayForecast: today),
          ),
        ),
      ),
    );

    expect(find.text('2.5 mm'), findsOneWidget);
    expect(find.text('0 mm'), findsNothing);
  });
}
