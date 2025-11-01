import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/core/widgets/custom_drawer.dart';
import 'package:prayer_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_countdown_card.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_header.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_time_list.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final appTheme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(),
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
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial) {
              context.read<HomeCubit>().fetchPrayerTimes();
              return const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              );
            } else if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              );
            } else if (state is HomeError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            } else if (state is HomeLoaded) {
              final prayerTimings = state.prayerTimings;
              final cityName = state.cityName ?? 'Kayseri';
              final nextTimings = state.nextTimings;

              // Bir sonraki namaz adını bul
              final now = DateTime.now();
              String nextPrayerName = _getNextPrayerName(
                nextTimings,
                now,
                context,
              );

              return Column(
                children: [
                  PrayerHeader(cityName: cityName, scaffoldKey: scaffoldKey),
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
                            PrayerCountdownCard(nextTimings: nextTimings),
                            PrayerTimesList(
                              timings: prayerTimings,
                              nextPrayerName: nextPrayerName,
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
    );
  }

  String _getNextPrayerName(
    Timings timings,
    DateTime now,
    BuildContext context,
  ) {
    final l10nL = AppLocalizations.of(context)!;
    final currentHour = now.hour;
    final currentMinute = now.minute;

    bool hasPassed(String? timeStr) {
      if (timeStr == null) return true;
      try {
        final cleanTime = timeStr.split('(').first.trim();
        final parts = cleanTime.split(':');

        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          if (currentHour > hour) return true;
          if (currentHour == hour && currentMinute >= minute) return true;
        }
      } catch (e) {
        return false;
      }
      return false;
    }

    if (timings.fajr != null && !hasPassed(timings.fajr)) {
      return l10nL.fajr;
    }
    if (timings.sunrise != null && !hasPassed(timings.sunrise)) {
      return l10nL.sunrise;
    }
    if (timings.dhuhr != null && !hasPassed(timings.dhuhr)) {
      return l10nL.dhuhr;
    }
    if (timings.asr != null && !hasPassed(timings.asr)) {
      return l10nL.asr;
    }
    if (timings.maghrib != null && !hasPassed(timings.maghrib)) {
      return l10nL.maghrib;
    }
    if (timings.isha != null && !hasPassed(timings.isha)) {
      return l10nL.isha;
    }

    return l10nL.fajr;
  }
}
