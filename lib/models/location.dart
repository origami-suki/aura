class Location {
  final double longitude;
  final double latitude;
  final String? cityName;

  Location({required this.longitude, required this.latitude, this.cityName});

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

class CitySearchResult {
  final String name;
  final String id;
  final double latitude;
  final double longitude;
  final String adm1;
  final String adm2;
  final String country;
  final String tz;
  final String utcOffset;
  final String isDst;
  final String type;
  final String rank;
  final String fxLink;

  CitySearchResult({
    required this.name,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.adm1,
    required this.adm2,
    required this.country,
    required this.tz,
    required this.utcOffset,
    required this.isDst,
    required this.type,
    required this.rank,
    required this.fxLink,
  });

  String get displayName {
    final parts = <String>[];
    for (final part in [name, adm2, adm1, country]) {
      final normalized = part.trim();
      if (normalized.isNotEmpty && !parts.contains(normalized)) {
        parts.add(normalized);
      }
    }
    return parts.join(', ');
  }

  factory CitySearchResult.fromJson(Map<String, dynamic> json) {
    final latitude = double.tryParse(_readString(json, 'lat'));
    final longitude = double.tryParse(_readString(json, 'lon'));

    if (latitude == null || longitude == null) {
      throw const FormatException('Invalid city search coordinates');
    }

    return CitySearchResult(
      name: _readString(json, 'name'),
      id: _readString(json, 'id'),
      latitude: latitude,
      longitude: longitude,
      adm1: _readString(json, 'adm1'),
      adm2: _readString(json, 'adm2'),
      country: _readString(json, 'country'),
      tz: _readString(json, 'tz'),
      utcOffset: _readString(json, 'utcOffset'),
      isDst: _readString(json, 'isDst'),
      type: _readString(json, 'type'),
      rank: _readString(json, 'rank'),
      fxLink: _readString(json, 'fxLink'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    return json[key]?.toString() ?? '';
  }
}
