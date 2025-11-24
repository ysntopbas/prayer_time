import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/features/home/data/repository/home_repository.dart';
import 'package:prayer_time/core/services/locationServices/location_service_initialization.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final CacheService cacheService;

  HomeCubit(this.cacheService) : super(HomeInitial());

  Future<void> fetchPrayerTimes({
    Map<String, String>? savedLocation,
    required BuildContext context,
  }) async {
    emit(HomeLoading());

    Map<String, String>? finalLocation = savedLocation;

    //  Kayıtlı konum yoksa GPS kontrolü
    if (savedLocation == null) {
      final locationInit = LocationServiceInitialization(context);
      bool isLocationReady = await locationInit.initialize();

      if (isLocationReady) {
        try {
          finalLocation = null;
        } catch (e) {
          log("Konum alınamadı, varsayılan kullanılacak.");
        }
      } else {
        log("Kullanıcı konumu reddetti, varsayılan konum kullanılacak.");
      }
    }

    try {
      final HomeRepository homeRepository = HomeRepository(cacheService);

      final prayerTimes = await homeRepository.getPrayerTimes(
        savedLocation: finalLocation,
      );

      final nextPrayerTimes = await homeRepository.getNextPrayerTimes(
        savedLocation: finalLocation,
      );

      final cityName = homeRepository.cityName;
      final subAdministrativeArea = homeRepository.subAdministrativeArea;

      emit(
        HomeLoaded(
          prayerTimings: prayerTimes,
          cityName: cityName,
          subAdministrativeArea: subAdministrativeArea,
          nextTimings: nextPrayerTimes,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void loadPrayerTimes(BuildContext context) {
    fetchPrayerTimes(context: context);
  }
}
