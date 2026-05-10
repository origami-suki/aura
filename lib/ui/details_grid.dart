import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/weather_now.dart';
import 'shapes/blob_shape.dart';
import 'shapes/sine_wave.dart';
import 'shapes/scalloped_edge.dart';
import 'shapes/concentric_waves.dart';
import 'shapes/gauge_chart.dart';
import 'shapes/liquid_wave.dart';
import 'weather_effects.dart';

import '../models/weather_daily.dart';

class DetailsStaggeredGrid extends StatelessWidget {
  final WeatherNow weather;
  final DailyForecast todayForecast;

  const DetailsStaggeredGrid({
    super.key,
    required this.weather,
    required this.todayForecast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("Current details"),
        const SizedBox(height: AuraSpacing.md),
        // Simplistic staggered grid approach using rows and columns for flutter
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildPrecipitationCard(context),
                  const SizedBox(height: AuraSpacing.md),
                  _buildSunriseSunsetCard(context, todayForecast),
                  const SizedBox(height: AuraSpacing.md),
                  _buildVisibilityCard(context),
                  const SizedBox(height: AuraSpacing.md),
                  _buildHumidityCard(context),
                ],
              ),
            ),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                children: [
                  _buildWindCard(context),
                  const SizedBox(height: AuraSpacing.md),
                  _buildUvIndexCard(context, todayForecast),
                  const SizedBox(height: AuraSpacing.md),
                  _buildPressureCard(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardBase(
    BuildContext context, {
    required Widget child,
    double? height,
  }) {
    return WeatherSurfaceCard(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildDetailHeader(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: AuraSpacing.xl,
          height: AuraSpacing.xl,
          decoration: BoxDecoration(
            color: accent.withAlpha(38),
            borderRadius: BorderRadius.circular(AuraRadii.chip),
          ),
          child: Icon(icon, size: 16, color: accent),
        ),
        const SizedBox(width: AuraSpacing.xs),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadlineValue(
    BuildContext context,
    String value, {
    TextAlign textAlign = TextAlign.start,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        value,
        maxLines: 1,
        textAlign: textAlign,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildScaleTrack(
    BuildContext context, {
    required double progress,
    required Color color,
    List<Color>? stops,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AuraRadii.full),
      child: SizedBox(
        height: AuraSpacing.xxs,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: (stops ?? [colorScheme.surfaceContainerHighest])
                  .map(
                    (stop) => Expanded(
                      child: ColoredBox(
                        color: stop.withAlpha(stops == null ? 255 : 128),
                      ),
                    ),
                  )
                  .toList(),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: safeProgress,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaption(
    BuildContext context,
    String text, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPrecipitationCard(BuildContext context) {
    final precip = _formatPrecipitation(todayForecast.precip);
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final progress = (todayForecast.precip / 25).clamp(0.0, 1.0).toDouble();

    return _buildCardBase(
      context,
      height: 132,
      child: Stack(
        children: [
          Positioned.fill(
            top: AuraSpacing.xxl,
            child: CustomPaint(
              painter: LiquidWavePainter(
                color: colorScheme.primaryContainer.withAlpha(126),
                progress: progress,
              ),
            ),
          ),
          Positioned(
            right: -AuraSpacing.lg,
            bottom: -AuraSpacing.xl,
            width: AuraSpacing.xxl * 3,
            height: AuraSpacing.xxl * 3,
            child: CustomPaint(
              painter: ConcentricWavesPainter(
                color1: colorScheme.primaryContainer.withAlpha(96),
                color2: colorScheme.surfaceContainerHighest.withAlpha(128),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(
                  context,
                  icon: Icons.water_drop_outlined,
                  label: "Precipitation",
                  accent: accent,
                ),
                const Spacer(),
                _buildHeadlineValue(context, "$precip mm"),
                const SizedBox(height: AuraSpacing.xxs),
                _buildScaleTrack(context, progress: progress, color: accent),
                const SizedBox(height: AuraSpacing.xxs),
                Text(
                  "in last 24h",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrecipitation(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _formatVisibility(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  Widget _buildWindCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _getWindColor(context, weather.windSpeed);
    final progress = (weather.windSpeed / 62).clamp(0.0, 1.0).toDouble();

    return _buildCardBase(
      context,
      height: 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BlobPainter(
                color: colorScheme.secondaryContainer.withAlpha(138),
              ),
            ),
          ),
          Positioned(
            right: AuraSpacing.md,
            top: AuraSpacing.xxl,
            child: Transform.rotate(
              angle: _windDirectionTurns(weather.windDir) * math.pi * 2,
              child: Icon(
                Icons.navigation,
                size: AuraSpacing.xxl,
                color: accent.withAlpha(176),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(
                  context,
                  icon: Icons.air,
                  label: "Wind",
                  accent: accent,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${weather.windSpeed}",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "km/h",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AuraSpacing.xs),
                _buildScaleTrack(
                  context,
                  progress: progress,
                  color: accent,
                  stops: [
                    colorScheme.tertiary,
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.error,
                  ],
                ),
                const SizedBox(height: AuraSpacing.xs),
                _buildCaption(context, "From ${weather.windDir}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getWindColor(BuildContext context, int speed) {
    final colorScheme = Theme.of(context).colorScheme;
    if (speed < 12) return colorScheme.tertiary;
    if (speed < 29) return colorScheme.primary;
    if (speed < 50) return colorScheme.secondary;
    return colorScheme.error;
  }

  double _windDirectionTurns(String direction) {
    final value = direction.toLowerCase();
    if (value.contains('north') && value.contains('east')) return 0.125;
    if (value.contains('east') && value.contains('south')) return 0.375;
    if (value.contains('south') && value.contains('west')) return 0.625;
    if (value.contains('west') && value.contains('north')) return 0.875;
    if (value.contains('east')) return 0.25;
    if (value.contains('south')) return 0.5;
    if (value.contains('west')) return 0.75;
    return 0;
  }

  Widget _buildSunriseSunsetCard(BuildContext context, DailyForecast today) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;

    return _buildCardBase(
      context,
      height: 160,
      child: Stack(
        children: [
          Positioned(
            right: -AuraSpacing.xxl,
            top: -AuraSpacing.xxl,
            width: AuraSpacing.xxl * 3.5,
            height: AuraSpacing.xxl * 3.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.tertiaryContainer.withAlpha(166),
                    colorScheme.tertiaryContainer.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(
                  context,
                  icon: Icons.wb_twilight,
                  label: "Sunrise & Sunset",
                  accent: accent,
                ),
                const Spacer(),
                SizedBox(
                  height: AuraSpacing.xxl * 2,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: SineWavePainter(
                      lineColor: colorScheme.outlineVariant,
                      sunColor: colorScheme.tertiary,
                      progress: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: AuraSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _buildSunTimeLabel(
                        context,
                        "Sunrise: ${today.sunrise}",
                        Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(width: AuraSpacing.xs),
                    Expanded(
                      child: _buildSunTimeLabel(
                        context,
                        "Sunset: ${today.sunset}",
                        Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunTimeLabel(
    BuildContext context,
    String label,
    Alignment alignment,
  ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        label,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  Widget _buildUvIndexCard(BuildContext context, DailyForecast today) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _getUvColor(context, today.uvIndex);
    final progress = (today.uvIndex / 11).clamp(0.0, 1.0).toDouble();

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
              painter: ScallopedEdgePainter(
                color: colorScheme.errorContainer.withAlpha(132),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  label: "UV Index",
                  accent: accent,
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildHeadlineValue(context, "${today.uvIndex}"),
                    ),
                    const SizedBox(width: AuraSpacing.sm),
                    Flexible(
                      child: Text(
                        _getUvDesc(today.uvIndex),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AuraSpacing.xs),
                _buildScaleTrack(
                  context,
                  progress: progress,
                  color: accent,
                  stops: [
                    colorScheme.tertiary,
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.error,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUvDesc(int uv) {
    if (uv <= 2) return "Low";
    if (uv <= 5) return "Moderate";
    if (uv <= 7) return "High";
    if (uv <= 10) return "Very High";
    return "Extreme";
  }

  Color _getUvColor(BuildContext context, int uv) {
    final colorScheme = Theme.of(context).colorScheme;
    if (uv <= 2) return colorScheme.tertiary;
    if (uv <= 5) return colorScheme.primary;
    if (uv <= 7) return colorScheme.secondary;
    return colorScheme.error;
  }

  Widget _buildVisibilityCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _getVisibilityColor(context, weather.visibility);
    final progress = (weather.visibility / 20).clamp(0.0, 1.0).toDouble();

    return _buildCardBase(
      context,
      height: 132,
      child: Stack(
        children: [
          Positioned(
            right: -AuraSpacing.lg,
            top: -AuraSpacing.lg,
            width: AuraSpacing.xxl * 3,
            height: AuraSpacing.xxl * 3,
            child: CustomPaint(
              painter: ConcentricWavesPainter(
                color1: colorScheme.surfaceContainerHigh.withAlpha(190),
                color2: colorScheme.tertiaryContainer.withAlpha(150),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(
                  context,
                  icon: Icons.visibility_outlined,
                  label: "Visibility",
                  accent: accent,
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildHeadlineValue(
                        context,
                        "${_formatVisibility(weather.visibility)} km",
                      ),
                    ),
                    const SizedBox(width: AuraSpacing.sm),
                    Flexible(
                      child: _buildCaption(
                        context,
                        _getVisibilityDesc(weather.visibility),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AuraSpacing.xs),
                _buildScaleTrack(context, progress: progress, color: accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getVisibilityDesc(double visibility) {
    if (visibility >= 15) return "Excellent";
    if (visibility >= 8) return "Clear";
    if (visibility >= 3) return "Hazy";
    return "Poor";
  }

  Color _getVisibilityColor(BuildContext context, double visibility) {
    final colorScheme = Theme.of(context).colorScheme;
    if (visibility >= 15) return colorScheme.tertiary;
    if (visibility >= 8) return colorScheme.primary;
    if (visibility >= 3) return colorScheme.secondary;
    return colorScheme.error;
  }

  Widget _buildPressureCard(BuildContext context) {
    // Normal pressure range ~980 to 1040 hPa
    final progress = ((weather.pressure - 980) / 60).clamp(0.0, 1.0).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _getPressureColor(context, weather.pressure);

    return _buildCardBase(
      context,
      height: 140,
      child: Stack(
        children: [
          Positioned(
            right: -AuraSpacing.lg,
            bottom: -AuraSpacing.md,
            width: AuraSpacing.xxl * 3,
            height: AuraSpacing.xxl * 2,
            child: CustomPaint(
              painter: GaugePainter(
                trackColor: colorScheme.surfaceContainerHigh.withAlpha(160),
                progressColor: accent.withAlpha(112),
                value: progress,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(
                  context,
                  icon: Icons.speed,
                  label: "Pressure",
                  accent: accent,
                ),
                const Spacer(),
                _buildHeadlineValue(context, "${weather.pressure} hPa"),
                const SizedBox(height: AuraSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _buildScaleTrack(
                        context,
                        progress: progress,
                        color: accent,
                        stops: [
                          colorScheme.secondary,
                          colorScheme.primary,
                          colorScheme.tertiary,
                        ],
                      ),
                    ),
                    const SizedBox(width: AuraSpacing.sm),
                    Flexible(
                      child: _buildCaption(
                        context,
                        _getPressureDesc(weather.pressure),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPressureDesc(int pressure) {
    if (pressure < 1000) return "Low";
    if (pressure > 1025) return "High";
    return "Steady";
  }

  Color _getPressureColor(BuildContext context, int pressure) {
    final colorScheme = Theme.of(context).colorScheme;
    if (pressure < 1000) return colorScheme.secondary;
    if (pressure > 1025) return colorScheme.tertiary;
    return colorScheme.primary;
  }

  Widget _buildHumidityCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _getHumidityColor(context, weather.humidity);
    final progress = (weather.humidity / 100).clamp(0.0, 1.0).toDouble();

    return _buildCardBase(
      context,
      height: 140,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LiquidWavePainter(
                color: colorScheme.primaryContainer.withAlpha(142),
                progress: progress,
              ),
            ),
          ),
          Positioned(
            right: AuraSpacing.sm,
            top: AuraSpacing.xxl,
            child: Icon(
              Icons.opacity,
              size: AuraSpacing.xl + AuraSpacing.lg,
              color: accent.withAlpha(112),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(
                  context,
                  icon: Icons.water_drop,
                  label: "Humidity",
                  accent: accent,
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildHeadlineValue(
                        context,
                        "${weather.humidity}%",
                      ),
                    ),
                    const SizedBox(width: AuraSpacing.sm),
                    Flexible(
                      child: _buildCaption(
                        context,
                        _getHumidityDesc(weather.humidity),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AuraSpacing.xs),
                _buildScaleTrack(context, progress: progress, color: accent),
                const SizedBox(height: AuraSpacing.xs),
                _buildCaption(context, "Dew point ${weather.dewPoint}°"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHumidityDesc(int humidity) {
    if (humidity < 35) return "Dry";
    if (humidity > 70) return "Humid";
    return "Comfort";
  }

  Color _getHumidityColor(BuildContext context, int humidity) {
    final colorScheme = Theme.of(context).colorScheme;
    if (humidity < 35) return colorScheme.secondary;
    if (humidity > 70) return colorScheme.primary;
    return colorScheme.tertiary;
  }
}
