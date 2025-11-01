import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/features/home/data/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final CacheService cacheService;

  HomeCubit(this.cacheService) : super(HomeInitial());

  Future<void> fetchPrayerTimes({Map<String, String>? savedLocation}) async {
    emit(HomeLoading());

    try {
      final HomeRepository homeRepository = HomeRepository(cacheService);
      final prayerTimes = await homeRepository.getPrayerTimes(
        savedLocation: savedLocation,
      );
      final nextPrayerTimes = await homeRepository.getNextPrayerTimes(
        savedLocation: savedLocation,
      );
      final cityName = homeRepository.cityName;
      emit(
        HomeLoaded(
          prayerTimings: prayerTimes,
          cityName: cityName,
          nextTimings: nextPrayerTimes,
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
