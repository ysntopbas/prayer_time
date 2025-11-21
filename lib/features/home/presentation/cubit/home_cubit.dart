import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Context için gerekli
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/features/home/data/repository/home_repository.dart';
// LocationServiceInitialization sınıfını import etmeyi unutma
import 'package:prayer_time/core/services/locationServices/location_service_initialization.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final CacheService cacheService;

  HomeCubit(this.cacheService) : super(HomeInitial());

  // Context parametresini ekledik
  Future<void> fetchPrayerTimes({
    Map<String, String>? savedLocation,
    required BuildContext context,
  }) async {
    // Loading durumuna geç (Ekranda dönen çember çıksın)
    // Bu sayede kullanıcı dialoglarla uğraşırken arkada boş ekran görmez
    emit(HomeLoading());

    // -- KONUM SERVİSİ AKIŞI BAŞLIYOR --
    final locationInit = LocationServiceInitialization(context);

    // initialize() metodu, kullanıcı GPS açıp dönene kadar burada bekler (await).
    bool isLocationReady = await locationInit.initialize();

    Map<String, String>? finalLocation = savedLocation;

    // Eğer kullanıcı her şeyi onayladıysa (GPS + İzin), güncel konumu çekmeye çalış
    if (isLocationReady) {
      try {
        // Konum alma kodunu buraya repository üzerinden veya direkt servis üzerinden çağırabilirsin.
        // Örnek olarak repository'nin konum bulma metodunu tetikleyebilirsin
        // Veya savedLocation'ı null yaparak repository'nin taze konum çekmesini sağlayabilirsin.
        finalLocation =
            null; // Repository taze konum çeksin diye null yapıyoruz
      } catch (e) {
        log("Konum alınamadı, varsayılan kullanılacak.");
      }
    } else {
      log(
        "Kullanıcı konumu veya izni reddetti, kayıtlı/varsayılan konum kullanılacak.",
      );
    }
    // -- KONUM SERVİSİ AKIŞI BİTTİ --

    try {
      final HomeRepository homeRepository = HomeRepository(cacheService);

      // finalLocation null ise Repository taze konum çeker (senin repo mantığına göre)
      // finalLocation doluysa onu kullanır.
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
}
