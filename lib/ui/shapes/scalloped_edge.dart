import 'package:flutter/material.dart';

class ScallopedEdgePainter extends CustomPainter {
  final Color color;

  ScallopedEdgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Draw a rectangle with a scalloped top edge
    path.moveTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, height * 0.2);

    // Create scallops along the top
    int scallopCount = 5;
    double scallopWidth = width / scallopCount;
    for (int i = scallopCount - 1; i >= 0; i--) {
      path.quadraticBezierTo(
        scallopWidth * i + scallopWidth / 2,
        0,
        scallopWidth * i,
        height * 0.2
      );
    }

    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
