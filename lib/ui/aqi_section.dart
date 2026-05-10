import 'package:flutter/material.dart';
import '../models/indices.dart';
import 'weather_effects.dart';

class AqiSection extends StatelessWidget {
  final AqiNow? aqiNow;

  const AqiSection({super.key, this.aqiNow});

  @override
  Widget build(BuildContext context) {
    if (aqiNow == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("Air Quality"),
        const SizedBox(height: AuraSpacing.md),
        _buildAqiCard(context, aqiNow!),
        const SizedBox(height: AuraSpacing.xl),
      ],
    );
  }

  Widget _buildAqiCard(BuildContext context, AqiNow aqi) {
    Color getAqiColor(int aqiValue) {
      final colorScheme = Theme.of(context).colorScheme;
      if (aqiValue <= 50) return colorScheme.tertiary;
      if (aqiValue <= 100) return colorScheme.primary;
      if (aqiValue <= 150) return colorScheme.secondary;
      if (aqiValue <= 200) return colorScheme.error;
      return colorScheme.inversePrimary;
    }

    return WeatherSurfaceCard(
      width: double.infinity,
      padding: const EdgeInsets.all(AuraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, size: 20),
              const SizedBox(width: AuraSpacing.xs),
              Text(
                "AQI Now",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${aqi.aqi}",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AuraSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuraSpacing.sm,
                  vertical: AuraSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: getAqiColor(aqi.aqi).withAlpha(51),
                  borderRadius: BorderRadius.circular(AuraRadii.chip),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: getAqiColor(aqi.aqi),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AuraSpacing.xs),
                    Text(
                      aqi.category,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: getAqiColor(aqi.aqi),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
