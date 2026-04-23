import 'package:intl/intl.dart';

class DailyForecast {
  final String date;
  final String dayOfWeek;
  final int tempMax;
  final int tempMin;
  final String icon;
  final int pop;
  final String sunrise;
  final String sunset;
  final int uvIndex;

  DailyForecast({
    required this.date,
    required this.dayOfWeek,
    required this.tempMax,
    required this.tempMin,
    required this.icon,
    required this.pop,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    String dayOfWeek = '';

    try {
      final fxDate = json['fxDate'] as String?;
      if (fxDate != null) {
        final dt = DateTime.parse(fxDate);
        formattedDate = DateFormat('MM/dd').format(dt);

        // Simple day of week mapping
        if (dt.day == DateTime.now().day && dt.month == DateTime.now().month) {
          dayOfWeek = "Today";
        } else {
          dayOfWeek = DateFormat('EEE').format(dt);
        }
      }
    } catch (_) {}

    return DailyForecast(
      date: formattedDate,
      dayOfWeek: dayOfWeek,
      tempMax: int.tryParse(json['tempMax']?.toString() ?? '') ?? 0,
      tempMin: int.tryParse(json['tempMin']?.toString() ?? '') ?? 0,
      icon: json['iconDay']?.toString() ?? '', // Using daytime icon
      pop: int.tryParse(json['pop']?.toString() ?? '') ?? 0,
      sunrise: json['sunrise']?.toString() ?? '',
      sunset: json['sunset']?.toString() ?? '',
      uvIndex: int.tryParse(json['uvIndex']?.toString() ?? '') ?? 0,
    );
  }
}
