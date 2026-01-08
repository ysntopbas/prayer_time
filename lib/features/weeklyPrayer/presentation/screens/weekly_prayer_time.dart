import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/features/weeklyPrayer/presentation/cubit/weekly_cubit.dart';
import 'package:prayer_time/features/weeklyPrayer/presentation/widgets/weekly_prayer_day_card.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class WeeklyPrayerTimeScreen extends StatefulWidget {
  const WeeklyPrayerTimeScreen({super.key});

  @override
  State<WeeklyPrayerTimeScreen> createState() => _WeeklyPrayerTimeScreenState();
}

class _WeeklyPrayerTimeScreenState extends State<WeeklyPrayerTimeScreen> {
  late ScrollController _scrollController;
  int? _todayIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyPrayerTimes();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadWeeklyPrayerTimes() {
    final settingsCubit = context.read<SettingsCubit>();
    final savedLocation = settingsCubit.getSavedLocation();
    context.read<WeeklyCubit>().fetchWeeklyPrayerTimes(
      savedLocation: savedLocation,
    );
  }

  void _scrollToToday() {
    if (_todayIndex != null && _scrollController.hasClients) {
      final itemHeight = 140.0;
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
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getAppBarColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
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
                  l10n.weeklyPrayerTimePageTitle,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppTheme.textWhite70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$cityName${subArea.isNotEmpty ? ', $subArea' : ''}',
                      style: const TextStyle(
                        color: AppTheme.textWhite70,
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
            icon: const Icon(Icons.calendar_today, color: AppTheme.textWhite),
            onPressed: _scrollToToday,
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) =>
              previous.cityName != current.cityName,
          listener: (context, state) {
            _loadWeeklyPrayerTimes();
          },
          child: Column(
            children: [
              // Week Header
              _buildWeekHeader(now, languageCode, l10n),
              // Column Headers
              _buildColumnHeaders(l10n),
              // Prayer Times List
              Expanded(
                child: BlocBuilder<WeeklyCubit, WeeklyState>(
                  builder: (context, state) {
                    if (state is WeeklyInitial || state is WeeklyLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.loadingColor,
                        ),
                      );
                    } else if (state is WeeklyError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.message,
                              style: const TextStyle(color: AppTheme.textWhite70),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadWeeklyPrayerTimes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorButtonColor,
                              ),
                              child: Text(l10n.tryAgain),
                            ),
                          ],
                        ),
                      );
                    } else if (state is WeeklyLoaded) {
                      final weeklyTimings = state.weeklyTimings ?? [];

                      if (weeklyTimings.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.prayTimeNotAvailable,
                            style: const TextStyle(color: AppTheme.textWhite70),
                          ),
                        );
                      }

                      // Find today's index
                      _todayIndex = weeklyTimings.indexWhere((timing) {
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

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: weeklyTimings.length,
                        itemBuilder: (context, index) {
                          final timing = weeklyTimings[index];
                          final isToday = index == _todayIndex;
                          final isFriday = _isFriday(
                            timing.date?.gregorian?.date,
                          );

                          return WeeklyPrayerDayCard(
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

  Widget _buildWeekHeader(
    DateTime now,
    String languageCode,
    AppLocalizations l10n,
  ) {
    final weekEnd = now.add(const Duration(days: 6));
    final startDate = DateFormat('d MMM', languageCode).format(now);
    final endDate = DateFormat('d MMM yyyy', languageCode).format(weekEnd);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            '$startDate - $endDate',
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.weeklyPrayerTimePageTitle.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
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
          bottom: BorderSide(color: AppTheme.getDividerColor(context)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _headerText(l10n.fajr),
                _headerText(l10n.sunrise),
                _headerText(l10n.dhuhr),
                _headerText(l10n.asr),
                _headerText(l10n.maghrib),
                _headerText(l10n.isha),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return SizedBox(
      width: 45,
      child: Text(
        text.length > 4 ? text.substring(0, 4) : text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.getSecondaryTextColor(context),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
