import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/features/home/presentation/cubit/home_cubit.dart';

class PrayerHeader extends StatelessWidget {
  final String subAdministrativeArea;
  final String cityName;

  const PrayerHeader({
    super.key,
    required this.subAdministrativeArea,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final languageCode = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('d MMMM yyyy', languageCode);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Location and Menu Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menu Button
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$cityName, Türkiye',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subAdministrativeArea,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu Icon
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Date Badge
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              String hijriDate = '';
              if (state is HomeLoaded) {
                // You can add Hijri date from API if available
                hijriDate = ''; // Will be populated from API
              }
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        languageCode == 'tr' ? 'BUGÜN' : 'TODAY',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (hijriDate.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• $hijriDate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Gregorian Date
          Text(
            dateFormat.format(now).toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
