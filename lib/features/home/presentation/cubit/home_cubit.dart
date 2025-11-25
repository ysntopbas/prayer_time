import 'dart:async';
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
  Timer? _countdownTimer;

  HomeCubit(this.cacheService) : super(HomeInitial());

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }

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
          remainingTime: Duration.zero,
          nextPrayerName: '',
          nextPrayerTime: '',
        ),
      );

      _startCountdown();
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final now = DateTime.now();

        final nextPrayerInfo = _getNextPrayerInfo(
          currentState.prayerTimings,
          currentState.nextTimings,
          now,
        );

        if (nextPrayerInfo != null) {
          emit(
            HomeLoaded(
              prayerTimings: currentState.prayerTimings,
              cityName: currentState.cityName,
              subAdministrativeArea: currentState.subAdministrativeArea,
              nextTimings: currentState.nextTimings,
              remainingTime: nextPrayerInfo['remainingTime'] as Duration,
              nextPrayerName: nextPrayerInfo['name'] as String,
              nextPrayerTime: nextPrayerInfo['time'] as String,
            ),
          );
        }
      }
    });
  }

  Map<String, dynamic>? _getNextPrayerInfo(
    Timings todayTimings,
    Timings tomorrowTimings,
    DateTime now,
  ) {
    DateTime? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      try {
        final cleanTime = timeStr.split('(').first.trim();
        final parts = cleanTime.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      } catch (e) {
        log('Time parse error: $e');
      }
      return null;
    }

    final prayers = [
      {'name': 'Fajr', 'time': todayTimings.fajr, 'isTomorrow': false},
      {'name': 'Sunrise', 'time': todayTimings.sunrise, 'isTomorrow': false},
      {'name': 'Dhuhr', 'time': todayTimings.dhuhr, 'isTomorrow': false},
      {'name': 'Asr', 'time': todayTimings.asr, 'isTomorrow': false},
      {'name': 'Maghrib', 'time': todayTimings.maghrib, 'isTomorrow': false},
      {'name': 'Isha', 'time': todayTimings.isha, 'isTomorrow': false},
      {'name': 'Fajr', 'time': tomorrowTimings.fajr, 'isTomorrow': true},
    ];

    for (var prayer in prayers) {
      final prayerTime = parseTime(prayer['time'] as String?);
      if (prayerTime != null) {
        DateTime targetTime = prayerTime;
        if (prayer['isTomorrow'] == true) {
          targetTime = targetTime.add(const Duration(days: 1));
        }

        if (now.isBefore(targetTime)) {
          final remaining = targetTime.difference(now);
          return {
            'remainingTime': remaining,
            'name': prayer['name'],
            'time': prayer['time'],
          };
        }
      }
    }

    return null;
  }

  void loadPrayerTimes(BuildContext context) {
    fetchPrayerTimes(context: context);
  }
}
