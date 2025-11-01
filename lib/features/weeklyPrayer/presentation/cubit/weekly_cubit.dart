import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/weeklyPrayer/data/repository/weekly_repository.dart';

part 'weekly_state.dart';

class WeeklyCubit extends Cubit<WeeklyState> {
  WeeklyCubit() : super(WeeklyInitial());

  Future<void> fetchWeeklyPrayerTimes({
    Map<String, String>? savedLocation,
  }) async {
    emit(WeeklyLoading());

    try {
      final WeeklyRepository weeklyRepository = WeeklyRepository();
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
