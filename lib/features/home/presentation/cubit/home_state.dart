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

  const HomeLoaded({
    required this.prayerTimings,
    this.cityName,
    required this.nextTimings,
    this.subAdministrativeArea,
  });

  @override
  List<Object> get props => [
    prayerTimings,
    cityName ?? '',
    subAdministrativeArea ?? '',
  ];
}

final class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
