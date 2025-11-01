import 'package:flutter/material.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/widgets/prayer_time_item.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class MonthlyPrayerDayCard extends StatelessWidget {
  final PrayerTimeModel prayerTime;
  final String cityName;

  const MonthlyPrayerDayCard({
    super.key,
    required this.prayerTime,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final gregorian = prayerTime.date?.gregorian;
    final hijri = prayerTime.date?.hijri;
    final timings = prayerTime.timings;
    final l10nL = AppLocalizations.of(context)!;
    final appTheme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appTheme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Day Number
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      gregorian?.day ?? '',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: appTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Date Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gregorian?.day ?? ''} ${_getLocalizedMonth(gregorian?.month?.en, l10nL)} ${gregorian?.year ?? ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getLocalizedWeekday(gregorian?.weekday?.en, l10nL),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        '${hijri?.hijriday ?? ''} ${hijri?.hijrimonth?.hijrien ?? ''} ${hijri?.hijriyear ?? ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // City Name
                Text(
                  cityName,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Prayer Times Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PrayerTimeItem(
                        title: l10nL.fajr,
                        time: timings?.fajr ?? '',
                        icon: Icons.nightlight_round,
                        color: const Color(0xFF5C6BC0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrayerTimeItem(
                        title: l10nL.sunrise,
                        time: timings?.sunrise ?? '',
                        icon: Icons.wb_sunny,
                        color: const Color(0xFFFFA726),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PrayerTimeItem(
                        title: l10nL.dhuhr,
                        time: timings?.dhuhr ?? '',
                        icon: Icons.wb_sunny_outlined,
                        color: const Color(0xFFFF7043),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrayerTimeItem(
                        title: l10nL.asr,
                        time: timings?.asr ?? '',
                        icon: Icons.wb_twilight,
                        color: const Color(0xFFFFB74D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PrayerTimeItem(
                        title: l10nL.maghrib,
                        time: timings?.maghrib ?? '',
                        icon: Icons.wb_sunny,
                        color: const Color(0xFFEF5350),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrayerTimeItem(
                        title: l10nL.isha,
                        time: timings?.isha ?? '',
                        icon: Icons.nightlight,
                        color: const Color(0xFF7E57C2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _getLocalizedMonth(String? monthEn, AppLocalizations l10n) {
  if (monthEn == null) return '';

  switch (monthEn.toLowerCase()) {
    case 'january':
      return l10n.january;
    case 'february':
      return l10n.february;
    case 'march':
      return l10n.march;
    case 'april':
      return l10n.april;
    case 'may':
      return l10n.may;
    case 'june':
      return l10n.june;
    case 'july':
      return l10n.july;
    case 'august':
      return l10n.august;
    case 'september':
      return l10n.september;
    case 'october':
      return l10n.october;
    case 'november':
      return l10n.november;
    case 'december':
      return l10n.december;
    default:
      return monthEn;
  }
}

String _getLocalizedWeekday(String? weekdayEn, AppLocalizations l10n) {
  if (weekdayEn == null) return '';

  switch (weekdayEn.toLowerCase()) {
    case 'monday':
      return l10n.monday;
    case 'tuesday':
      return l10n.tuesday;
    case 'wednesday':
      return l10n.wednesday;
    case 'thursday':
      return l10n.thursday;
    case 'friday':
      return l10n.friday;
    case 'saturday':
      return l10n.saturday;
    case 'sunday':
      return l10n.sunday;
    default:
      return weekdayEn;
  }
}
