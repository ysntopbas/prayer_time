import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/cubit/monthly_cubit.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/widgets/monthly_prayer_day_card.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class MonthlyPrayerTimeScreen extends StatefulWidget {
  const MonthlyPrayerTimeScreen({super.key});

  @override
  State<MonthlyPrayerTimeScreen> createState() =>
      _MonthlyPrayerTimeScreenState();
}

class _MonthlyPrayerTimeScreenState extends State<MonthlyPrayerTimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthlyPrayerTimes();
    });
  }

  void _loadMonthlyPrayerTimes() {
    final settingsCubit = context.read<SettingsCubit>();
    final savedLocation = settingsCubit.getSavedLocation();
    context.read<MonthlyCubit>().fetchMonthlyPrayerTimes(
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
        title: l10nL.monthlyPrayerTimePageTitle,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) =>
              previous.cityName != current.cityName,
          listener: (context, state) {
            _loadMonthlyPrayerTimes();
          },
          child: BlocBuilder<MonthlyCubit, MonthlyState>(
            builder: (context, state) {
              if (state is MonthlyInitial || state is MonthlyLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MonthlyError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMonthlyPrayerTimes,
                        child: Text(l10nL.tryAgain),
                      ),
                    ],
                  ),
                );
              } else if (state is MonthlyLoaded) {
                final monthlyTimings = state.monthlyTimings ?? [];
                final cityName = state.cityName ?? 'Istanbul';

                if (monthlyTimings.isEmpty) {
                  return Center(child: Text(l10nL.prayTimeNotAvailable));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: monthlyTimings.length,
                  itemBuilder: (context, index) {
                    final prayerTime = monthlyTimings[index];
                    return MonthlyPrayerDayCard(
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
      ),
    );
  }
}
