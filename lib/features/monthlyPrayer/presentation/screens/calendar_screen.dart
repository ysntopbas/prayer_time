import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/cubit/monthly_cubit.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/widgets/prayer_time_monthly_card';
import 'package:prayer_time/l10n/app_localizations.dart';

class MonthlyPrayerTimeScreen extends StatelessWidget {
  const MonthlyPrayerTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.monthlyPrayerTimePageTitle,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Center(
            child: Expanded(
              child: BlocBuilder<MonthlyCubit, MonthlyState>(
                builder: (context, state) {
                  if (state is MonthlyInitial) {
                    context.read<MonthlyCubit>().fetchMonthlyPrayerTimes();
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is MonthlyLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is MonthlyError) {
                    return Center(child: Text(state.message));
                  } else if (state is MonthlyLoaded) {
                    final monthlyTimings = state.monthlyTimings ?? [];
                    final cityName = state.cityName ?? 'Kayseri';
                    return PrayerTimeMonthlyCard(
                      cityName: cityName,
                      timings: monthlyTimings,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
