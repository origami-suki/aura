import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidWavePainter extends CustomPainter {
  final Color color;
  final double progress; // 0.0 to 1.0 (e.g., humidity percentage)

  LiquidWavePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // The water level based on progress
    final waterLevel = height - (height * progress);

    path.moveTo(0, height);
    path.lineTo(0, waterLevel);

    // Draw a simple wave
    for (double x = 0; x <= width; x++) {
      double y = math.sin((x / width) * 2 * math.pi) * 8.0 + waterLevel;
      path.lineTo(x, y);
    }

    path.lineTo(width, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
