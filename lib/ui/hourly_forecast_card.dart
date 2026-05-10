import 'package:flutter/material.dart';
import '../models/weather_hourly.dart';
import '../utils/weather_icons.dart' show getWeatherIcon;
import 'weather_effects.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const HourlyForecastCard({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    return WeatherSurfaceCard(
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: AuraSpacing.xs),
              Text(
                "Hourly forecast",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.md),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyData.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AuraSpacing.xl),
              itemBuilder: (context, index) {
                final forecast = hourlyData[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      forecast.time,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    getWeatherIcon(forecast.icon, size: 28),
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
}
