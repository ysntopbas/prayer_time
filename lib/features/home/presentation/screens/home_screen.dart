import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/widgets/custom_drawer.dart';
import 'package:prayer_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_countdown_card.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_header.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_time_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _loadPrayerTimes(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();
    final savedLocation = settingsCubit.getSavedLocation();
    context.read<HomeCubit>().fetchPrayerTimes(
      savedLocation: savedLocation,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) {
        // İlk yükleme için HomeInitial'dan geçişi izin ver
        if (previous is HomeInitial) return true;
        // Loading ve Error state'leri için izin ver
        if (current is HomeLoading || current is HomeError) return true;
        // HomeLoaded içinde sadece prayer timings değişirse rebuild et
        if (previous is HomeLoaded && current is HomeLoaded) {
          return previous.prayerTimings != current.prayerTimings ||
              previous.cityName != current.cityName ||
              previous.subAdministrativeArea != current.subAdministrativeArea;
        }
        return true;
      },
      builder: (context, homeState) {
        // İlk yükleme kontrolü - sadece bir kez çalışacak
        if (homeState is HomeInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadPrayerTimes(context);
          });
        }

        return _HomeScaffold(
          appTheme: appTheme,
          onLoadPrayerTimes: () => _loadPrayerTimes(context),
        );
      },
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  final ThemeData appTheme;
  final VoidCallback onLoadPrayerTimes;

  const _HomeScaffold({
    required this.appTheme,
    required this.onLoadPrayerTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appTheme.colorScheme.primary,
              appTheme.colorScheme.secondary,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) =>
              previous.cityName != current.cityName,
          listener: (context, state) {
            onLoadPrayerTimes();
          },
          child: BlocBuilder<HomeCubit, HomeState>(
            buildWhen: (previous, current) {
              // HomeLoaded içindeki countdown güncellemelerini ignore et
              if (previous is HomeLoaded && current is HomeLoaded) {
                return previous.prayerTimings != current.prayerTimings ||
                    previous.cityName != current.cityName ||
                    previous.subAdministrativeArea !=
                        current.subAdministrativeArea;
              }
              return true;
            },
            builder: (context, state) {
              if (state is HomeInitial || state is HomeLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: appTheme.colorScheme.onPrimary,
                  ),
                );
              } else if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: TextStyle(color: appTheme.colorScheme.onPrimary),
                      ),
                    ],
                  ),
                );
              } else if (state is HomeLoaded) {
                final prayerTimings = state.prayerTimings;
                final cityName = state.cityName ?? 'Istanbul';
                final subAdministrativeArea =
                    state.subAdministrativeArea ?? 'Fatih';

                return Column(
                  children: [
                    PrayerHeader(
                      subAdministrativeArea: subAdministrativeArea,
                      cityName: cityName,
                      scaffoldKey: null,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              BlocSelector<
                                HomeCubit,
                                HomeState,
                                Map<String, dynamic>
                              >(
                                selector: (state) {
                                  if (state is HomeLoaded) {
                                    return {
                                      'remainingTime': state.remainingTime,
                                      'nextPrayerName': state.nextPrayerName,
                                      'nextPrayerTime': state.nextPrayerTime,
                                    };
                                  }
                                  return {
                                    'remainingTime': Duration.zero,
                                    'nextPrayerName': '',
                                    'nextPrayerTime': '',
                                  };
                                },
                                builder: (context, countdownData) {
                                  return PrayerCountdownCard(
                                    remainingTime:
                                        countdownData['remainingTime']
                                            as Duration,
                                    nextPrayerName:
                                        countdownData['nextPrayerName']
                                            as String,
                                    nextPrayerTime:
                                        countdownData['nextPrayerTime']
                                            as String,
                                  );
                                },
                              ),
                              BlocSelector<HomeCubit, HomeState, String>(
                                selector: (state) {
                                  if (state is HomeLoaded) {
                                    return state.nextPrayerName;
                                  }
                                  return '';
                                },
                                builder: (context, nextPrayerName) {
                                  return PrayerTimesList(
                                    timings: prayerTimings,
                                    nextPrayerName: nextPrayerName,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
