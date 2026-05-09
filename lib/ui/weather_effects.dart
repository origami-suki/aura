import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/weather_now.dart';

abstract final class AuraSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double bottomSafe = 100;
}

abstract final class AuraRadii {
  static const double chip = 12;
  static const double icon = 16;
  static const double tile = 20;
  static const double card = 24;
  static const double sheet = 28;
  static const double pill = 40;
  static const double full = 999;
}

abstract final class AuraMotion {
  static const Duration crossFade = Duration(milliseconds: 300);
  static const Duration entrance = Duration(milliseconds: 520);
  static const Curve expressive = Curves.easeOutCubic;
}

class WeatherAtmosphere extends StatelessWidget {
  final WeatherNow? weather;
  final Widget child;

  const WeatherAtmosphere({
    super.key,
    required this.weather,
    required this.child,
  });

  static Color appBarColor(BuildContext context, WeatherNow? weather) {
    final palette = _WeatherPalette.resolve(
      weather: weather,
      colorScheme: Theme.of(context).colorScheme,
    );

    return Color.alphaBlend(
      palette.colors.first.withAlpha(184),
      Theme.of(context).colorScheme.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _WeatherPalette.resolve(
      weather: weather,
      colorScheme: Theme.of(context).colorScheme,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: AuraMotion.crossFade,
            curve: AuraMotion.expressive,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.colors,
                stops: const [0, 0.48, 1],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(palette.kind),
            duration: AuraMotion.entrance,
            curve: AuraMotion.expressive,
            tween: Tween(begin: 0, end: 1),
            builder: (context, opacity, _) {
              return CustomPaint(
                painter: _WeatherAtmospherePainter(
                  colorScheme: Theme.of(context).colorScheme,
                  palette: palette,
                  opacity: opacity,
                ),
              );
            },
          ),
        ),
        child,
      ],
    );
  }
}

class WeatherSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool emphasized;
  final Clip clipBehavior;

  const WeatherSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
    this.borderRadius = AuraRadii.card,
    this.emphasized = false,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(borderRadius);
    final background = emphasized
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainer;
    final glow = emphasized ? colorScheme.primary : colorScheme.shadow;

    return AnimatedContainer(
      duration: AuraMotion.crossFade,
      curve: AuraMotion.expressive,
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: background,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              colorScheme.surfaceTint.withAlpha(emphasized ? 28 : 18),
              background,
            ),
            background,
          ],
        ),
        borderRadius: radius,
        border: Border.all(
          color: (emphasized ? colorScheme.primary : colorScheme.outlineVariant)
              .withAlpha(emphasized ? 176 : 112),
          width: emphasized ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withAlpha(emphasized ? 38 : 18),
            blurRadius: emphasized ? 26 : 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String label;
  final IconData? icon;

  const SectionHeader(this.label, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.xs),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: AuraSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherPalette {
  final String kind;
  final List<Color> colors;

  const _WeatherPalette(this.kind, this.colors);

  static _WeatherPalette resolve({
    required WeatherNow? weather,
    required ColorScheme colorScheme,
  }) {
    final icon = weather?.icon ?? '';
    final condition = (weather?.condition ?? '').toLowerCase();
    final isDark = colorScheme.brightness == Brightness.dark;
    final isNight = icon.startsWith('15') || isDark;
    final isRain = icon.startsWith('3') || condition.contains('rain');
    final isSnow = icon.startsWith('4') || condition.contains('snow');
    final isFog =
        icon.startsWith('5') ||
        condition.contains('fog') ||
        condition.contains('haze');
    final isCloud =
        icon == '101' || icon == '104' || condition.contains('cloud');

    if (isNight) {
      return _WeatherPalette('night', [
        const Color(0xFF171D52),
        const Color(0xFF3F4DBA),
        Color.alphaBlend(
          const Color(0xFF5E68BD).withAlpha(166),
          colorScheme.surface,
        ),
      ]);
    }
    if (isRain) {
      return _WeatherPalette('rain', [
        const Color(0xFF7897B8),
        const Color(0xFFB8CBD8),
        Color.alphaBlend(
          const Color(0xFFE7EEF3).withAlpha(196),
          colorScheme.surface,
        ),
      ]);
    }
    if (isSnow || isFog) {
      return _WeatherPalette('mist', [
        const Color(0xFFC8D8E4),
        const Color(0xFFE1E9EE),
        Color.alphaBlend(
          const Color(0xFFF7FAFC).withAlpha(220),
          colorScheme.surface,
        ),
      ]);
    }
    if (isCloud) {
      return _WeatherPalette('cloud', [
        const Color(0xFF9DB7D1),
        const Color(0xFFD6E0E8),
        Color.alphaBlend(
          const Color(0xFFF4F0E8).withAlpha(210),
          colorScheme.surface,
        ),
      ]);
    }

    return _WeatherPalette('clear-day', [
      const Color(0xFFFFBA5E),
      const Color(0xFFFFC67E),
      Color.alphaBlend(
        const Color(0xFFFFF0E2).withAlpha(232),
        colorScheme.surface,
      ),
    ]);
  }
}

class _WeatherAtmospherePainter extends CustomPainter {
  final ColorScheme colorScheme;
  final _WeatherPalette palette;
  final double opacity;

  _WeatherAtmospherePainter({
    required this.colorScheme,
    required this.palette,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final accent = colorScheme.surfaceTint.withAlpha((24 * opacity).round());
    final light = Colors.white.withAlpha((46 * opacity).round());
    final shade = colorScheme.primary.withAlpha((18 * opacity).round());

    paint.shader = RadialGradient(colors: [light, Colors.transparent])
        .createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.18, size.height * 0.10),
            radius: size.width * 0.46,
          ),
        );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.10),
      size.width * 0.46,
      paint,
    );

    paint.shader = RadialGradient(colors: [accent, Colors.transparent])
        .createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.92, size.height * 0.28),
            radius: size.width * 0.54,
          ),
        );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.28),
      size.width * 0.54,
      paint,
    );

    paint
      ..shader = null
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = shade;

    for (var index = 0; index < 9; index++) {
      final y = size.height * (0.18 + index * 0.085);
      final path = Path()..moveTo(-size.width * 0.05, y);
      for (var step = 0; step <= 5; step++) {
        final x = size.width * (step / 5);
        final nextX = size.width * ((step + 0.5) / 5);
        final wave = math.sin(step + index * 0.8) * AuraSpacing.xs;
        path.quadraticBezierTo(x, y + wave, nextX, y - wave);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherAtmospherePainter oldDelegate) {
    return oldDelegate.palette.kind != palette.kind ||
        oldDelegate.opacity != opacity ||
        oldDelegate.colorScheme != colorScheme;
  }
}
