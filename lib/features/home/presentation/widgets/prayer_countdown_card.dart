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
    // initState'de context kullanmıyoruz, sadece timer'ı başlatıyoruz
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
    // İlk güncellemeyi burada yapıyoruz (context güvenli)
    _updateCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    // Bir sonraki namaz vaktini bul
    final (timeStr, prayerName) = _getNextPrayer(widget.nextTimings, l10n);

    if (timeStr.isEmpty) {
      _remainingTime = Duration.zero;
      _nextPrayerTime = '';
      _nextPrayerName = '';
      return;
    }

    // Namaz vaktini DateTime'a çevir
    final nextPrayerDateTime = _parseTimeString(timeStr, now);

    // Kalan süreyi hesapla
    final difference = nextPrayerDateTime.difference(now);

    _remainingTime = difference.isNegative ? Duration.zero : difference;
    _nextPrayerTime = timeStr;
    _nextPrayerName = prayerName;
  }

  DateTime _parseTimeString(String timeStr, DateTime baseDate) {
    try {
      // API'den gelen format: "05:30 (EET)" veya "05:30"
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

        // Eğer hedef saat geçmişte ise, yarına ekle
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

  String _formatDuration(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return '00:00:00';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  (String, String) _getNextPrayer(Timings timings, AppLocalizations l10n) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    // Helper function to check if prayer time has passed
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

    // Sırayla kontrol et
    if (timings.fajr != null && !hasPassed(timings.fajr)) {
      return (timings.fajr!, l10n.fajr);
    }
    if (timings.sunrise != null && !hasPassed(timings.sunrise)) {
      return (timings.sunrise!, l10n.sunrise);
    }
    if (timings.dhuhr != null && !hasPassed(timings.dhuhr)) {
      return (timings.dhuhr!, l10n.dhuhr);
    }
    if (timings.asr != null && !hasPassed(timings.asr)) {
      return (timings.asr!, l10n.asr);
    }
    if (timings.maghrib != null && !hasPassed(timings.maghrib)) {
      return (timings.maghrib!, l10n.maghrib);
    }
    if (timings.isha != null && !hasPassed(timings.isha)) {
      return (timings.isha!, l10n.isha);
    }

    // Tüm vakitler geçmişse, yarının ilk vaktini döndür (Sabah)
    if (timings.fajr != null) {
      return (timings.fajr!, l10n.fajr);
    }

    return ('', '');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 1),
              colorScheme.primary.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Bir sonraki namaz adı
              Text(
                _nextPrayerName.isNotEmpty ? _nextPrayerName : '-',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Namaz saati
              Text(
                _nextPrayerTime.isNotEmpty ? _nextPrayerTime : '-',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Geri sayım
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 2),
                  ),
                ),
                child: Text(
                  _formatDuration(_remainingTime),
                  style: textTheme.displaySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Kalan süre etiketi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Kalan Süre',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
