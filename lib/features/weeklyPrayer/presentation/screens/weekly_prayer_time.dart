import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/features/weeklyPrayer/presentation/cubit/weekly_cubit.dart';
import 'package:prayer_time/features/weeklyPrayer/presentation/widgets/weekly_prayer_day_card.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class WeeklyPrayerTimeScreen extends StatefulWidget {
  const WeeklyPrayerTimeScreen({super.key});

  @override
  State<WeeklyPrayerTimeScreen> createState() => _WeeklyPrayerTimeScreenState();
}

class _WeeklyPrayerTimeScreenState extends State<WeeklyPrayerTimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyPrayerTimes();
    });
  }

  void _loadWeeklyPrayerTimes() {
    final settingsCubit = context.read<SettingsCubit>();
    final savedLocation = settingsCubit.getSavedLocation();
    context.read<WeeklyCubit>().fetchWeeklyPrayerTimes(
      savedLocation: savedLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: CustomAppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: const Icon(Icons.mosque, color: Colors.white, size: 28),
          ),
        ],
        title: l10nL.weeklyPrayerTimePageTitle,
        leading: const BackButton(),
      ),
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.cityName != current.cityName,
        listener: (context, state) {
          // Konum güncellendiğinde namaz vakitlerini yeniden yükle
          _loadWeeklyPrayerTimes();
        },
        child: BlocBuilder<WeeklyCubit, WeeklyState>(
          builder: (context, state) {
            if (state is WeeklyInitial || state is WeeklyLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WeeklyError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadWeeklyPrayerTimes,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            } else if (state is WeeklyLoaded) {
              final weeklyTimings = state.weeklyTimings ?? [];
              final cityName = state.cityName ?? 'Kayseri';

              if (weeklyTimings.isEmpty) {
                return Center(child: Text(l10nL.prayTimeNotAvailable));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: weeklyTimings.length,
                itemBuilder: (context, index) {
                  final prayerTime = weeklyTimings[index];
                  return WeeklyPrayerDayCard(
                    prayerTime: prayerTime,
                    cityName: cityName,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
