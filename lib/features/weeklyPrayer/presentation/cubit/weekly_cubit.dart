import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/features/weeklyPrayer/data/repository/weekly_repository.dart';

part 'weekly_state.dart';

class WeeklyCubit extends Cubit<WeeklyState> {
  final CacheService cacheService;

  WeeklyCubit(this.cacheService) : super(WeeklyInitial());

  Future<void> fetchWeeklyPrayerTimes({
    Map<String, String>? savedLocation,
  }) async {
    emit(WeeklyLoading());

    try {
      final WeeklyRepository weeklyRepository = WeeklyRepository(cacheService);
      final weeklyTimings = await weeklyRepository.getWeeklyPrayerTimes(
        savedLocation: savedLocation,
      );
      final cityName = weeklyRepository.cityName;
      emit(WeeklyLoaded(weeklyTimings: weeklyTimings, cityName: cityName));
    } catch (e) {
      emit(WeeklyError(e.toString()));
    }
  }
}
