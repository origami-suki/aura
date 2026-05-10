import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../models/location.dart';
import '../models/weather_now.dart';
import '../models/weather_hourly.dart';
import '../models/weather_daily.dart';
import '../models/indices.dart';

class ApiWeatherRepository {
  final http.Client _client = http.Client();
  String? _deviceId;

  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');

    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }

    return _deviceId!;
  }

  Future<Map<String, String>> _getHeaders() async {
    final deviceId = await _getDeviceId();
    return {'Content-Type': 'application/json', 'X-Device-ID': deviceId};
  }

  /// Returns the device's saved backend location, or null when none exists.
  ///
  /// Does NOT trigger the default Xi'an fallback. Callers that need the
  /// default behavior should use [getLocation] instead.
  Future<LocationResponse?> getSavedLocation() async {
    final headers = await _getHeaders();
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/user/location'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return LocationResponse.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load location: ${response.statusCode}');
    }
  }

  /// Returns the persisted device location, creating a default Xi'an fixture
  /// if none exists. Callers that need to detect a missing location before
  /// the default is saved should use [getSavedLocation].
  Future<LocationResponse> getLocation() async {
    final saved = await getSavedLocation();
    if (saved != null) return saved;

    await saveLocation(
      longitude: 108.9398,
      latitude: 34.3416,
      cityName: '西安',
    );
    return getLocation();
  }

  Future<void> saveLocation({
    required double longitude,
    required double latitude,
    String? cityName,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'longitude': longitude,
      'latitude': latitude,
      'city_name': cityName,
    });

    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/user/location'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save location');
    }
  }

  Future<List<CitySearchResult>> searchCity(
    String query, {
    String lang = 'zh',
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/city/search',
    ).replace(queryParameters: {'location': trimmedQuery, 'lang': lang});

    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final code = json['code']?.toString();
      if (code != null && code != '200') {
        throw Exception('City search failed with code $code');
      }
      final List<dynamic> locationsJson = json['location'] ?? [];
      return locationsJson.map((e) => CitySearchResult.fromJson(e)).toList();
    }

    throw Exception('Failed to search city: ${response.statusCode}');
  }

  Future<WeatherNow> getWeatherNow(String location) async {
    final response = await _client.get(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/weather/now?location=$location&lang=zh&unit=m',
      ),
    );
    if (response.statusCode == 200) {
      return WeatherNow.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Failed to load weather now');
  }

  Future<List<HourlyForecast>> getHourlyForecast(String location) async {
    final response = await _client.get(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/weather/hourly?location=$location&lang=zh&unit=m',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> hourlyJson = json['hourly'] ?? [];
      return hourlyJson.map((e) => HourlyForecast.fromJson(e)).toList();
    }
    throw Exception('Failed to load hourly forecast');
  }

  Future<List<DailyForecast>> getDailyForecast(String location) async {
    final response = await _client.get(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/weather/daily?location=$location&lang=zh&unit=m',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> dailyJson = json['daily'] ?? [];
      return dailyJson.map((e) => DailyForecast.fromJson(e)).toList();
    }
    throw Exception('Failed to load daily forecast');
  }

  Future<AqiNow> getAqiNow(String location) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/aqi/now?location=$location&lang=zh'),
    );
    if (response.statusCode == 200) {
      return AqiNow.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Failed to load AQI');
  }

  Future<List<IndexInfo>> getIndices(String location) async {
    // 0 = all indices
    final response = await _client.get(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/indices?location=$location&type=0&lang=zh',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> indicesJson = json['daily'] ?? [];
      return indicesJson.map((e) => IndexInfo.fromJson(e)).toList();
    }
    throw Exception('Failed to load indices');
  }

  void dispose() {
    _client.close();
  }
}
