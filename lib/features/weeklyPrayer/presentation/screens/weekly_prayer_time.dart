import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/widgets/custom_app_bar.dart';

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
      body: BlocBuilder<WeeklyCubit, WeeklyState>(
        builder: (context, state) {
          if (state is WeeklyInitial) {
            context.read<WeeklyCubit>().fetchWeeklyPrayerTimes();
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeeklyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeeklyError) {
            return Center(child: Text(state.message));
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
    );
  }
}
