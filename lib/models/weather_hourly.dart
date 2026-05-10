import 'package:intl/intl.dart';

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
    String formattedTime = '';
    try {
      final fxTime = json['fxTime'] as String?;
      if (fxTime != null) {
        final dt = DateTime.parse(fxTime);
        formattedTime = DateFormat('HH:mm').format(dt);
      }
    } catch (_) {}

    return HourlyForecast(
      time: formattedTime,
      icon: json['icon']?.toString() ?? '',
      temp: int.tryParse(json['temp']?.toString() ?? '') ?? 0,
    );
  }
}
