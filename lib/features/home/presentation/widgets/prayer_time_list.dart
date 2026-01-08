import 'package:flutter/material.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class PrayerTimesList extends StatelessWidget {
  final Timings timings;
  final String nextPrayerName;

  const PrayerTimesList({
    super.key,
    required this.timings,
    required this.nextPrayerName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    final prayers = [
      _PrayerData(
        name: l10n.fajr,
        time: timings.fajr ?? '--:--',
        icon: Icons.nightlight_round,
      ),
      _PrayerData(
        name: l10n.sunrise,
        time: timings.sunrise ?? '--:--',
        icon: Icons.wb_twilight,
      ),
      _PrayerData(
        name: l10n.dhuhr,
        time: timings.dhuhr ?? '--:--',
        icon: Icons.wb_sunny,
      ),
      _PrayerData(
        name: l10n.asr,
        time: timings.asr ?? '--:--',
        icon: Icons.sunny_snowing,
      ),
      _PrayerData(
        name: l10n.maghrib,
        time: timings.maghrib ?? '--:--',
        icon: Icons.nights_stay,
      ),
      _PrayerData(
        name: l10n.isha,
        time: timings.isha ?? '--:--',
        icon: Icons.dark_mode,
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: prayers.map((prayer) {
          final isCurrentPrayer = prayer.name == nextPrayerName;
          final isPassed = _isPrayerPassed(
            prayer.time,
            prayers,
            nextPrayerName,
          );

          return _buildPrayerItem(
            context,
            prayer: prayer,
            isCurrentPrayer: isCurrentPrayer,
            isPassed: isPassed,
            languageCode: languageCode,
          );
        }).toList(),
      ),
    );
  }

  bool _isPrayerPassed(
    String time,
    List<_PrayerData> prayers,
    String nextPrayerName,
  ) {
    final currentIndex = prayers.indexWhere((p) => p.name == nextPrayerName);
    final thisIndex = prayers.indexWhere((p) => p.time == time);
    return thisIndex < currentIndex;
  }

  Widget _buildPrayerItem(
    BuildContext context, {
    required _PrayerData prayer,
    required bool isCurrentPrayer,
    required bool isPassed,
    required String languageCode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? AppTheme.activeCardBackground
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentPrayer
            ? Border.all(color: AppTheme.activeCardBorderColor, width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Status Indicator
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrentPrayer
                    ? AppTheme.activeIndicatorColor
                    : isPassed
                    ? AppTheme.passedIndicatorColor
                    : Colors.transparent,
                border: Border.all(
                  color: isCurrentPrayer
                      ? AppTheme.activeIndicatorColor
                      : AppTheme.normalIndicatorBorderColor,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isCurrentPrayer
                    ? AppTheme.chipActiveBackground
                    : AppTheme.chipBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                prayer.icon,
                color: isCurrentPrayer
                    ? AppTheme.activeIconColor
                    : AppTheme.normalIconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Prayer Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prayer.name,
                    style: TextStyle(
                      color: isCurrentPrayer
                          ? AppTheme.textWhite
                          : isPassed
                          ? AppTheme.textWhite40
                          : AppTheme.textWhite70,
                      fontSize: 15,
                      fontWeight: isCurrentPrayer
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (isCurrentPrayer)
                    Text(
                      languageCode == 'tr' ? 'ŞU AN' : 'NOW',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prayer.time.split('(').first.trim(),
                  style: TextStyle(
                    color: isCurrentPrayer
                        ? AppTheme.textWhite
                        : isPassed
                        ? AppTheme.textWhite40
                        : AppTheme.textWhite70,
                    fontSize: isCurrentPrayer ? 18 : 15,
                    fontWeight: isCurrentPrayer
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (isCurrentPrayer)
                  Text(
                    languageCode == 'tr' ? 'Başladı' : 'Started',
                    style: TextStyle(color: AppTheme.textWhite50, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerData {
  final String name;
  final String time;
  final IconData icon;

  _PrayerData({required this.name, required this.time, required this.icon});
}
