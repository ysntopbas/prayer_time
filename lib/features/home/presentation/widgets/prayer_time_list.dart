import 'package:flutter/material.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final prayer = prayers[index];
        final isCurrentPrayer = prayer.name == nextPrayerName;
        final isPassed = _isPrayerPassed(index, prayers, nextPrayerName);

        return _buildPrayerItem(
          context,
          prayer: prayer,
          isCurrentPrayer: isCurrentPrayer,
          isPassed: isPassed,
          languageCode: languageCode,
        );
      },
    );
  }

  bool _isPrayerPassed(
    int index,
    List<_PrayerData> prayers,
    String nextPrayerName,
  ) {
    final currentIndex = prayers.indexWhere((p) => p.name == nextPrayerName);
    return index < currentIndex;
  }

  Widget _buildPrayerItem(
    BuildContext context, {
    required _PrayerData prayer,
    required bool isCurrentPrayer,
    required bool isPassed,
    required String languageCode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentPrayer
            ? Border.all(color: const Color(0xFF4CAF50), width: 1.5)
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
                    ? const Color(0xFF4CAF50)
                    : isPassed
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.transparent,
                border: Border.all(
                  color: isCurrentPrayer
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withValues(alpha: 0.3),
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
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                prayer.icon,
                color: isCurrentPrayer
                    ? const Color(0xFF4CAF50)
                    : Colors.white.withValues(alpha: 0.5),
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
                          ? Colors.white
                          : isPassed
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.8),
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
                        color: Color(0xFF4CAF50),
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
                        ? Colors.white
                        : isPassed
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.8),
                    fontSize: isCurrentPrayer ? 18 : 15,
                    fontWeight: isCurrentPrayer
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (isCurrentPrayer)
                  Text(
                    languageCode == 'tr' ? 'Başladı' : 'Started',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
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
