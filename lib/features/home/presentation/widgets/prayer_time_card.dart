import 'package:flutter/material.dart';
import 'package:prayer_time/features/calendar/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/core/theme/app_theme.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class PrayerTimeCard extends StatelessWidget {
  final Timings timings;
  const PrayerTimeCard({super.key, required this.timings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Kartın içeriğe göre küçülmesini sağlar
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Namaz Vakitleri - Kayseri", // Başlık
              style: AppTheme.lightTheme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // Vakitleri listelemek için ayrı bir widget
            _PrayerTimeRow(name: l10n.fajr, time: timings.fajr),
            _PrayerTimeRow(name: l10n.sunrise, time: timings.sunrise),
            _PrayerTimeRow(name: l10n.dhuhr, time: timings.dhuhr),
            _PrayerTimeRow(name: l10n.asr, time: timings.asr),
            _PrayerTimeRow(name: l10n.maghrib, time: timings.maghrib),
            _PrayerTimeRow(name: l10n.isha, time: timings.isha),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimeRow extends StatelessWidget {
  final String name;
  final String? time;

  const _PrayerTimeRow({required this.name, this.time});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: textTheme.titleLarge),
          Text(
            time ?? 'N/A', // Modeldeki '?' (nullable) için kontrol
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
