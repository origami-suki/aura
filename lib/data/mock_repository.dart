import '../models/location.dart';
import '../models/weather_now.dart';
import '../models/weather_hourly.dart';
import '../models/weather_daily.dart';
import '../models/indices.dart';

class MockWeatherRepository {
  Future<LocationResponse> getLocation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return LocationResponse(
      deviceId: "mock-device-id",
      longitude: -122.084,
      latitude: 37.422,
      cityName: "Mountain View",
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  Future<WeatherNow> getWeatherNow(String location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return WeatherNow(
      temp: 22,
      feelsLike: 24,
      condition: "Sunny",
      icon: "sunny",
      precip: 0.0,
      windSpeed: 12,
      windDir: "NE",
      sunrise: "06:30",
      sunset: "18:45",
      uvIndex: 7,
      uvDesc: "High",
      visibility: 16.0,
      humidity: 45,
      dewPoint: 10,
      pressure: 1012,
    );
  }

  Future<List<HourlyForecast>> getHourlyForecast(String location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      HourlyForecast(time: "Now", icon: "sunny", temp: 22),
      HourlyForecast(time: "13:00", icon: "sunny", temp: 24),
      HourlyForecast(time: "14:00", icon: "partly_cloudy", temp: 25),
      HourlyForecast(time: "15:00", icon: "cloudy", temp: 23),
      HourlyForecast(time: "16:00", icon: "rain", temp: 21),
    ];
  }

  Future<List<DailyForecast>> getDailyForecast(String location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      DailyForecast(date: "2023-10-27", dayOfWeek: "Today", tempMax: 26, tempMin: 15, icon: "sunny", pop: 10),
      DailyForecast(date: "2023-10-28", dayOfWeek: "Mon", tempMax: 24, tempMin: 14, icon: "partly_cloudy", pop: 20),
      DailyForecast(date: "2023-10-29", dayOfWeek: "Tue", tempMax: 22, tempMin: 12, icon: "rain", pop: 80),
      DailyForecast(date: "2023-10-30", dayOfWeek: "Wed", tempMax: 20, tempMin: 10, icon: "cloudy", pop: 40),
      DailyForecast(date: "2023-10-31", dayOfWeek: "Thu", tempMax: 23, tempMin: 11, icon: "sunny", pop: 0),
    ];
  }

  Future<AqiNow> getAqiNow(String location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AqiNow(aqi: 45, category: "Good");
  }

  Future<List<IndexInfo>> getIndices(String location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      IndexInfo(type: "Dressing", name: "Dressing Index", category: "Warm", text: "T-shirts and shorts are suitable."),
      IndexInfo(type: "UV", name: "UV Index", category: "High", text: "Apply sunscreen and wear a hat."),
      IndexInfo(type: "Sports", name: "Sports Index", category: "Good", text: "Perfect weather for outdoor sports."),
    ];
  }
}
