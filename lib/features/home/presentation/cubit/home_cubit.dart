import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/home/data/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> fetchPrayerTimes() async {
    emit(HomeLoading());

    try {
      final HomeRepository homeRepository = HomeRepository();
      final prayerTimes = await homeRepository.getPrayerTimes();
      final nextPrayerTimes = await homeRepository.getNextPrayerTimes();
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
