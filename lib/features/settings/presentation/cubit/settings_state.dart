part of 'settings_cubit.dart';

// Her namaz için bildirim ayarları
class NotificationBeforePrays extends Equatable {
  final bool isEnabled;
  final int minutesBefore;

  const NotificationBeforePrays({
    this.isEnabled = false,
    this.minutesBefore = 10,
  });

  Map<String, dynamic> toJson() {
    return {'isEnabled': isEnabled, 'minutesBefore': minutesBefore};
  }

  factory NotificationBeforePrays.fromJson(Map<String, dynamic> json) {
    return NotificationBeforePrays(
      isEnabled: json['isEnabled'] as bool? ?? false,
      minutesBefore: json['minutesBefore'] as int? ?? 10,
    );
  }

  NotificationBeforePrays copyWith({bool? isEnabled, int? minutesBefore}) {
    return NotificationBeforePrays(
      isEnabled: isEnabled ?? this.isEnabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }

  @override
  List<Object?> get props => [isEnabled, minutesBefore];
}

// Tüm namazlar için bildirim ayarları
class NotificationBeforePraysSettings extends Equatable {
  final NotificationBeforePrays fajr;
  final NotificationBeforePrays sunrise;
  final NotificationBeforePrays dhuhr;
  final NotificationBeforePrays asr;
  final NotificationBeforePrays maghrib;
  final NotificationBeforePrays isha;

  const NotificationBeforePraysSettings({
    this.fajr = const NotificationBeforePrays(),
    this.sunrise = const NotificationBeforePrays(),
    this.dhuhr = const NotificationBeforePrays(),
    this.asr = const NotificationBeforePrays(),
    this.maghrib = const NotificationBeforePrays(),
    this.isha = const NotificationBeforePrays(),
  });

  NotificationBeforePraysSettings copyWith({
    NotificationBeforePrays? fajr,
    NotificationBeforePrays? sunrise,
    NotificationBeforePrays? dhuhr,
    NotificationBeforePrays? asr,
    NotificationBeforePrays? maghrib,
    NotificationBeforePrays? isha,
  }) {
    return NotificationBeforePraysSettings(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  @override
  List<Object?> get props => [fajr, sunrise, dhuhr, asr, maghrib, isha];
}

// Her namaz için sessiz mod ayarları
class SilentModeDuringPrays extends Equatable {
  final bool isEnabled;
  final int minutesBefore;
  final int minutesAfter;

  const SilentModeDuringPrays({
    this.isEnabled = false,
    this.minutesBefore = 5,
    this.minutesAfter = 15,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'minutesBefore': minutesBefore,
      'minutesAfter': minutesAfter,
    };
  }

  factory SilentModeDuringPrays.fromJson(Map<String, dynamic> json) {
    return SilentModeDuringPrays(
      isEnabled: json['isEnabled'] as bool? ?? false,
      minutesBefore: json['minutesBefore'] as int? ?? 5,
      minutesAfter: json['minutesAfter'] as int? ?? 15,
    );
  }

  SilentModeDuringPrays copyWith({
    bool? isEnabled,
    int? minutesBefore,
    int? minutesAfter,
  }) {
    return SilentModeDuringPrays(
      isEnabled: isEnabled ?? this.isEnabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      minutesAfter: minutesAfter ?? this.minutesAfter,
    );
  }

  @override
  List<Object?> get props => [isEnabled, minutesBefore, minutesAfter];
}

// Tüm namazlar için sessiz mod ayarları
class SilentModeDuringPraysSettings extends Equatable {
  final SilentModeDuringPrays fajr;
  final SilentModeDuringPrays sunrise;
  final SilentModeDuringPrays dhuhr;
  final SilentModeDuringPrays asr;
  final SilentModeDuringPrays maghrib;
  final SilentModeDuringPrays isha;

  const SilentModeDuringPraysSettings({
    this.fajr = const SilentModeDuringPrays(),
    this.sunrise = const SilentModeDuringPrays(),
    this.dhuhr = const SilentModeDuringPrays(),
    this.asr = const SilentModeDuringPrays(),
    this.maghrib = const SilentModeDuringPrays(),
    this.isha = const SilentModeDuringPrays(),
  });

  SilentModeDuringPraysSettings copyWith({
    SilentModeDuringPrays? fajr,
    SilentModeDuringPrays? sunrise,
    SilentModeDuringPrays? dhuhr,
    SilentModeDuringPrays? asr,
    SilentModeDuringPrays? maghrib,
    SilentModeDuringPrays? isha,
  }) {
    return SilentModeDuringPraysSettings(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  @override
  List<Object?> get props => [fajr, sunrise, dhuhr, asr, maghrib, isha];
}

// Ana State Sınıfı
class SettingsState extends Equatable {
  final bool isDarkMode;
  final String languageCode;
  final String? cityName;
  final String? countryName;
  final String? subAdministrativeArea;
  final bool mainNotificationsEnabled;
  final bool mainSilentModeEnabled;
  final NotificationBeforePraysSettings notificationBeforePraysSettings;
  final SilentModeDuringPraysSettings silentModeDuringPraysSettings;
  final bool isLocationLoading;
  final bool needsPermissionDialog;

  const SettingsState({
    required this.isDarkMode,
    required this.languageCode,
    this.cityName,
    this.countryName,
    this.subAdministrativeArea,
    this.mainNotificationsEnabled = false,
    this.mainSilentModeEnabled = false,
    this.notificationBeforePraysSettings =
        const NotificationBeforePraysSettings(),
    this.silentModeDuringPraysSettings = const SilentModeDuringPraysSettings(),
    this.isLocationLoading = false,
    this.needsPermissionDialog = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? languageCode,
    String? cityName,
    String? countryName,
    String? subAdministrativeArea,
    bool? mainNotificationsEnabled,
    bool? mainSilentModeEnabled,
    NotificationBeforePraysSettings? notificationBeforePraysSettings,
    SilentModeDuringPraysSettings? silentModeDuringPraysSettings,
    bool? isLocationLoading,
    bool? needsPermissionDialog,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      subAdministrativeArea:
          subAdministrativeArea ?? this.subAdministrativeArea,
      mainNotificationsEnabled:
          mainNotificationsEnabled ?? this.mainNotificationsEnabled,
      mainSilentModeEnabled:
          mainSilentModeEnabled ?? this.mainSilentModeEnabled,
      notificationBeforePraysSettings:
          notificationBeforePraysSettings ??
          this.notificationBeforePraysSettings,
      silentModeDuringPraysSettings:
          silentModeDuringPraysSettings ?? this.silentModeDuringPraysSettings,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      needsPermissionDialog:
          needsPermissionDialog ?? this.needsPermissionDialog,
    );
  }

  @override
  List<Object?> get props => [
    isDarkMode,
    languageCode,
    cityName,
    countryName,
    subAdministrativeArea,
    mainNotificationsEnabled,
    mainSilentModeEnabled,
    notificationBeforePraysSettings,
    silentModeDuringPraysSettings,
    isLocationLoading,
    needsPermissionDialog,
  ];
}
