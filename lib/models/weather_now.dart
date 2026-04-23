class WeatherNow {
  final int temp;
  final int feelsLike;
  final String condition;
  final String icon;
  final double precip; // Precipitation in mm
  final int windSpeed; // km/h
  final String windDir;
  final String sunrise;
  final String sunset;
  final int uvIndex;
  final String uvDesc;
  final double visibility; // km
  final int humidity; // percentage
  final int dewPoint; // degrees
  final int pressure; // hPa

  WeatherNow({
    required this.temp,
    required this.feelsLike,
    required this.condition,
    required this.icon,
    required this.precip,
    required this.windSpeed,
    required this.windDir,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    required this.uvDesc,
    required this.visibility,
    required this.humidity,
    required this.dewPoint,
    required this.pressure,
  });

  factory WeatherNow.fromJson(Map<String, dynamic> json) {
    return WeatherNow(
      temp: json['temp'] as int? ?? 0,
      feelsLike: json['feels_like'] as int? ?? 0,
      condition: json['condition'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      precip: (json['precip'] as num?)?.toDouble() ?? 0.0,
      windSpeed: json['wind_speed'] as int? ?? 0,
      windDir: json['wind_dir'] as String? ?? '',
      sunrise: json['sunrise'] as String? ?? '',
      sunset: json['sunset'] as String? ?? '',
      uvIndex: json['uv_index'] as int? ?? 0,
      uvDesc: json['uv_desc'] as String? ?? '',
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0.0,
      humidity: json['humidity'] as int? ?? 0,
      dewPoint: json['dew_point'] as int? ?? 0,
      pressure: json['pressure'] as int? ?? 0,
    );
  }
}
