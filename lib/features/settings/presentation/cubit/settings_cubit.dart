import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/services/location_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageServices storageServices;
  final LocationService locationService;

  SettingsCubit(this.storageServices, this.locationService)
    : super(const SettingsState()) {
    _loadInitialSettings();
  }

  void _loadInitialSettings() {
    final isDarkMode = storageServices.getBool('isDarkMode') ?? false;
    final languageCode = storageServices.getString('languageCode') ?? 'en';
    final cityName = storageServices.getString('cityName');
    final countryName = storageServices.getString('countryName');
    final mainNotificationsEnabled =
        storageServices.getBool('mainNotificationsEnabled') ?? false;
    final mainSilentModeEnabled =
        storageServices.getBool('mainSilentModeEnabled') ?? false;

    final notificationSettings = _loadNotificationSettings();
    final silentModeSettings = _loadSilentModeSettings();

    emit(
      SettingsState(
        isDarkMode: isDarkMode,
        languageCode: languageCode,
        cityName: cityName,
        countryName: countryName,
        mainNotificationsEnabled: mainNotificationsEnabled,
        mainSilentModeEnabled: mainSilentModeEnabled,
        notificationBeforePraysSettings: notificationSettings,
        silentModeDuringPraysSettings: silentModeSettings,
      ),
    );
  }

  NotificationBeforePraysSettings _loadNotificationSettings() {
    return NotificationBeforePraysSettings(
      fajr: _loadSingleNotificationSetting('fajr_notification'),
      sunrise: _loadSingleNotificationSetting('sunrise_notification'),
      dhuhr: _loadSingleNotificationSetting('dhuhr_notification'),
      asr: _loadSingleNotificationSetting('asr_notification'),
      maghrib: _loadSingleNotificationSetting('maghrib_notification'),
      isha: _loadSingleNotificationSetting('isha_notification'),
    );
  }

  NotificationBeforePrays _loadSingleNotificationSetting(String key) {
    final jsonString = storageServices.getString(key);
    if (jsonString != null) {
      try {
        return NotificationBeforePrays.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } catch (e) {
        return const NotificationBeforePrays();
      }
    }
    return const NotificationBeforePrays();
  }

  SilentModeDuringPraysSettings _loadSilentModeSettings() {
    return SilentModeDuringPraysSettings(
      fajr: _loadSingleSilentModeSetting('fajr_silent'),
      sunrise: _loadSingleSilentModeSetting('sunrise_silent'),
      dhuhr: _loadSingleSilentModeSetting('dhuhr_silent'),
      asr: _loadSingleSilentModeSetting('asr_silent'),
      maghrib: _loadSingleSilentModeSetting('maghrib_silent'),
      isha: _loadSingleSilentModeSetting('isha_silent'),
    );
  }

  SilentModeDuringPrays _loadSingleSilentModeSetting(String key) {
    final jsonString = storageServices.getString(key);
    if (jsonString != null) {
      try {
        return SilentModeDuringPrays.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } catch (e) {
        return const SilentModeDuringPrays();
      }
    }
    return const SilentModeDuringPrays();
  }

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
    storageServices.saveBool('isDarkMode', state.isDarkMode);
  }

  void changeLanguage(String languageCode) {
    emit(state.copyWith(languageCode: languageCode));
    storageServices.saveString('languageCode', languageCode);
  }

  void mainToggleNotifications() {
    final newValue = !state.mainNotificationsEnabled;
    emit(state.copyWith(mainNotificationsEnabled: newValue));
    storageServices.saveBool('mainNotificationsEnabled', newValue);

    if (!newValue) {
      _disableAllNotifications();
    }
  }

  void _disableAllNotifications() {
    final prayers = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
    for (final prayer in prayers) {
      updateNotificationSetting(prayerName: prayer, isEnabled: false);
    }
  }

  void mainToggleSilentMode() {
    final newValue = !state.mainSilentModeEnabled;
    emit(state.copyWith(mainSilentModeEnabled: newValue));
    storageServices.saveBool('mainSilentModeEnabled', newValue);

    if (!newValue) {
      _disableAllSilentModes();
    }
  }

  void _disableAllSilentModes() {
    final prayers = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
    for (final prayer in prayers) {
      updateSilentModeSetting(prayerName: prayer, isEnabled: false);
    }
  }

  Future<void> updateNotificationSetting({
    required String prayerName,
    bool? isEnabled,
    int? minutesBefore,
  }) async {
    final currentSettings = state.notificationBeforePraysSettings;
    NotificationBeforePraysSettings newSettings;

    switch (prayerName.toLowerCase()) {
      case 'fajr':
        final updated = currentSettings.fajr.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
        );
        newSettings = currentSettings.copyWith(fajr: updated);
        await storageServices.saveString(
          'fajr_notification',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'sunrise':
        final updated = currentSettings.sunrise.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
        );
        newSettings = currentSettings.copyWith(sunrise: updated);
        await storageServices.saveString(
          'sunrise_notification',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'dhuhr':
        final updated = currentSettings.dhuhr.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
        );
        newSettings = currentSettings.copyWith(dhuhr: updated);
        await storageServices.saveString(
          'dhuhr_notification',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'asr':
        final updated = currentSettings.asr.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
        );
        newSettings = currentSettings.copyWith(asr: updated);
        await storageServices.saveString(
          'asr_notification',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'maghrib':
        final updated = currentSettings.maghrib.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
        );
        newSettings = currentSettings.copyWith(maghrib: updated);
        await storageServices.saveString(
          'maghrib_notification',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'isha':
        final updated = currentSettings.isha.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
        );
        newSettings = currentSettings.copyWith(isha: updated);
        await storageServices.saveString(
          'isha_notification',
          jsonEncode(updated.toJson()),
        );
        break;
      default:
        return;
    }

    emit(state.copyWith(notificationBeforePraysSettings: newSettings));
  }

  Future<void> updateSilentModeSetting({
    required String prayerName,
    bool? isEnabled,
    int? minutesBefore,
    int? minutesAfter,
  }) async {
    final currentSettings = state.silentModeDuringPraysSettings;
    SilentModeDuringPraysSettings newSettings;

    switch (prayerName.toLowerCase()) {
      case 'fajr':
        final updated = currentSettings.fajr.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
          minutesAfter: minutesAfter,
        );
        newSettings = currentSettings.copyWith(fajr: updated);
        await storageServices.saveString(
          'fajr_silent',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'sunrise':
        final updated = currentSettings.sunrise.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
          minutesAfter: minutesAfter,
        );
        newSettings = currentSettings.copyWith(sunrise: updated);
        await storageServices.saveString(
          'sunrise_silent',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'dhuhr':
        final updated = currentSettings.dhuhr.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
          minutesAfter: minutesAfter,
        );
        newSettings = currentSettings.copyWith(dhuhr: updated);
        await storageServices.saveString(
          'dhuhr_silent',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'asr':
        final updated = currentSettings.asr.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
          minutesAfter: minutesAfter,
        );
        newSettings = currentSettings.copyWith(asr: updated);
        await storageServices.saveString(
          'asr_silent',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'maghrib':
        final updated = currentSettings.maghrib.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
          minutesAfter: minutesAfter,
        );
        newSettings = currentSettings.copyWith(maghrib: updated);
        await storageServices.saveString(
          'maghrib_silent',
          jsonEncode(updated.toJson()),
        );
        break;
      case 'isha':
        final updated = currentSettings.isha.copyWith(
          isEnabled: isEnabled,
          minutesBefore: minutesBefore,
          minutesAfter: minutesAfter,
        );
        newSettings = currentSettings.copyWith(isha: updated);
        await storageServices.saveString(
          'isha_silent',
          jsonEncode(updated.toJson()),
        );
        break;
      default:
        return;
    }

    emit(state.copyWith(silentModeDuringPraysSettings: newSettings));
  }

  Future<void> updateLocation() async {
    emit(state.copyWith(isLocationLoading: true));

    try {
      final locationData = await locationService.getCurrentCity();

      if (locationData != null) {
        final cityName = locationData['city'];
        final countryName = locationData['country'];

        await storageServices.saveString('cityName', cityName ?? '');
        await storageServices.saveString('countryName', countryName ?? '');

        emit(
          state.copyWith(
            cityName: cityName,
            countryName: countryName,
            isLocationLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(isLocationLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLocationLoading: false));
    }
  }

  Map<String, String>? getSavedLocation() {
    final cityName = state.cityName;
    final countryName = state.countryName;

    if (cityName != null && countryName != null) {
      return {'city': cityName, 'country': countryName};
    }
    return null;
  }
}
