import 'package:flutter/material.dart';
import '../models/weather_now.dart';
import 'shapes/blob_shape.dart';
import 'shapes/sine_wave.dart';
import 'shapes/scalloped_edge.dart';
import 'shapes/concentric_waves.dart';
import 'shapes/gauge_chart.dart';
import 'shapes/liquid_wave.dart';

class DetailsStaggeredGrid extends StatelessWidget {
  final WeatherNow weather;

  const DetailsStaggeredGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Current details",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        // Simplistic staggered grid approach using rows and columns for flutter
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildPrecipitationCard(context),
                  const SizedBox(height: 16),
                  _buildSunriseSunsetCard(context),
                  const SizedBox(height: 16),
                  _buildVisibilityCard(context),
                  const SizedBox(height: 16),
                  _buildHumidityCard(context),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildWindCard(context),
                  const SizedBox(height: 16),
                  _buildUvIndexCard(context),
                  const SizedBox(height: 16),
                  _buildPressureCard(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardBase(BuildContext context, {required Widget child, double? height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildPrecipitationCard(BuildContext context) {
    return _buildCardBase(
      context,
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text("Precipitation", style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const Spacer(),
            Text(
              "${weather.precip} mm",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              "in last 24h",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindCard(BuildContext context) {
    return _buildCardBase(
      context,
      height: 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BlobPainter(color: Theme.of(context).colorScheme.secondaryContainer),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.air, size: 16, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text("Wind", style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "${weather.windSpeed}",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text("km/h", style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text("From ${weather.windDir}", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunsetCard(BuildContext context) {
    return _buildCardBase(
      context,
      height: 160,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_twilight, size: 16, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 4),
                Text("Sunrise & Sunset", style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: CustomPaint(
                painter: SineWavePainter(
                  lineColor: Theme.of(context).colorScheme.outlineVariant,
                  sunColor: Colors.amber,
                  progress: 0.6, // Mock progress based on current time
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sunrise: ${weather.sunrise}", style: Theme.of(context).textTheme.labelSmall),
                Text("Sunset: ${weather.sunset}", style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUvIndexCard(BuildContext context) {
    return _buildCardBase(
      context,
      height: 140,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: CustomPaint(
              painter: ScallopedEdgePainter(color: Theme.of(context).colorScheme.errorContainer),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined, size: 16, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 4),
                    Text("UV Index", style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                const Spacer(),
                Text(
                  "${weather.uvIndex}",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(weather.uvDesc, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityCard(BuildContext context) {
    return _buildCardBase(
      context,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: ConcentricWavesPainter(
                color1: Theme.of(context).colorScheme.surfaceContainerHigh,
                color2: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text("Visibility", style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                const Spacer(),
                Text(
                  "${weather.visibility} km",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPressureCard(BuildContext context) {
    // Normal pressure range ~980 to 1040 hPa
    double progress = ((weather.pressure - 980) / 60).clamp(0.0, 1.0);

    return _buildCardBase(
      context,
      height: 140,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, size: 16),
                const SizedBox(width: 4),
                Text("Pressure", style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 100,
                height: 50,
                child: CustomPaint(
                  painter: GaugePainter(
                    trackColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                    progressColor: Theme.of(context).colorScheme.primary,
                    value: progress,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "${weather.pressure} hPa",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityCard(BuildContext context) {
    return _buildCardBase(
      context,
      height: 140,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LiquidWavePainter(
                color: Theme.of(context).colorScheme.primaryContainer,
                progress: weather.humidity / 100.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text("Humidity", style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                const Spacer(),
                Text(
                  "${weather.humidity}%",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Dew point ${weather.dewPoint}°",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
