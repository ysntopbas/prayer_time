part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final Timings nextTimings;
  final Timings prayerTimings;
  final String? cityName;
  final String? subAdministrativeArea;
  final Duration remainingTime;
  final String nextPrayerName;
  final String nextPrayerTime;

  const HomeLoaded({
    required this.prayerTimings,
    this.cityName,
    required this.nextTimings,
    this.subAdministrativeArea,
    required this.remainingTime,
    required this.nextPrayerName,
    required this.nextPrayerTime,
  });

  @override
  List<Object> get props => [
    prayerTimings,
    cityName ?? '',
    subAdministrativeArea ?? '',
    nextTimings,
    remainingTime,
    nextPrayerName,
    nextPrayerTime,
  ];
}

final class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
