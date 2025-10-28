part of 'settings_cubit.dart';

class SettingsState {
  final bool isDarkMode;
  final String languageCode;

  SettingsState({required this.isDarkMode, required this.languageCode});

  SettingsState copyWith({bool? isDarkMode, String? languageCode}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
