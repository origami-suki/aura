import '../models/location.dart';
import '../models/weather_now.dart';
import '../models/weather_hourly.dart';
import '../models/weather_daily.dart';
import '../models/indices.dart';

class WeatherUiState {
  final bool isLoading;
  final String? errorMessage;
  final LocationResponse? location;
  final WeatherNow? weatherNow;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final AqiNow? aqiNow;
  final List<IndexInfo> indices;

  WeatherUiState({
    this.isLoading = true,
    this.errorMessage,
    this.location,
    this.weatherNow,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
    this.aqiNow,
    this.indices = const [],
  });

  WeatherUiState copyWith({
    bool? isLoading,
    String? errorMessage,
    LocationResponse? location,
    WeatherNow? weatherNow,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
    AqiNow? aqiNow,
    List<IndexInfo>? indices,
  }) {
    return WeatherUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      location: location ?? this.location,
      weatherNow: weatherNow ?? this.weatherNow,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      aqiNow: aqiNow ?? this.aqiNow,
      indices: indices ?? this.indices,
    );
  }
}
