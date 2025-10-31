import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prayer_time/features/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class PrayerCountdownCard extends StatefulWidget {
  final Timings nextTimings;
  const PrayerCountdownCard({super.key, required this.nextTimings});

  @override
  State<PrayerCountdownCard> createState() => _PrayerCountdownCardState();
}

class _PrayerCountdownCardState extends State<PrayerCountdownCard> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  String _nextPrayerTime = '';
  String _nextPrayerName = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCountdown();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final l10nL = AppLocalizations.of(context)!;

    final (timeStr, prayerName) = _getNextPrayer(widget.nextTimings, l10nL);

    if (timeStr.isEmpty) {
      _remainingTime = Duration.zero;
      _nextPrayerTime = '';
      _nextPrayerName = '';
      return;
    }

    final nextPrayerDateTime = _parseTimeString(timeStr, now);
    final difference = nextPrayerDateTime.difference(now);

    _remainingTime = difference.isNegative ? Duration.zero : difference;
    _nextPrayerTime = timeStr;
    _nextPrayerName = prayerName;
  }

  DateTime _parseTimeString(String timeStr, DateTime baseDate) {
    try {
      final cleanTime = timeStr.split('(').first.trim();
      final parts = cleanTime.split(':');

      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        var targetTime = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          hour,
          minute,
        );

        if (targetTime.isBefore(baseDate)) {
          targetTime = targetTime.add(const Duration(days: 1));
        }

        return targetTime;
      }
    } catch (e) {
      debugPrint('Saat parse hatası: $e');
    }
    return baseDate;
  }

  (String, String) _getNextPrayer(Timings timings, AppLocalizations l10nL) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    bool hasPassed(String? timeStr) {
      if (timeStr == null) return true;
      try {
        final cleanTime = timeStr.split('(').first.trim();
        final parts = cleanTime.split(':');

        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          if (currentHour > hour) return true;
          if (currentHour == hour && currentMinute >= minute) return true;
        }
      } catch (e) {
        debugPrint('Zaman kontrol hatası: $e');
      }
      return false;
    }

    if (timings.fajr != null && !hasPassed(timings.fajr)) {
      return (timings.fajr!, l10nL.fajr);
    }
    if (timings.sunrise != null && !hasPassed(timings.sunrise)) {
      return (timings.sunrise!, l10nL.sunrise);
    }
    if (timings.dhuhr != null && !hasPassed(timings.dhuhr)) {
      return (timings.dhuhr!, l10nL.dhuhr);
    }
    if (timings.asr != null && !hasPassed(timings.asr)) {
      return (timings.asr!, l10nL.asr);
    }
    if (timings.maghrib != null && !hasPassed(timings.maghrib)) {
      return (timings.maghrib!, l10nL.maghrib);
    }
    if (timings.isha != null && !hasPassed(timings.isha)) {
      return (timings.isha!, l10nL.isha);
    }

    return (timings.fajr ?? '', l10nL.fajr);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Next Prayer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nextPrayerName.isNotEmpty ? _nextPrayerName : '-',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeBox(
                _remainingTime.inHours.toString().padLeft(2, '0'),
                'Hours',
              ),
              const SizedBox(width: 12),
              _buildTimeBox(
                (_remainingTime.inMinutes % 60).toString().padLeft(2, '0'),
                'Minutes',
              ),
              const SizedBox(width: 12),
              _buildTimeBox(
                (_remainingTime.inSeconds % 60).toString().padLeft(2, '0'),
                'Seconds',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nextPrayerTime.isNotEmpty
                ? _nextPrayerTime.split('(').first.trim()
                : '-',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String value, String label) {
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
