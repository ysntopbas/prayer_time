import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/core/domain/models/prayer_time_model.dart';
import 'package:prayer_time/features/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/monthlyPrayer/presentation/cubit/monthly_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class MonthlyPrayerTimeScreen extends StatefulWidget {
  const MonthlyPrayerTimeScreen({super.key});

  @override
  State<MonthlyPrayerTimeScreen> createState() =>
      _MonthlyPrayerTimeScreenState();
}

class _MonthlyPrayerTimeScreenState extends State<MonthlyPrayerTimeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: CustomAppBar(
        title: l10nL.monthlyPrayerTimePageTitle,
        leading: const BackButton(),
      ),
      body: BlocBuilder<MonthlyCubit, MonthlyState>(
        builder: (context, state) {
          if (state is MonthlyInitial) {
            context.read<MonthlyCubit>().fetchMonthlyPrayerTimes();
            return const Center(child: CircularProgressIndicator());
          } else if (state is MonthlyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MonthlyError) {
            return Center(child: Text(state.message));
          } else if (state is MonthlyLoaded) {
            final monthlyTimings = state.monthlyTimings ?? [];
            final cityName = state.cityName ?? 'Kayseri';

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
    );
  }
}

class MonthlyPrayerDayCard extends StatelessWidget {
  final PrayerTimeModel prayerTime;
  final String cityName;

  const MonthlyPrayerDayCard({
    super.key,
    required this.prayerTime,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final gregorian = prayerTime.date?.gregorian;
    final hijri = prayerTime.date?.hijri;
    final timings = prayerTime.timings;
    final l10nL = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Day Number
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      gregorian?.day ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C6BC0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Date Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gregorian?.day ?? ''} ${gregorian?.month?.en ?? ''} ${gregorian?.year ?? ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        gregorian?.weekday?.en ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        '${hijri?.hijriday ?? ''} ${hijri?.hijrimonth?.hijrien ?? ''} ${hijri?.hijriyear ?? ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // City Name
                Text(
                  cityName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Prayer Times Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _PrayerTimeItem(
                        title: l10nL.fajr,
                        time: timings?.fajr ?? '',
                        icon: Icons.nightlight_round,
                        color: const Color(0xFF5C6BC0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PrayerTimeItem(
                        title: l10nL.sunrise,
                        time: timings?.sunrise ?? '',
                        icon: Icons.wb_sunny,
                        color: const Color(0xFFFFA726),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PrayerTimeItem(
                        title: l10nL.dhuhr,
                        time: timings?.dhuhr ?? '',
                        icon: Icons.wb_sunny_outlined,
                        color: const Color(0xFFFF7043),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PrayerTimeItem(
                        title: l10nL.asr,
                        time: timings?.asr ?? '',
                        icon: Icons.wb_twilight,
                        color: const Color(0xFFFFB74D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PrayerTimeItem(
                        title: l10nL.maghrib,
                        time: timings?.maghrib ?? '',
                        icon: Icons.wb_sunny,
                        color: const Color(0xFFEF5350),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PrayerTimeItem(
                        title: l10nL.isha,
                        time: timings?.isha ?? '',
                        icon: Icons.nightlight,
                        color: const Color(0xFF7E57C2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _PrayerTimeItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
