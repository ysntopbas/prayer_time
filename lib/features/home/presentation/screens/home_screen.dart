import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/core/widgets/custom_drawer.dart';
import 'package:prayer_time/features/home/presentation/cubit/home_cubit.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_countdown_card.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_header.dart';
import 'package:prayer_time/features/home/presentation/widgets/prayer_time_list.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

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
        if (previous is HomeInitial) return true;
        if (current is HomeLoading || current is HomeError) return true;
        if (previous is HomeLoaded && current is HomeLoaded) {
          return previous.prayerTimings != current.prayerTimings ||
              previous.cityName != current.cityName ||
              previous.subAdministrativeArea != current.subAdministrativeArea;
        }
        return true;
      },
      builder: (context, homeState) {
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

  String _getTranslatedPrayerName(BuildContext context, String prayerName) {
    final l10n = AppLocalizations.of(context)!;

    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return l10n.fajr;
      case 'sunrise':
        return l10n.sunrise;
      case 'dhuhr':
        return l10n.dhuhr;
      case 'asr':
        return l10n.asr;
      case 'maghrib':
        return l10n.maghrib;
      case 'isha':
        return l10n.isha;
      default:
        return prayerName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.prayerBackgroundColor,
      drawer: const CustomDrawer(),
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.cityName != current.cityName,
        listener: (context, state) {
          onLoadPrayerTimes();
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) {
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
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.loadingColor),
              );
            } else if (state is HomeError) {
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
                      onPressed: onLoadPrayerTimes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorButtonColor,
                      ),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              );
            } else if (state is HomeLoaded) {
              final prayerTimings = state.prayerTimings;
              final cityName = state.cityName ?? 'Istanbul';
              final subAdministrativeArea =
                  state.subAdministrativeArea ?? 'Fatih';

              return SafeArea(
                child: Stack(
                  children: [
                    // Background mosque silhouette
                    Positioned.fill(
                      child: CustomPaint(painter: MosqueSilhouettePainter()),
                    ),
                    // Main content
                    Column(
                      children: [
                        // Header
                        PrayerHeader(
                          subAdministrativeArea: subAdministrativeArea,
                          cityName: cityName,
                        ),
                        // Countdown Card
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
                            final translatedPrayerName =
                                _getTranslatedPrayerName(
                                  context,
                                  countdownData['nextPrayerName'] as String,
                                );

                            return PrayerCountdownCard(
                              remainingTime:
                                  countdownData['remainingTime'] as Duration,
                              nextPrayerName: translatedPrayerName,
                              nextPrayerTime:
                                  countdownData['nextPrayerTime'] as String,
                            );
                          },
                        ),
                        // Prayer Times List
                        Expanded(
                          child: BlocSelector<HomeCubit, HomeState, String>(
                            selector: (state) {
                              if (state is HomeLoaded) {
                                return state.nextPrayerName;
                              }
                              return '';
                            },
                            builder: (context, nextPrayerName) {
                              final translatedPrayerName =
                                  _getTranslatedPrayerName(
                                    context,
                                    nextPrayerName,
                                  );
                              return PrayerTimesList(
                                timings: prayerTimings,
                                nextPrayerName: translatedPrayerName,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// Mosque silhouette painter for background
class MosqueSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.mosqueBackgroundColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Simple minaret shape
    final centerX = size.width / 2;
    final bottomY = size.height * 0.85;

    // Left minaret
    path.moveTo(centerX - 30, bottomY);
    path.lineTo(centerX - 30, size.height * 0.3);
    path.lineTo(centerX - 20, size.height * 0.25);
    path.lineTo(centerX - 10, size.height * 0.3);
    path.lineTo(centerX - 10, bottomY);
    path.close();

    // Right minaret
    path.moveTo(centerX + 10, bottomY);
    path.lineTo(centerX + 10, size.height * 0.3);
    path.lineTo(centerX + 20, size.height * 0.25);
    path.lineTo(centerX + 30, size.height * 0.3);
    path.lineTo(centerX + 30, bottomY);
    path.close();

    // Dome
    path.moveTo(centerX - 60, bottomY);
    path.quadraticBezierTo(centerX, size.height * 0.4, centerX + 60, bottomY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
