class DailyForecast {
  final String date; // e.g., "2023-10-27"
  final String dayOfWeek; // e.g., "Mon"
  final int tempMax;
  final int tempMin;
  final String icon;
  final int pop; // Probability of precipitation percentage

  DailyForecast({
    required this.date,
    required this.dayOfWeek,
    required this.tempMax,
    required this.tempMin,
    required this.icon,
    required this.pop,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      tempMax: json['temp_max'] as int? ?? 0,
      tempMin: json['temp_min'] as int? ?? 0,
      icon: json['icon'] as String? ?? '',
      pop: json['pop'] as int? ?? 0,
    );
  }
}
