import 'package:flutter/material.dart';

class DirectionIndicator extends StatelessWidget {
  final double qiblahDirection;
  final double currentHeading;

  const DirectionIndicator({
    super.key,
    required this.qiblahDirection,
    required this.currentHeading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var difference = (qiblahDirection - currentHeading).abs();
    if (difference > 180) difference = 360 - difference;

    final isAligned = difference < 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAligned ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAligned ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAligned ? Icons.check_circle : Icons.rotate_right,
                color: isAligned ? Colors.green[700] : Colors.orange[700],
                size: 36,
              ),
              const SizedBox(width: 12),
              Text(
                isAligned ? 'Kıble Yönündesiniz! ✓' : 'Cihazınızı Döndürün',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isAligned ? Colors.green[900] : Colors.orange[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isAligned) ...[
            const SizedBox(height: 12),
            Text(
              'Kalan Açı: ${difference.toStringAsFixed(1)}°',
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
