import 'package:flutter/material.dart';

IconData getIconForCondition(String iconName) {
  switch (iconName.toLowerCase()) {
    case 'sunny':
      return Icons.wb_sunny;
    case 'cloudy':
      return Icons.cloud;
    case 'partly_cloudy':
      return Icons.wb_cloudy;
    case 'rain':
      return Icons.water_drop;
    default:
      return Icons.cloud;
  }
}
