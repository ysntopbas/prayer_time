part of 'weekly_cubit.dart';

sealed class WeeklyState extends Equatable {
  const WeeklyState();

  @override
  List<Object> get props => [];
}

final class WeeklyInitial extends WeeklyState {}

final class WeeklyLoading extends WeeklyState {}

final class WeeklyLoaded extends WeeklyState {
  final List<PrayerTimeModel>? weeklyTimings;
  final String? cityName;

  const WeeklyLoaded({this.weeklyTimings, this.cityName});
}

final class WeeklyError extends WeeklyState {
  final String message;

  const WeeklyError(this.message);

  @override
  List<Object> get props => [message];
}
