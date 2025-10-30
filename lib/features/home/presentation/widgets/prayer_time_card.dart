import 'package:flutter/material.dart';
import 'package:prayer_time/features/calendar/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/core/widgets/custom_card.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class PrayerTimeHomeCard extends StatelessWidget {
  final Timings timings;
  final String cityName;
  const PrayerTimeHomeCard({
    super.key,
    required this.timings,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TimeCard(
      cityName: cityName,
      prayName: [
        l10n.fajr,
        l10n.sunrise,
        l10n.dhuhr,
        l10n.asr,
        l10n.maghrib,
        l10n.isha,
      ],
      timings: timings,
    );
  }
}
