import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0) // Üst nokta
      ..lineTo(0, size.height) // Sol alt
      ..lineTo(size.width, size.height) // Sağ alt
      ..close();

    // Gölge
    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(path, paint);

    // Kenarlık
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
