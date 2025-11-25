import 'package:flutter/material.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class PrayerCountdownCard extends StatelessWidget {
  final Duration remainingTime;
  final String nextPrayerName;
  final String nextPrayerTime;

  const PrayerCountdownCard({
    super.key,
    required this.remainingTime,
    required this.nextPrayerName,
    required this.nextPrayerTime,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final l10nL = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            appTheme.colorScheme.primary,
            appTheme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10nL.nextPrayer,
            style: appTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextPrayerName.isNotEmpty ? nextPrayerName : '-',
            style: appTheme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeBox(
                appTheme,
                remainingTime.inHours.toString().padLeft(2, '0'),
                l10nL.hours,
              ),
              const SizedBox(width: 12),
              _buildTimeBox(
                appTheme,
                (remainingTime.inMinutes % 60).toString().padLeft(2, '0'),
                l10nL.minutes,
              ),
              const SizedBox(width: 12),
              _buildTimeBox(
                appTheme,
                (remainingTime.inSeconds % 60).toString().padLeft(2, '0'),
                l10nL.seconds,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            nextPrayerTime.isNotEmpty
                ? nextPrayerTime.split('(').first.trim()
                : '-',
            style: appTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(ThemeData theme, String value, String label) {
    final appTheme = theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: appTheme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: appTheme.textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
