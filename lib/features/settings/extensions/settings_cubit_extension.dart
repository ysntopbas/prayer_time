import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get key => name;
}

extension NotificationSettingsExtension on NotificationBeforePraysSettings {
  NotificationBeforePrays? getByKey(String prayerKey) {
    switch (prayerKey.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return null;
    }
  }

  NotificationBeforePraysSettings updateByKey(
    String prayerKey,
    NotificationBeforePrays updated,
  ) {
    switch (prayerKey.toLowerCase()) {
      case 'fajr':
        return copyWith(fajr: updated);
      case 'sunrise':
        return copyWith(sunrise: updated);
      case 'dhuhr':
        return copyWith(dhuhr: updated);
      case 'asr':
        return copyWith(asr: updated);
      case 'maghrib':
        return copyWith(maghrib: updated);
      case 'isha':
        return copyWith(isha: updated);
      default:
        return this;
    }
  }
}

extension SilentModeSettingsExtension on SilentModeDuringPraysSettings {
  SilentModeDuringPrays? getByKey(String prayerKey) {
    switch (prayerKey.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return null;
    }
  }

  SilentModeDuringPraysSettings updateByKey(
    String prayerKey,
    SilentModeDuringPrays updated,
  ) {
    switch (prayerKey.toLowerCase()) {
      case 'fajr':
        return copyWith(fajr: updated);
      case 'sunrise':
        return copyWith(sunrise: updated);
      case 'dhuhr':
        return copyWith(dhuhr: updated);
      case 'asr':
        return copyWith(asr: updated);
      case 'maghrib':
        return copyWith(maghrib: updated);
      case 'isha':
        return copyWith(isha: updated);
      default:
        return this;
    }
  }
}
