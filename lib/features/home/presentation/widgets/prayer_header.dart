import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/features/home/presentation/cubit/home_cubit.dart';

class PrayerHeader extends StatelessWidget {
  final String subAdministrativeArea;
  final String cityName;
  final String countryName;

  const PrayerHeader({
    super.key,
    required this.subAdministrativeArea,
    required this.cityName,
    required this.countryName,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryGreen, // SABİT
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$cityName, $countryName',
                        style: TextStyle(
                          color: AppTheme.getTextColor(context), // DEĞİŞTİ
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subAdministrativeArea,
                        style: TextStyle(
                          color: AppTheme.getSecondaryTextColor(
                            context,
                          ), // DEĞİŞTİ
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.getChipBackground(context), // DEĞİŞTİ
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu,
                    color: AppTheme.getTextColor(context), // DEĞİŞTİ
                    size: 24,
                  ),
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
                hijriDate = '';
              }
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getCountdownBadgeBackground(
                    context,
                  ), // DEĞİŞTİ
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
                        color: AppTheme.badgeBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        languageCode == 'tr' ? 'BUGÜN' : 'TODAY',
                        style: const TextStyle(
                          color: AppTheme.badgeTextColor,
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
                          color: AppTheme.textWhite,
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
              color: AppTheme.getTertiaryTextColor(context), // DEĞİŞTİ
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
