import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/services/storage_services.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageServices storageServices;
  SettingsCubit(this.storageServices)
    : super(SettingsState(isDarkMode: false, languageCode: 'en')) {
    final isDarkMode = storageServices.getBool('isDarkMode') ?? false;
    final languageCode = storageServices.getString('languageCode') ?? 'en';
    emit(SettingsState(isDarkMode: isDarkMode, languageCode: languageCode));
  }

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
    storageServices.saveBool('isDarkMode', state.isDarkMode);
  }

  void changeLanguage(String languageCode) {
    emit(state.copyWith(languageCode: languageCode));
    storageServices.saveString('languageCode', languageCode);
  }
}
