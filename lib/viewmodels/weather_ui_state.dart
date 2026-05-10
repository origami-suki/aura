import '../models/location.dart';
import '../models/weather_now.dart';
import '../models/weather_hourly.dart';
import '../models/weather_daily.dart';
import '../models/indices.dart';

class WeatherUiState {
  static const Object _unset = Object();

  final bool isLoading;
  final String? errorMessage;
  final LocationResponse? location;
  final WeatherNow? weatherNow;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final AqiNow? aqiNow;
  final List<IndexInfo> indices;
  final List<CitySearchResult> citySearchResults;
  final bool isSearchingCities;
  final String? citySearchError;

  WeatherUiState({
    this.isLoading = true,
    this.errorMessage,
    this.location,
    this.weatherNow,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
    this.aqiNow,
    this.indices = const [],
    this.citySearchResults = const [],
    this.isSearchingCities = false,
    this.citySearchError,
  });

  WeatherUiState copyWith({
    bool? isLoading,
    Object? errorMessage = _unset,
    Object? location = _unset,
    Object? weatherNow = _unset,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
    Object? aqiNow = _unset,
    List<IndexInfo>? indices,
    List<CitySearchResult>? citySearchResults,
    bool? isSearchingCities,
    Object? citySearchError = _unset,
  }) {
    return WeatherUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      location: identical(location, _unset)
          ? this.location
          : location as LocationResponse?,
      weatherNow: identical(weatherNow, _unset)
          ? this.weatherNow
          : weatherNow as WeatherNow?,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      aqiNow: identical(aqiNow, _unset) ? this.aqiNow : aqiNow as AqiNow?,
      indices: indices ?? this.indices,
      citySearchResults: citySearchResults ?? this.citySearchResults,
      isSearchingCities: isSearchingCities ?? this.isSearchingCities,
      citySearchError: identical(citySearchError, _unset)
          ? this.citySearchError
          : citySearchError as String?,
    );
  }
}
