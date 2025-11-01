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

    emit(
      SettingsState(
        isDarkMode: isDarkMode,
        languageCode: languageCode,
        cityName: cityName,
        countryName: countryName,
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

  Future<void> updateLocation() async {
    emit(state.copyWith(isLocationLoading: true));

    try {
      final locationData = await locationService.getCurrentCity();

      if (locationData != null) {
        final cityName = locationData['city'];
        final countryName = locationData['country'];

        // Storage'a kaydet
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
      // Hata durumunu isteğe bağlı olarak yönetebilirsiniz
    }
  }

  // Kaydedilmiş konumu al
  Map<String, String>? getSavedLocation() {
    final cityName = state.cityName;
    final countryName = state.countryName;

    if (cityName != null && countryName != null) {
      return {'city': cityName, 'country': countryName};
    }
    return null;
  }
}
