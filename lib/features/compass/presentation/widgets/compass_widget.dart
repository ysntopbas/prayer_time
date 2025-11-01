import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prayer_time/features/compass/presentation/widgets/compass_base.dart';
import 'package:prayer_time/features/compass/presentation/widgets/qiblah_needle.dart';

class CompassWidget extends StatelessWidget {
  final double qiblahDirection;
  final double currentHeading;

  const CompassWidget({
    super.key,
    required this.qiblahDirection,
    required this.currentHeading,
  });

  @override
  Widget build(BuildContext context) {
    // Kıble ibresi için açı hesaplama
    final needleAngle = (qiblahDirection - currentHeading) * (pi / 180);

    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pusula Tabanı
          CompassBase(currentHeading: currentHeading),

          // Kıble İbresi
          Transform.rotate(angle: needleAngle, child: const QiblahNeedle()),

          // Merkez Nokta
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.red[700]!, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
