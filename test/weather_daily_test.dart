import 'package:aura_weather/models/weather_daily.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyForecast.fromJson', () {
    test('parses documented daily precipitation amount from string values', () {
      final forecast = DailyForecast.fromJson({
        'fxDate': '2026-05-09',
        'tempMax': '25',
        'tempMin': '17',
        'iconDay': '305',
        'pop': '40',
        'precip': '2.5',
        'sunrise': '05:03',
        'sunset': '19:18',
        'uvIndex': '6',
      });

      expect(forecast.precip, 2.5);
      expect(forecast.pop, 40);
    });

    test('parses documented daily precipitation amount from numeric values', () {
      final forecast = DailyForecast.fromJson({
        'fxDate': '2026-05-09',
        'tempMax': 25,
        'tempMin': 17,
        'iconDay': 305,
        'pop': 40,
        'precip': 3,
        'sunrise': '05:03',
        'sunset': '19:18',
        'uvIndex': 6,
      });

      expect(forecast.precip, 3.0);
    });
  });
}
