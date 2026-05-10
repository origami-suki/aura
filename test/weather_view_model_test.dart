import 'package:aura_weather/data/api_repository.dart';
import 'package:aura_weather/models/indices.dart';
import 'package:aura_weather/models/location.dart';
import 'package:aura_weather/models/weather_daily.dart';
import 'package:aura_weather/models/weather_hourly.dart';
import 'package:aura_weather/models/weather_now.dart';
import 'package:aura_weather/services/device_location_service.dart';
import 'package:aura_weather/viewmodels/weather_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final shanghaiResult = CitySearchResult(
    name: '上海',
    id: '101020100',
    latitude: 31.23,
    longitude: 121.47,
    adm1: '上海',
    adm2: '上海',
    country: '中国',
    tz: 'Asia/Shanghai',
    utcOffset: '+08:00',
    isDst: '0',
    type: 'city',
    rank: '10',
    fxLink: '',
  );

  group('WeatherViewModel location bootstrap', () {
    test('existing saved location does not request device location', () async {
      final repository = _FakeRepository(
        savedLocation: LocationResponse(
          deviceId: 'test-device',
          longitude: 116.40,
          latitude: 39.90,
          cityName: 'Beijing',
          updatedAt: '2026-01-01T00:00:00Z',
        ),
      );
      final locationService = _FakeLocationService(null);

      final viewModel = WeatherViewModel(
        repository: repository,
        locationService: locationService,
        autoLoad: false,
      );

      await viewModel.loadWeatherData();

      expect(repository.getSavedLocationCalled, isTrue);
      expect(repository.saveLocationCalled, isFalse);
      expect(repository.getLocationCalled, isTrue);
      expect(locationService.getCurrentPositionCalled, isFalse);

      viewModel.dispose();
    });

    test(
      'no saved location + granted coordinates saves GPS before weather load',
      () async {
        final repository = _FakeRepository(
          savedOnGetLocation: true,
          searchCityResults: [shanghaiResult],
        );
        final locationService = _FakeLocationService(
          (longitude: 121.47, latitude: 31.23),
        );

        final viewModel = WeatherViewModel(
          repository: repository,
          locationService: locationService,
          autoLoad: false,
        );

        await viewModel.loadWeatherData();

        expect(repository.getSavedLocationCalled, isTrue);
        expect(repository.saveLocationCalled, isTrue);
        expect(repository.savedLongitude, 121.47);
        expect(repository.savedLatitude, 31.23);
        expect(repository.savedCityName, '上海');
        expect(repository.searchCityCalled, isTrue);
        expect(repository.searchCityQuery, '121.47,31.23');
        expect(
          repository.callLog.indexOf('searchCity'),
          lessThan(repository.callLog.indexOf('saveLocation')),
        );
        expect(repository.getLocationCalled, isTrue);
        expect(
          repository.callLog.indexOf('saveLocation'),
          lessThan(repository.callLog.indexOf('getWeatherNow')),
        );
        expect(locationService.getCurrentPositionCalled, isTrue);

        viewModel.dispose();
      },
    );

    test(
      'no saved location + denied device location falls back to default path',
      () async {
        final repository = _FakeRepository(
          savedOnGetLocation: true,
        );
        final locationService = _FakeLocationService(null);

        final viewModel = WeatherViewModel(
          repository: repository,
          locationService: locationService,
          autoLoad: false,
        );

        await viewModel.loadWeatherData();

        expect(repository.getSavedLocationCalled, isTrue);
        expect(repository.saveLocationCalled, isFalse);
        expect(repository.getLocationCalled, isTrue);
        expect(locationService.getCurrentPositionCalled, isTrue);

        viewModel.dispose();
      },
    );

    test(
      'unsupported platform service returns null, falls back to default',
      () async {
        final repository = _FakeRepository(
          savedOnGetLocation: true,
        );
        final locationService = _AlwaysNullLocationService();

        final viewModel = WeatherViewModel(
          repository: repository,
          locationService: locationService,
          autoLoad: false,
        );

        await viewModel.loadWeatherData();

        expect(repository.getSavedLocationCalled, isTrue);
        expect(repository.saveLocationCalled, isFalse);
        expect(repository.getLocationCalled, isTrue);
        expect(locationService.getCurrentPositionCalled, isTrue);

        viewModel.dispose();
      },
    );

    test(
      'city search failure still saves GPS coords with null cityName',
      () async {
        final repository = _FakeRepository(
          savedOnGetLocation: true,
          searchCityThrows: true,
        );
        final locationService = _FakeLocationService(
          (longitude: 121.47, latitude: 31.23),
        );

        final viewModel = WeatherViewModel(
          repository: repository,
          locationService: locationService,
          autoLoad: false,
        );

        await viewModel.loadWeatherData();

        expect(repository.searchCityCalled, isTrue);
        expect(repository.saveLocationCalled, isTrue);
        expect(repository.savedLongitude, 121.47);
        expect(repository.savedLatitude, 31.23);
        expect(repository.savedCityName, isNull);
        expect(repository.getLocationCalled, isTrue);

        viewModel.dispose();
      },
    );

    test(
      'empty city search results still saves GPS coords with null cityName',
      () async {
        final repository = _FakeRepository(
          savedOnGetLocation: true,
          searchCityResults: [],
        );
        final locationService = _FakeLocationService(
          (longitude: 121.47, latitude: 31.23),
        );

        final viewModel = WeatherViewModel(
          repository: repository,
          locationService: locationService,
          autoLoad: false,
        );

        await viewModel.loadWeatherData();

        expect(repository.searchCityCalled, isTrue);
        expect(repository.saveLocationCalled, isTrue);
        expect(repository.savedLongitude, 121.47);
        expect(repository.savedLatitude, 31.23);
        expect(repository.savedCityName, isNull);
        expect(repository.getLocationCalled, isTrue);

        viewModel.dispose();
      },
    );
  });
}

