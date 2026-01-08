import 'package:flutter/material.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    final hours = remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Current Time Display
          Text(
            nextPrayerTime.isNotEmpty
                ? nextPrayerTime.split('(').first.trim()
                : '--:--',
            style: TextStyle(
              color: AppTheme.getTextColor(context), // DEĞİŞTİ
              fontSize: 72,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          // Prayer Name
          Text(
            nextPrayerName.isNotEmpty
                ? '$nextPrayerName ${languageCode == 'tr' ? 'Vakti' : 'Time'}'
                : '',
            style: TextStyle(
              color: AppTheme.getTextColor(context), // DEĞİŞTİ
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Countdown Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.getCountdownBadgeBackground(context), // DEĞİŞTİ
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.5), // SABİT
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.hourglass_empty,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$hours:$minutes:$seconds',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  languageCode == 'tr' ? 'kaldı' : 'left',
                  style: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context), // DEĞİŞTİ
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Next Prayer Info
          _buildNextPrayerInfo(context, l10n, languageCode),
        ],
      ),
    );
  }

  Widget _buildNextPrayerInfo(
    BuildContext context,
    AppLocalizations l10n,
    String languageCode,
  ) {
    return Text(
      '${languageCode == 'tr' ? 'Sonraki' : 'Next'}: $nextPrayerName',
      style: TextStyle(
        color: AppTheme.getTertiaryTextColor(context), // DEĞİŞTİ
        fontSize: 14,
      ),
    );
  }
}
