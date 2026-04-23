class AqiNow {
  final int aqi;
  final String category; // e.g., "Good", "Moderate"

  AqiNow({
    required this.aqi,
    required this.category,
  });

  factory AqiNow.fromJson(Map<String, dynamic> json) {
    final now = json['now'] as Map<String, dynamic>? ?? {};

    return AqiNow(
      aqi: int.tryParse(now['aqi']?.toString() ?? '') ?? 0,
      category: now['category']?.toString() ?? 'Unknown',
    );
  }
}

class IndexInfo {
  final String type;
  final String name;
  final String category;
  final String text;

  IndexInfo({
    required this.type,
    required this.name,
    required this.category,
    required this.text,
  });

  factory IndexInfo.fromJson(Map<String, dynamic> json) {
    return IndexInfo(
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}
