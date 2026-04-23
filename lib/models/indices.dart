class AqiNow {
  final int aqi;
  final String category; // e.g., "Good", "Moderate"

  AqiNow({
    required this.aqi,
    required this.category,
  });

  factory AqiNow.fromJson(Map<String, dynamic> json) {
    return AqiNow(
      aqi: json['aqi'] as int? ?? 0,
      category: json['category'] as String? ?? 'Unknown',
    );
  }
}

class IndexInfo {
  final String type; // e.g., "Dressing", "UV"
  final String name;
  final String category; // e.g., "Cold", "Strong"
  final String text; // detailed advice

  IndexInfo({
    required this.type,
    required this.name,
    required this.category,
    required this.text,
  });

  factory IndexInfo.fromJson(Map<String, dynamic> json) {
    return IndexInfo(
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}
