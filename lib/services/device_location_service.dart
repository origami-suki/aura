import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

typedef DeviceCoordinates = ({double longitude, double latitude});

/// Wraps geolocator to provide one-shot current-position lookups.
class DeviceLocationService {
  DeviceLocationService({
    TargetPlatform Function()? targetPlatform,
    bool isWeb = kIsWeb,
  }) : _targetPlatform = targetPlatform ?? (() => defaultTargetPlatform),
       _isWeb = isWeb;

  final TargetPlatform Function() _targetPlatform;
  final bool _isWeb;

  bool get _supportsAndroid => !_isWeb && _targetPlatform() == TargetPlatform.android;

  /// Returns current Android coordinates, or null on unsupported/failure paths.
  Future<DeviceCoordinates?> getCurrentPosition() async {
    if (!_supportsAndroid) return null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final isGranted = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (!isGranted) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return (longitude: position.longitude, latitude: position.latitude);
    } catch (_) {
      return null;
    }
  }
}
