import 'package:flutter/foundation.dart';
import '../data/api_repository.dart';

import '../models/location.dart';
import '../models/weather_now.dart';
import '../models/weather_hourly.dart';
import '../models/weather_daily.dart';
import '../models/indices.dart';
import 'weather_ui_state.dart';

class WeatherViewModel extends ChangeNotifier {
  final ApiWeatherRepository _repository = ApiWeatherRepository();
  WeatherUiState _uiState = WeatherUiState();
  int _citySearchRequestId = 0;

  WeatherUiState get uiState => _uiState;

  WeatherViewModel() {
    loadWeatherData();
  }

  Future<void> loadWeatherData() async {
    _uiState = _uiState.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final location = await _repository.getLocation();
      final locString = "${location.longitude},${location.latitude}";

      // Fetch each endpoint independently so one failure doesn't block others.
      final results = await Future.wait([
        _tryFetch(() => _repository.getWeatherNow(locString)),
        _tryFetch(() => _repository.getHourlyForecast(locString)),
        _tryFetch(() => _repository.getDailyForecast(locString)),
        _tryFetch(() => _repository.getAqiNow(locString)),
        _tryFetch(() => _repository.getIndices(locString)),
      ]);

      final weatherNow = results[0] as WeatherNow?;
      final hourlyForecast = results[1] as List<HourlyForecast>? ?? [];
      final dailyForecast = results[2] as List<DailyForecast>? ?? [];
      final aqiNow = results[3] as AqiNow?;
      final indices = results[4] as List<IndexInfo>? ?? [];

      if (weatherNow == null &&
          dailyForecast.isEmpty &&
          hourlyForecast.isEmpty) {
        _uiState = _uiState.copyWith(
          isLoading: false,
          errorMessage: "Failed to load weather data. Pull to retry.",
        );
      } else {
        _uiState = _uiState.copyWith(
          isLoading: false,
          location: location,
          weatherNow: weatherNow,
          hourlyForecast: hourlyForecast,
          dailyForecast: dailyForecast,
          aqiNow: aqiNow,
          indices: indices,
        );
      }
    } catch (e) {
      _uiState = _uiState.copyWith(
        isLoading: false,
        errorMessage: "Failed to load weather data: $e",
      );
    }
    notifyListeners();
  }

  Future<T?> _tryFetch<T>(Future<T> Function() fetcher) async {
    try {
      return await fetcher();
    } catch (_) {
      return null;
    }
  }

  Future<void> searchCities(String query, {String lang = 'en'}) async {
    final trimmedQuery = query.trim();
    final requestId = ++_citySearchRequestId;

    if (trimmedQuery.isEmpty) {
      _uiState = _uiState.copyWith(
        citySearchResults: [],
        isSearchingCities: false,
        citySearchError: null,
      );
      notifyListeners();
      return;
    }

    _uiState = _uiState.copyWith(
      isSearchingCities: true,
      citySearchError: null,
    );
    notifyListeners();

    try {
      final results = await _repository.searchCity(trimmedQuery, lang: lang);
      if (requestId != _citySearchRequestId) return;

      _uiState = _uiState.copyWith(
        citySearchResults: results,
        isSearchingCities: false,
        citySearchError: null,
      );
    } catch (_) {
      if (requestId != _citySearchRequestId) return;

      _uiState = _uiState.copyWith(
        citySearchResults: [],
        isSearchingCities: false,
        citySearchError: 'Failed to search cities. Please try again.',
      );
    }
    notifyListeners();
  }

  void clearCitySearch() {
    _citySearchRequestId++;
    _uiState = _uiState.copyWith(
      citySearchResults: [],
      isSearchingCities: false,
      citySearchError: null,
    );
    notifyListeners();
  }

  Future<void> selectCity(CitySearchResult result) async {
    try {
      _uiState = _uiState.copyWith(citySearchError: null);
      notifyListeners();

      await _repository.saveLocation(
        longitude: result.longitude,
        latitude: result.latitude,
        cityName: result.name,
      );
      await loadWeatherData();
    } catch (_) {
      _uiState = _uiState.copyWith(
        citySearchError: 'Failed to save city. Please try again.',
      );
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
