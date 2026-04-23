import 'package:flutter/material.dart';

class BlobPainter extends CustomPainter {
  final Color color;

  BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Drawing an irregular blob shape
    path.moveTo(width * 0.5, height * 0.1);
    path.cubicTo(width * 0.9, height * 0.05, width * 1.1, height * 0.6, width * 0.8, height * 0.8);
    path.cubicTo(width * 0.5, height * 1.0, width * 0.1, height * 0.9, width * 0.1, height * 0.5);
    path.cubicTo(width * 0.1, height * 0.1, width * 0.3, height * 0.15, width * 0.5, height * 0.1);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlobShapeCard extends StatelessWidget {
  final Widget child;

  const BlobShapeCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlobPainter(color: Theme.of(context).colorScheme.tertiaryContainer),
      child: child,
    );
  }
}
