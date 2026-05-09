import 'package:flutter/material.dart';
import '../models/weather_daily.dart';
import '../utils/weather_icons.dart' show getWeatherIcon;
import 'weather_effects.dart';

class DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> dailyData;

  const DailyForecastCard({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("10-Day forecast"),
        const SizedBox(height: AuraSpacing.md),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dailyData.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AuraSpacing.sm),
            itemBuilder: (context, index) {
              final forecast = dailyData[index];
              final isToday = index == 0; // Assuming first item is today

              return WeatherSurfaceCard(
                width: 80,
                borderRadius: AuraRadii.pill,
                emphasized: isToday,
                padding: const EdgeInsets.symmetric(
                  vertical: AuraSpacing.lg,
                  horizontal: AuraSpacing.xs,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      forecast.dayOfWeek,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    getWeatherIcon(forecast.icon, size: 32),
                    if (forecast.pop > 0)
                      Text(
                        '${forecast.pop}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Column(
                      children: [
                        Text(
                          '${forecast.tempMax}°',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${forecast.tempMin}°',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
