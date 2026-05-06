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
    return {
      'Content-Type': 'application/json',
      'X-Device-ID': deviceId,
    };
  }

  Future<LocationResponse> getLocation() async {
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse('${AppConfig.apiBaseUrl}/user/location'), headers: headers);

    if (response.statusCode == 200) {
      return LocationResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      // If no location found, save a default one and retry
      await saveLocation(longitude: -74.0060, latitude: 40.7128, cityName: "New York");
      return getLocation();
    } else {
      throw Exception('Failed to load location: ${response.statusCode}');
    }
  }

  Future<void> saveLocation({required double longitude, required double latitude, String? cityName}) async {
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

  Future<WeatherNow> getWeatherNow(String location) async {
    final response = await _client.get(Uri.parse('${AppConfig.apiBaseUrl}/weather/now?location=$location&lang=en&unit=m'));
    if (response.statusCode == 200) {
      return WeatherNow.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Failed to load weather now');
  }

  Future<List<HourlyForecast>> getHourlyForecast(String location) async {
    final response = await _client.get(Uri.parse('${AppConfig.apiBaseUrl}/weather/hourly?location=$location&lang=en&unit=m'));
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> hourlyJson = json['hourly'] ?? [];
      return hourlyJson.map((e) => HourlyForecast.fromJson(e)).toList();
    }
    throw Exception('Failed to load hourly forecast');
  }

  Future<List<DailyForecast>> getDailyForecast(String location) async {
    final response = await _client.get(Uri.parse('${AppConfig.apiBaseUrl}/weather/daily?location=$location&lang=en&unit=m'));
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> dailyJson = json['daily'] ?? [];
      return dailyJson.map((e) => DailyForecast.fromJson(e)).toList();
    }
    throw Exception('Failed to load daily forecast');
  }

  Future<AqiNow> getAqiNow(String location) async {
    final response = await _client.get(Uri.parse('${AppConfig.apiBaseUrl}/aqi/now?location=$location&lang=en'));
    if (response.statusCode == 200) {
      return AqiNow.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Failed to load AQI');
  }

  Future<List<IndexInfo>> getIndices(String location) async {
    // 0 = all indices
    final response = await _client.get(Uri.parse('${AppConfig.apiBaseUrl}/indices?location=$location&type=0&lang=en'));
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
