class WeatherNow {
  final int temp;
  final int feelsLike;
  final String condition;
  final String icon;
  final double precip;
  final int windSpeed;
  final String windDir;
  final double visibility;
  final int humidity;
  final int dewPoint;
  final int pressure;

  WeatherNow({
    required this.temp,
    required this.feelsLike,
    required this.condition,
    required this.icon,
    required this.precip,
    required this.windSpeed,
    required this.windDir,
    required this.visibility,
    required this.humidity,
    required this.dewPoint,
    required this.pressure,
  });

  factory WeatherNow.fromJson(Map<String, dynamic> json) {
    // Note: API returns numbers as strings in the "now" object
    final now = json['now'] as Map<String, dynamic>? ?? {};

    return WeatherNow(
      temp: int.tryParse(now['temp']?.toString() ?? '') ?? 0,
      feelsLike: int.tryParse(now['feelsLike']?.toString() ?? '') ?? 0,
      condition: now['text']?.toString() ?? '',
      icon: now['icon']?.toString() ?? '',
      precip: double.tryParse(now['precip']?.toString() ?? '') ?? 0.0,
      windSpeed: int.tryParse(now['windSpeed']?.toString() ?? '') ?? 0,
      windDir: now['windDir']?.toString() ?? '',
      visibility: double.tryParse(now['vis']?.toString() ?? '') ?? 0.0,
      humidity: int.tryParse(now['humidity']?.toString() ?? '') ?? 0,
      dewPoint: int.tryParse(now['dew']?.toString() ?? '') ?? 0,
      pressure: int.tryParse(now['pressure']?.toString() ?? '') ?? 0,
    );
  }
}
