import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/monthlyPrayer/data/repository/monthly_repository.dart';

part 'monthly_state.dart';

class MonthlyCubit extends Cubit<MonthlyState> {
  MonthlyCubit() : super(MonthlyInitial());

  Future<void> fetchMonthlyPrayerTimes({
    Map<String, String>? savedLocation,
  }) async {
    emit(MonthlyLoading());

    try {
      final MonthlyRepository monthlyRepository = MonthlyRepository();
      final monthlyTimings = await monthlyRepository.getMonthlyPrayerTimes(
        savedLocation: savedLocation,
      );
      final cityName = monthlyRepository.cityName;
      emit(MonthlyLoaded(cityName, monthlyTimings));
    } catch (e) {
      emit(MonthlyError(e.toString()));
    }
  }
}
