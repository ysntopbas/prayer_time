import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/features/compass/presentation/widgets/info_item.dart';

class QiblahInfoCard extends StatelessWidget {
  final Position currentPosition;
  final double qiblahDirection;
  final double currentHeading;

  const QiblahInfoCard({
    super.key,
    required this.currentPosition,
    required this.qiblahDirection,
    required this.currentHeading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.mosque, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Kabe Yönü',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoItem(
                icon: Icons.explore,
                label: 'Kıble Açısı',
                value: '${qiblahDirection.toStringAsFixed(1)}°',
                color: theme.colorScheme.primary,
              ),
              InfoItem(
                icon: Icons.navigation,
                label: 'Pusula',
                value: '${currentHeading.toStringAsFixed(1)}°',
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
