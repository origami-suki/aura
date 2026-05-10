import 'package:flutter/material.dart';

Widget getWeatherIcon(String iconCode, {double size = 24}) {
  final asset = _iconAsset(iconCode);
  return Image.asset(asset, width: size, height: size, gaplessPlayback: true);
}

String _iconAsset(String iconCode) {
  const base = 'assets/icons';
  switch (iconCode) {
    // Daytime
    case '100':
      return '$base/weather_clear_day_pixel.png';
    case '101':
      return '$base/weather_cloudy_pixel.png';
    case '102':
    case '103':
      return '$base/weather_partly_cloudy_day_pixel.png';
    case '104':
      return '$base/weather_cloudy_pixel.png';
    // Nighttime
    case '150':
      return '$base/weather_clear_night_pixel.png';
    case '151':
      return '$base/weather_cloudy_pixel.png';
    case '152':
    case '153':
      return '$base/weather_partly_cloudy_night_pixel.png';
    // Rain
    case '300':
    case '301':
    case '305':
    case '306':
    case '307':
    case '308':
    case '309':
    case '310':
    case '311':
    case '312':
    case '313':
    case '314':
    case '315':
    case '316':
    case '317':
    case '318':
    case '399':
      return '$base/weather_rain_pixel.png';
    // Thunderstorm
    case '302':
    case '303':
      return '$base/weather_thunderstorm_pixel.png';
    // Hail
    case '304':
      return '$base/weather_hail_pixel.png';
    // Snow
    case '400':
    case '401':
    case '402':
    case '403':
    case '404':
    case '405':
    case '406':
    case '407':
    case '408':
    case '409':
    case '410':
    case '499':
      return '$base/weather_snow_pixel.png';
    // Sleet
    case '456':
    case '457':
      return '$base/weather_sleet_pixel.png';
    // Fog / Mist
    case '500':
    case '501':
      return '$base/weather_fog_pixel.png';
    // Haze / Dust / Sand
    case '502':
    case '503':
    case '504':
    case '507':
    case '508':
    case '509':
    case '510':
    case '511':
    case '512':
    case '513':
    case '514':
    case '515':
      return '$base/weather_haze_pixel.png';
    // Extreme temperatures
    case '900':
      return '$base/weather_clear_day_pixel.png';
    case '901':
      return '$base/weather_snow_pixel.png';
    default:
      return '$base/weather_cloudy_pixel.png';
  }
}
