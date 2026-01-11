import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class WeeklyPrayerDayCard extends StatelessWidget {
  final PrayerTimeModel prayerTime;
  final bool isToday;
  final bool isFriday;
  final String languageCode;

  const WeeklyPrayerDayCard({
    super.key,
    required this.prayerTime,
    this.isToday = false,
    this.isFriday = false,
    this.languageCode = 'tr',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timings = prayerTime.timings;
    final gregorian = prayerTime.date?.gregorian;
    final hijri = prayerTime.date?.hijri;

    // Parse date
    int? dayNumber;
    String weekdayName = '';
    if (gregorian?.date != null) {
      try {
        final parts = gregorian!.date!.split('-');
        if (parts.length == 3) {
          dayNumber = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, dayNumber);
          weekdayName = DateFormat('EEEE', languageCode).format(date);
        }
      } catch (_) {}
    }

    // Hijri date
    final hijriDay = hijri?.hijriday ?? '';
    final hijriMonth = hijri?.hijrimonth?.hijrien ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.activeCardBackgroundDark : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppTheme.activeCardBorderColor
              : AppTheme.cardBorderColor,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row - Day info
            Row(
              children: [
                // Day Number Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primaryGreen : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday
                        ? null
                        : Border.all(
                            color: AppTheme.normalIndicatorBorderColor,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      '${dayNumber ?? ''}',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Day Name and Hijri Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            weekdayName,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.badgeBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                languageCode == 'tr' ? 'BUGÜN' : 'TODAY',
                                style: const TextStyle(
                                  color: AppTheme.badgeTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (isFriday && !isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.badgeBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                languageCode == 'tr' ? 'CUMA' : 'FRIDAY',
                                style: const TextStyle(
                                  color: AppTheme.badgeTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '$hijriDay $hijriMonth',
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mosque Icon for Today/Friday
                if (isToday || isFriday)
                  const Icon(
                    Icons.mosque,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Prayer Times Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPrayerTimeChip(
                  context, // context eklendi
                  l10n.fajr,
                  _formatTime(timings?.fajr),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  context, // context eklendi
                  l10n.sunrise,
                  _formatTime(timings?.sunrise),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  context, // context eklendi
                  l10n.dhuhr,
                  _formatTime(timings?.dhuhr),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  context, // context eklendi
                  l10n.asr,
                  _formatTime(timings?.asr),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  context, // context eklendi
                  l10n.maghrib,
                  _formatTime(timings?.maghrib),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  context, // context eklendi
                  l10n.isha,
                  _formatTime(timings?.isha),
                  isToday,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '--:--';
    return time.split(' ').first.split('(').first.trim();
  }

  Widget _buildPrayerTimeChip(
    BuildContext context, // context parametresi eklendi
    String label,
    String time,
    bool isHighlighted,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppTheme.chipActiveBackground
                : AppTheme.chipBackground,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHighlighted
                  ? AppTheme.chipActiveBorderColor
                  : AppTheme.chipBorderColor,
            ),
          ),
          child: Column(
            children: [
              Text(
                label.length > 5 ? label.substring(0, 5) : label,
                style: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  color: isHighlighted
                      ? AppTheme.primaryGreen
                      : AppTheme.getTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
