import 'package:flutter/material.dart';
import 'dart:math' as math;

class SineWavePainter extends CustomPainter {
  final Color lineColor;
  final Color sunColor;
  final double progress; // 0.0 to 1.0 (sunrise to sunset)

  SineWavePainter({
    required this.lineColor,
    required this.sunColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Draw an arc representing the sun's path
    path.moveTo(0, height);
    path.quadraticBezierTo(width / 2, -height * 0.5, width, height);
    canvas.drawPath(path, linePaint);

    // Draw the sun at the progress point along the quadratic bezier curve
    // B(t) = (1-t)^2 * P0 + 2t(1-t) * P1 + t^2 * P2
    final t = progress.clamp(0.0, 1.0);
    final p0x = 0.0;
    final p0y = height;
    final p1x = width / 2;
    final p1y = -height * 0.5;
    final p2x = width;
    final p2y = height;

    final sunX = math.pow(1 - t, 2) * p0x + 2 * (1 - t) * t * p1x + math.pow(t, 2) * p2x;
    final sunY = math.pow(1 - t, 2) * p0y + 2 * (1 - t) * t * p1y + math.pow(t, 2) * p2y;

    final sunPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(sunX, sunY), 8.0, sunPaint);

    // Sun outline
    final sunOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(sunX, sunY), 8.0, sunOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
