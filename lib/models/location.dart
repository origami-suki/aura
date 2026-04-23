class Location {
  final double longitude;
  final double latitude;
  final String? cityName;

  Location({
    required this.longitude,
    required this.latitude,
    this.cityName,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      cityName: json['city_name'] as String?,
    );
  }
}

class LocationResponse {
  final String deviceId;
  final double longitude;
  final double latitude;
  final String? cityName;
  final String updatedAt;

  LocationResponse({
    required this.deviceId,
    required this.longitude,
    required this.latitude,
    this.cityName,
    required this.updatedAt,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      deviceId: json['device_id'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      cityName: json['city_name'] as String?,
      updatedAt: json['updated_at'] as String,
    );
  }
}
