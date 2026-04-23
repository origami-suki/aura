class HourlyForecast {
  final String time; // e.g., "13:00"
  final String icon;
  final int temp;

  HourlyForecast({
    required this.time,
    required this.icon,
    required this.temp,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      temp: json['temp'] as int? ?? 0,
    );
  }
}
