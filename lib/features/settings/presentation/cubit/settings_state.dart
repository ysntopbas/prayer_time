part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final String languageCode;
  final String? cityName;
  final String? countryName;
  final bool isLocationLoading;
  final bool mainNotificationsEnabled;
  final bool mainSilentModeEnabled;
  //Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
  //Sabah, Gunes, Ogle, Ikindi, Aksam, Yatsi
  final Map<String, bool> notificationBeforeSettings;
  final Map<String, bool> silentModeDuringSettings;
  final Map<String, int> notificationBeforeMinutes;
  final Map<String, int> silentModeBeforeDurations;
  final Map<String, int> silentModeAfterDurations;

  const SettingsState({
    required this.isDarkMode,
    required this.languageCode,
    this.cityName,
    this.countryName,
    this.isLocationLoading = false,
    this.mainNotificationsEnabled = false,
    this.mainSilentModeEnabled = false,
    this.notificationBeforeSettings = const {
      'fajr': false,
      'sunrise': false,
      'dhuhr': false,
      'asr': false,
      'maghrib': false,
      'isha': false,
    },
    this.silentModeDuringSettings = const {
      'fajr': false,
      'sunrise': false,
      'dhuhr': false,
      'asr': false,
      'maghrib': false,
      'isha': false,
    },
    this.notificationBeforeMinutes = const {
      'fajr': 1,
      'sunrise': 1,
      'dhuhr': 1,
      'asr': 1,
      'maghrib': 1,
      'isha': 1,
    },
    this.silentModeBeforeDurations = const {
      'fajr': 1,
      'sunrise': 1,
      'dhuhr': 1,
      'asr': 1,
      'maghrib': 1,
      'isha': 1,
    },
    this.silentModeAfterDurations = const {
      'fajr': 1,
      'sunrise': 1,
      'dhuhr': 1,
      'asr': 1,
      'maghrib': 1,
      'isha': 1,
    },
  });

  @override
  List<Object?> get props => [
    isDarkMode,
    languageCode,
    cityName,
    countryName,
    isLocationLoading,
    mainNotificationsEnabled,
    mainSilentModeEnabled,
    notificationBeforeSettings,
    silentModeDuringSettings,
    notificationBeforeMinutes,
    silentModeBeforeDurations,
    silentModeAfterDurations,
  ];

  SettingsState copyWith({
    bool? isDarkMode,
    String? languageCode,
    String? cityName,
    String? countryName,
    bool? isLocationLoading,
    bool? mainNotificationsEnabled,
    bool? mainSilentModeEnabled,
    Map<String, bool>? notificationBeforeSettings,
    Map<String, bool>? silentModeDuringSettings,
    Map<String, int>? notificationBeforeMinutes,
    Map<String, int>? silentModeBeforeDurations,
    Map<String, int>? silentModeAfterDurations,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      mainNotificationsEnabled:
          mainNotificationsEnabled ?? this.mainNotificationsEnabled,
      mainSilentModeEnabled:
          mainSilentModeEnabled ?? this.mainSilentModeEnabled,
      notificationBeforeSettings:
          notificationBeforeSettings ?? this.notificationBeforeSettings,
      silentModeDuringSettings:
          silentModeDuringSettings ?? this.silentModeDuringSettings,
      notificationBeforeMinutes:
          notificationBeforeMinutes ?? this.notificationBeforeMinutes,
      silentModeBeforeDurations:
          silentModeBeforeDurations ?? this.silentModeBeforeDurations,
      silentModeAfterDurations:
          silentModeAfterDurations ?? this.silentModeAfterDurations,
    );
  }
}
