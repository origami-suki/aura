import 'package:flutter/material.dart';
import '../models/weather_hourly.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const HourlyForecastCard({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 8),
              Text(
                "Hourly forecast",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyData.length,
              separatorBuilder: (context, index) => const SizedBox(width: 24),
              itemBuilder: (context, index) {
                final forecast = hourlyData[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      forecast.time,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Icon(_getIconForCondition(forecast.icon)),
                    Text(
                      '${forecast.temp}°',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // A helper function to map string conditions to material icons
  IconData _getIconForCondition(String iconName) {
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
}
