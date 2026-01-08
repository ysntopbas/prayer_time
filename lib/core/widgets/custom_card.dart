import 'package:flutter/material.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class TimeCard extends StatelessWidget {
  final List<String> prayName;
  final Timings timings;
  final String? cityName;
  const TimeCard({
    super.key,
    required this.prayName,
    required this.timings,
    this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      color: AppTheme.chipBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.cardBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Text(
              "${l10nL.prayTimes} - $cityName",
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CustomCardColumn(name: prayName[0], time: timings.fajr),
                CustomCardColumn(name: prayName[1], time: timings.sunrise),
                CustomCardColumn(name: prayName[2], time: timings.dhuhr),
                CustomCardColumn(name: prayName[3], time: timings.asr),
                CustomCardColumn(name: prayName[4], time: timings.maghrib),
                CustomCardColumn(name: prayName[5], time: timings.isha),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCardColumn extends StatelessWidget {
  final String name;
  final String? time;

  const CustomCardColumn({required this.name, this.time, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(color: AppTheme.textWhite60, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            time ?? '--:--',
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
