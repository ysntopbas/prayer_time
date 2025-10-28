import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState(isDarkMode: false, languageCode: 'en'));

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void changeLanguage(String languageCode) {
    emit(state.copyWith(languageCode: languageCode));
  }
}
