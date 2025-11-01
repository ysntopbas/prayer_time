part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final String languageCode;
  final String? cityName;
  final String? countryName;
  final bool isLocationLoading;

  const SettingsState({
    required this.isDarkMode,
    required this.languageCode,
    this.cityName,
    this.countryName,
    this.isLocationLoading = false,
  });

  @override
  List<Object?> get props => [
    isDarkMode,
    languageCode,
    cityName,
    countryName,
    isLocationLoading,
  ];

  SettingsState copyWith({
    bool? isDarkMode,
    String? languageCode,
    String? cityName,
    String? countryName,
    bool? isLocationLoading,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
    );
  }
}
