import 'package:flutter/material.dart';

class ConcentricWavesPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  ConcentricWavesPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, paint1);
    canvas.drawCircle(center, maxRadius * 0.7, paint2);
    canvas.drawCircle(center, maxRadius * 0.4, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
