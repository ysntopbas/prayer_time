import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/calendar/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/home/data/repository/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> fetchPrayerTimes() async {
    emit(HomeLoading());

    try {
      final prayerTimes = await HomeRepository().getPrayerTimes();
      emit(HomeLoaded(prayerTimings: prayerTimes));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
