import 'package:flutter/material.dart';
import 'package:prayer_time/features/core/domain/models/prayer_time_model.dart';
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
    final l10nL = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Today's Prayer Times",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _buildPrayerItem(
            context,
            icon: Icons.nightlight_round,
            iconColor: const Color(0xFF7E57C2),
            title: l10nL.fajr,
            subtitle: 'Dawn Prayer',
            time: timings.fajr ?? '-',
            isNext: nextPrayerName == l10nL.fajr,
          ),
          _buildDivider(),
          _buildPrayerItem(
            context,
            icon: Icons.wb_sunny_outlined,
            iconColor: const Color(0xFFFFA726),
            title: l10nL.sunrise,
            subtitle: 'Sun Rise',
            time: timings.sunrise ?? '-',
            isNext: nextPrayerName == l10nL.sunrise,
          ),
          _buildDivider(),
          _buildPrayerItem(
            context,
            icon: Icons.wb_sunny,
            iconColor: const Color(0xFF9C27B0),
            title: l10nL.dhuhr,
            subtitle: 'Noon/Midday Prayer',
            time: timings.dhuhr ?? '-',
            isNext: nextPrayerName == l10nL.dhuhr,
          ),
          _buildDivider(),
          _buildPrayerItem(
            context,
            icon: Icons.wb_cloudy,
            iconColor: const Color(0xFFFF7043),
            title: l10nL.asr,
            subtitle: 'Afternoon Prayer',
            time: timings.asr ?? '-',
            isNext: nextPrayerName == l10nL.asr,
          ),
          _buildDivider(),
          _buildPrayerItem(
            context,
            icon: Icons.wb_twilight,
            iconColor: const Color(0xFFEF5350),
            title: l10nL.maghrib,
            subtitle: 'Sunset Prayer',
            time: timings.maghrib ?? '-',
            isNext: nextPrayerName == l10nL.maghrib,
          ),
          _buildDivider(),
          _buildPrayerItem(
            context,
            icon: Icons.nights_stay,
            iconColor: const Color(0xFF5C6BC0),
            title: l10nL.isha,
            subtitle: 'Night Prayer',
            time: timings.isha ?? '-',
            isNext: nextPrayerName == l10nL.isha,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isNext,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isNext
            ? Border(left: BorderSide(color: colorScheme.primary, width: 4))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isNext ? 'Next Prayer' : subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isNext
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(time),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
    );
  }

  String _formatTime(String time) {
    try {
      // API'den gelen format: "05:30 (EET)" veya "05:30"
      final cleanTime = time.split('(').first.trim();
      return cleanTime;
    } catch (e) {
      return time;
    }
  }
}
