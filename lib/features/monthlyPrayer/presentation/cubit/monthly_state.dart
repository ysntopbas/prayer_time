part of 'monthly_cubit.dart';

sealed class MonthlyState extends Equatable {
  const MonthlyState();

  @override
  List<Object> get props => [];
}

final class MonthlyInitial extends MonthlyState {}

final class MonthlyLoading extends MonthlyState {}

final class MonthlyLoaded extends MonthlyState {
  final String? cityName;
  final List<PrayerTimeModel>? monthlyTimings;

  const MonthlyLoaded(this.cityName, this.monthlyTimings);
}

final class MonthlyError extends MonthlyState {
  final String message;

  const MonthlyError(this.message);

  @override
  List<Object> get props => [message];
}