/// Fake [ApiWeatherRepository] that returns canned data and tracks calls.
class _FakeRepository extends ApiWeatherRepository {
  _FakeRepository({
    this.savedLocation,
    this.savedOnGetLocation = false,
    this.searchCityResults = const [],
    this.searchCityThrows = false,
  });

  final LocationResponse? savedLocation;
  final bool savedOnGetLocation;
  final List<CitySearchResult> searchCityResults;
  final bool searchCityThrows;
  bool getSavedLocationCalled = false;
  bool saveLocationCalled = false;
  double? savedLongitude;
  double? savedLatitude;
  String? savedCityName;
  bool getLocationCalled = false;
  bool searchCityCalled = false;
  String? searchCityQuery;
  final List<String> callLog = [];

  @override
  Future<LocationResponse?> getSavedLocation() async {
    callLog.add('getSavedLocation');
    getSavedLocationCalled = true;
    return savedLocation;
  }

  @override
  Future<void> saveLocation({
    required double longitude,
    required double latitude,
    String? cityName,
  }) async {
    callLog.add('saveLocation');
    saveLocationCalled = true;
    savedLongitude = longitude;
    savedLatitude = latitude;
    savedCityName = cityName;
  }

  @override
  Future<List<CitySearchResult>> searchCity(
    String query, {
    String lang = 'zh',
  }) async {
    callLog.add('searchCity');
    searchCityCalled = true;
    searchCityQuery = query;
    if (searchCityThrows) {
      throw Exception('Search failed');
    }
    return searchCityResults;
  }

  @override
  Future<LocationResponse> getLocation() async {
    callLog.add('getLocation');
    getLocationCalled = true;
    final loc = savedLocation;
    if (loc != null) return loc;
    if (savedOnGetLocation) {
      return LocationResponse(
        deviceId: 'test-device',
        longitude: savedLongitude ?? 121.47,
        latitude: savedLatitude ?? 31.23,
        cityName: savedCityName,
        updatedAt: '2026-01-01T00:00:00Z',
      );
    }
    return LocationResponse(
      deviceId: 'test-device',
      longitude: 108.9398,
      latitude: 34.3416,
      cityName: '西安',
      updatedAt: '2026-01-01T00:00:00Z',
    );
  }

  @override
  Future<WeatherNow> getWeatherNow(String location) async {
    callLog.add('getWeatherNow');
    return WeatherNow(
      temp: 22,
      feelsLike: 23,
      condition: 'Clear',
      icon: '100',
      precip: 0,
      windSpeed: 10,
      windDir: 'N',
      visibility: 10,
      humidity: 55,
      dewPoint: 12,
      pressure: 1013,
    );
  }

  @override
  Future<List<HourlyForecast>> getHourlyForecast(String location) async => [
    HourlyForecast(time: '14:00', icon: '100', temp: 22),
  ];

  @override
  Future<List<DailyForecast>> getDailyForecast(String location) async => [
    DailyForecast(
      date: '05/09',
      dayOfWeek: 'Today',
      tempMax: 25,
      tempMin: 15,
      icon: '100',
      pop: 0,
      precip: 0,
      sunrise: '06:00',
      sunset: '18:00',
      uvIndex: 5,
    ),
  ];

  @override
  Future<AqiNow> getAqiNow(String location) async =>
      AqiNow(aqi: 42, category: 'Good');

  @override
  Future<List<IndexInfo>> getIndices(String location) async => [];
}

/// Fake [DeviceLocationService] that returns a fixed position.
class _FakeLocationService extends DeviceLocationService {
  _FakeLocationService(this._position);

  final ({double longitude, double latitude})? _position;
  bool getCurrentPositionCalled = false;

  @override
  Future<({double longitude, double latitude})?> getCurrentPosition() async {
    getCurrentPositionCalled = true;
    return _position;
  }
}

/// Fake [DeviceLocationService] that always returns null (non-Android).
class _AlwaysNullLocationService extends DeviceLocationService {
  bool getCurrentPositionCalled = false;

  @override
  Future<({double longitude, double latitude})?> getCurrentPosition() async {
    getCurrentPositionCalled = true;
    return null;
  }
}
