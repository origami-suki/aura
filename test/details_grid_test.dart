import 'package:aura_weather/models/weather_daily.dart';
import 'package:aura_weather/models/weather_now.dart';
import 'package:aura_weather/ui/details_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('precipitation card displays today forecast precipitation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DetailsStaggeredGrid(
              weather: _testWeather(),
              todayForecast: _testToday(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('2.5 mm'), findsOneWidget);
    expect(find.text('0 mm'), findsNothing);
  });

  testWidgets('sunrise and sunset labels do not overflow in narrow cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              // Ahem test text is wider than platform fonts; this still keeps
              // each details card narrow enough to catch the time-label row.
              width: 580,
              child: DetailsStaggeredGrid(
                weather: _testWeather(),
                todayForecast: _testToday(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Sunrise: 05:03'), findsOneWidget);
    expect(find.text('Sunset: 19:18'), findsOneWidget);
  });

  testWidgets('displays all seven current detail card labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DetailsStaggeredGrid(
              weather: _testWeather(),
              todayForecast: _testToday(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Precipitation'), findsOneWidget);
    expect(find.text('Wind'), findsOneWidget);
    expect(find.text('Sunrise & Sunset'), findsOneWidget);
    expect(find.text('Visibility'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('UV Index'), findsOneWidget);
    expect(find.text('Pressure'), findsOneWidget);
  });
}

WeatherNow _testWeather() {
  return WeatherNow(
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
}

DailyForecast _testToday() {
  return DailyForecast(
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
}
