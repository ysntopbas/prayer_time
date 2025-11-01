import 'package:flutter/material.dart';
import 'package:prayer_time/features/compass/presentation/widgets/triangele_painter.dart';

class QiblahNeedle extends StatelessWidget {
  const QiblahNeedle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Üçgen (Kıble yönü)
        CustomPaint(
          size: const Size(40, 40),
          painter: TrianglePainter(color: Colors.red[700]!),
        ),
        // İbre Gövdesi
        Container(
          width: 10,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[700]!, Colors.red[400]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
