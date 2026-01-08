import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  late ScrollController _scrollController;
  int? _todayIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthlyPrayerTimes();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMonthlyPrayerTimes() {
    final settingsCubit = context.read<SettingsCubit>();
    final savedLocation = settingsCubit.getSavedLocation();
    context.read<MonthlyCubit>().fetchMonthlyPrayerTimes(
      savedLocation: savedLocation,
    );
  }

  void _scrollToToday() {
    if (_todayIndex != null && _scrollController.hasClients) {
      final itemHeight = 140.0; // Approximate card height
      final offset = (_todayIndex! * itemHeight).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFF1A2E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2E1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final cityName = settingsState.cityName ?? 'Istanbul';
            final subArea = settingsState.subAdministrativeArea ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.monthlyPrayerTimePageTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$cityName${subArea.isNotEmpty ? ', $subArea' : ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _scrollToToday,
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) =>
              previous.cityName != current.cityName,
          listener: (context, state) {
            _loadMonthlyPrayerTimes();
          },
          child: Column(
            children: [
              // Month Header
              _buildMonthHeader(now, languageCode, l10n),
              // Column Headers
              _buildColumnHeaders(l10n),
              // Prayer Times List
              Expanded(
                child: BlocBuilder<MonthlyCubit, MonthlyState>(
                  builder: (context, state) {
                    if (state is MonthlyInitial || state is MonthlyLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                      );
                    } else if (state is MonthlyError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMonthlyPrayerTimes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                              child: Text(l10n.tryAgain),
                            ),
                          ],
                        ),
                      );
                    } else if (state is MonthlyLoaded) {
                      final monthlyTimings = state.monthlyTimings ?? [];

                      if (monthlyTimings.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.prayTimeNotAvailable,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      // Find today's index
                      _todayIndex = monthlyTimings.indexWhere((timing) {
                        final date = timing.date?.gregorian?.date;
                        if (date == null) return false;
                        try {
                          final parts = date.split('-');
                          if (parts.length == 3) {
                            final day = int.parse(parts[0]);
                            final month = int.parse(parts[1]);
                            final year = int.parse(parts[2]);
                            return day == now.day &&
                                month == now.month &&
                                year == now.year;
                          }
                        } catch (_) {}
                        return false;
                      });

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_todayIndex != null && _todayIndex! >= 0) {
                          _scrollToToday();
                        }
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: monthlyTimings.length,
                        itemBuilder: (context, index) {
                          final timing = monthlyTimings[index];
                          final isToday = index == _todayIndex;
                          final isFriday = _isFriday(
                            timing.date?.gregorian?.date,
                          );

                          return MonthlyPrayerDayCard(
                            prayerTime: timing,
                            isToday: isToday,
                            isFriday: isFriday,
                            languageCode: languageCode,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFriday(String? dateStr) {
    if (dateStr == null) return false;
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        return date.weekday == DateTime.friday;
      }
    } catch (_) {}
    return false;
  }

  Widget _buildMonthHeader(
    DateTime now,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final monthName = DateFormat('MMMM yyyy', languageCode).format(now);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            monthName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          BlocBuilder<MonthlyCubit, MonthlyState>(
            builder: (context, state) {
              if (state is MonthlyLoaded) {
                final timings = state.monthlyTimings;
                if (timings != null && timings.isNotEmpty) {
                  // İlk ve son günün hicri aylarını al
                  final firstHijriMonth =
                      timings.first.date?.hijri?.hijrimonth?.hijrien ?? '';
                  final lastHijriMonth =
                      timings.last.date?.hijri?.hijrimonth?.hijrien ?? '';
                  final hijriYear = timings.first.date?.hijri?.hijriyear ?? '';

                  String hijriText;
                  if (firstHijriMonth == lastHijriMonth) {
                    hijriText = '$firstHijriMonth $hijriYear';
                  } else {
                    hijriText = '$firstHijriMonth - $lastHijriMonth $hijriYear';
                  }

                  if (hijriText.trim().isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        hijriText.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _headerText(l10n.fajr),
          _headerText(l10n.sunrise),
          _headerText(l10n.dhuhr),
          _headerText(l10n.asr),
          _headerText(l10n.maghrib),
          _headerText(l10n.isha),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
