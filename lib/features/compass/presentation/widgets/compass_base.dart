import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prayer_time/features/compass/presentation/screens/compass_page.dart';

class CompassBase extends StatelessWidget {
  final double currentHeading;

  const CompassBase({super.key, required this.currentHeading});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -currentHeading * (pi / 180),
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Colors.white, Colors.grey[100]!, Colors.grey[200]!],
          ),
        ),
        child: Stack(
          children: [
            // Yön İşaretleri
            buildDirectionMarker('N', 0, Colors.red[700]!),
            buildDirectionMarker('E', 90, Colors.blue[600]!),
            buildDirectionMarker('S', 180, Colors.grey[700]!),
            buildDirectionMarker('W', 270, Colors.orange[600]!),

            // Derece İşaretleri
            for (int i = 0; i < 360; i += 30)
              if (i % 90 != 0) buildDegreeMarker(i),
          ],
        ),
      ),
    );
  }
}
