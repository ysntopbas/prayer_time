part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final String languageCode;

  const SettingsState({required this.isDarkMode, required this.languageCode});

  @override
  List<Object> get props => [isDarkMode, languageCode];
  SettingsState copyWith({bool? isDarkMode, String? languageCode}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
