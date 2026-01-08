import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class MonthlyPrayerDayCard extends StatelessWidget {
  final PrayerTimeModel prayerTime;
  final bool isToday;
  final bool isFriday;
  final String languageCode;

  const MonthlyPrayerDayCard({
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
        color: isToday
            ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? const Color(0xFF4CAF50)
              : Colors.white.withValues(alpha: 0.1),
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
                    color: isToday
                        ? const Color(0xFF4CAF50)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                  ),
                  child: Center(
                    child: Text(
                      '${dayNumber ?? ''}',
                      style: TextStyle(
                        color: Colors.white,
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
                            style: const TextStyle(
                              color: Colors.white,
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
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                languageCode == 'tr' ? 'BUGÜN' : 'TODAY',
                                style: const TextStyle(
                                  color: Colors.white,
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
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                languageCode == 'tr' ? 'CUMA' : 'FRIDAY',
                                style: const TextStyle(
                                  color: Colors.white,
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
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mosque Icon for Friday only (not for today)
                if (isFriday)
                  Icon(Icons.mosque, color: const Color(0xFF4CAF50), size: 24),
              ],
            ),
            const SizedBox(height: 12),
            // Prayer Times Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPrayerTimeChip(
                  l10n.fajr,
                  _formatTime(timings?.fajr),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  l10n.sunrise,
                  _formatTime(timings?.sunrise),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  l10n.dhuhr,
                  _formatTime(timings?.dhuhr),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  l10n.asr,
                  _formatTime(timings?.asr),
                  isToday,
                ),
                _buildPrayerTimeChip(
                  l10n.maghrib,
                  _formatTime(timings?.maghrib),
                  isToday,
                ),
                _buildPrayerTimeChip(
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
    // Remove timezone info if present (e.g., "05:33 (EET)")
    return time.split(' ').first.split('(').first.trim();
  }

  Widget _buildPrayerTimeChip(String label, String time, bool isHighlighted) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Text(
                label.length > 5 ? label.substring(0, 5) : label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  color: isHighlighted ? const Color(0xFF4CAF50) : Colors.white,
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
