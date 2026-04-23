import 'package:flutter/foundation.dart';
import '../data/mock_repository.dart';
import 'weather_ui_state.dart';

class WeatherViewModel extends ChangeNotifier {
  final MockWeatherRepository _repository = MockWeatherRepository();
  WeatherUiState _uiState = WeatherUiState();

  WeatherUiState get uiState => _uiState;

  WeatherViewModel() {
    loadWeatherData();
  }

  Future<void> loadWeatherData() async {
    _uiState = _uiState.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final location = await _repository.getLocation();
      final locString = "\${location.latitude},\${location.longitude}";

      // Fetch all data in parallel to avoid flashing and improve speed
      final results = await Future.wait([
        _repository.getWeatherNow(locString),
        _repository.getHourlyForecast(locString),
        _repository.getDailyForecast(locString),
        _repository.getAqiNow(locString),
        _repository.getIndices(locString),
      ]);

      _uiState = _uiState.copyWith(
        isLoading: false,
        location: location,
        weatherNow: results[0] as dynamic,
        hourlyForecast: results[1] as dynamic,
        dailyForecast: results[2] as dynamic,
        aqiNow: results[3] as dynamic,
        indices: results[4] as dynamic,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isLoading: false,
        errorMessage: "Failed to load weather data: \$e",
      );
    }
    notifyListeners();
  }
}
