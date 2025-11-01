import 'package:flutter/material.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Text(
              "${l10nL.prayTimes} - $cityName", // Başlık
            ),
            SizedBox(height: 16),
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
        children: [Text(name), const SizedBox(height: 4), Text(time!)],
      ),
    );
  }
}
