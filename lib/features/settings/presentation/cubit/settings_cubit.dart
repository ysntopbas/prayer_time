import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/services/location_service.dart';
import 'package:prayer_time/core/services/storage_services.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageServices storageServices;
  final LocationService locationService;

  SettingsCubit(this.storageServices, this.locationService)
    : super(const SettingsState(isDarkMode: false, languageCode: 'en')) {
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
    final notificationBeforeSettings =
        storageServices
            .getMap('notificationBeforeSettings')
            ?.map((key, value) => MapEntry(key, value as bool)) ??
        const {
          'fajr': false,
          'sunrise': false,
          'dhuhr': false,
          'asr': false,
          'maghrib': false,
          'isha': false,
        };
    final silentModeDuringSettings =
        storageServices
            .getMap('silentModeDuringSettings')
            ?.map((key, value) => MapEntry(key, value as bool)) ??
        const {
          'fajr': false,
          'sunrise': false,
          'dhuhr': false,
          'asr': false,
          'maghrib': false,
          'isha': false,
        };
    final notificationBeforeMinutes =
        storageServices
            .getMap('notificationBeforeMinutes')
            ?.map((key, value) => MapEntry(key, value as int)) ??
        const {
          'fajr': 1,
          'sunrise': 1,
          'dhuhr': 1,
          'asr': 1,
          'maghrib': 1,
          'isha': 1,
        };
    final silentModeBeforeDurations =
        storageServices
            .getMap('silentModeBeforeDurations')
            ?.map((key, value) => MapEntry(key, value as int)) ??
        const {
          'fajr': 1,
          'sunrise': 1,
          'dhuhr': 1,
          'asr': 1,
          'maghrib': 1,
          'isha': 1,
        };
    final silentModeAfterDurations =
        storageServices
            .getMap('silentModeAfterDurations')
            ?.map((key, value) => MapEntry(key, value as int)) ??
        const {
          'fajr': 1,
          'sunrise': 1,
          'dhuhr': 1,
          'asr': 1,
          'maghrib': 1,
          'isha': 1,
        };

    emit(
      SettingsState(
        isDarkMode: isDarkMode,
        languageCode: languageCode,
        cityName: cityName,
        countryName: countryName,
        mainNotificationsEnabled: mainNotificationsEnabled,
        mainSilentModeEnabled: mainSilentModeEnabled,
        notificationBeforeSettings: notificationBeforeSettings,
        silentModeDuringSettings: silentModeDuringSettings,
        notificationBeforeMinutes: notificationBeforeMinutes,
        silentModeBeforeDurations: silentModeBeforeDurations,
        silentModeAfterDurations: silentModeAfterDurations,
      ),
    );
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
    emit(
      state.copyWith(mainNotificationsEnabled: !state.mainNotificationsEnabled),
    );
    storageServices.saveBool(
      'mainNotificationsEnabled',
      state.mainNotificationsEnabled,
    );
  }

  void mainToggleSilentMode() {
    emit(state.copyWith(mainSilentModeEnabled: !state.mainSilentModeEnabled));
    storageServices.saveBool(
      'mainSilentModeEnabled',
      state.mainSilentModeEnabled,
    );
  }

  void toggleNotificationBeforeSetting(String prayTime, bool value) {
    final updatedSettings = Map<String, bool>.from(
      state.notificationBeforeSettings,
    );
    updatedSettings[prayTime] = value;

    emit(state.copyWith(notificationBeforeSettings: updatedSettings));
    storageServices.saveMap('notificationBeforeSettings', updatedSettings);
  }

  void toggleSilentModeDuringSetting(String prayTime, bool value) {
    final updatedSettings = Map<String, bool>.from(
      state.silentModeDuringSettings,
    );
    updatedSettings[prayTime] = value;

    emit(state.copyWith(silentModeDuringSettings: updatedSettings));
    storageServices.saveMap('silentModeDuringSettings', updatedSettings);
  }

  void updateNotificationBeforeMinutes(String prayTime, int minutes) {
    final updatedMinutes = Map<String, int>.from(
      state.notificationBeforeMinutes,
    );
    updatedMinutes[prayTime] = minutes;

    emit(state.copyWith(notificationBeforeMinutes: updatedMinutes));
    storageServices.saveMap('notificationBeforeMinutes', updatedMinutes);
  }

  void updateSilentModeBeforeDurations(String prayTime, int minutes) {
    final updatedDurations = Map<String, int>.from(
      state.silentModeBeforeDurations,
    );
    updatedDurations[prayTime] = minutes;

    emit(state.copyWith(silentModeBeforeDurations: updatedDurations));
    storageServices.saveMap('silentModeBeforeDurations', updatedDurations);
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
