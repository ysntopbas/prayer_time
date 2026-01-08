import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/core/theme/app_theme.dart';
import 'package:prayer_time/features/settings/extensions/settings_cubit_extension.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';
import 'package:sound_mode/permission_handler.dart';

class SilentModeListTile extends StatelessWidget {
  const SilentModeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context);

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.needsPermissionDialog != current.needsPermissionDialog,
      listener: (context, state) {
        if (state.needsPermissionDialog) {
          _showPermissionDialog(context);
          context.read<SettingsCubit>().clearPermissionDialogFlag();
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final mainSilentModeEnabled = state.mainSilentModeEnabled;

          return Column(
            children: [
              // Ana Switch
              ListTile(
                leading: Icon(
                  Icons.volume_off,
                  color: AppTheme.primaryGreen,
                ),
                title: Text(
                  l10nL!.silentMode,
                  style: const TextStyle(color: AppTheme.textWhite),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: mainSilentModeEnabled,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: (value) {
                        context.read<SettingsCubit>().mainToggleSilentMode();
                      },
                    ),
                    Icon(
                      mainSilentModeEnabled
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppTheme.textWhite70,
                    ),
                  ],
                ),
              ),

              // Alt Ayarlar
              if (mainSilentModeEnabled)
                _buildPrayerSilentModeSettings(
                  context,
                  state,
                  mainSilentModeEnabled,
                  l10nL,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrayerSilentModeSettings(
    BuildContext context,
    SettingsState state,
    bool mainEnabled,
    AppLocalizations l10n,
  ) {
    final prayers = {
      PrayerType.fajr: (l10n.fajr, state.silentModeDuringPraysSettings.fajr),
      PrayerType.sunrise: (
        l10n.sunrise,
        state.silentModeDuringPraysSettings.sunrise,
      ),
      PrayerType.dhuhr: (l10n.dhuhr, state.silentModeDuringPraysSettings.dhuhr),
      PrayerType.asr: (l10n.asr, state.silentModeDuringPraysSettings.asr),
      PrayerType.maghrib: (
        l10n.maghrib,
        state.silentModeDuringPraysSettings.maghrib,
      ),
      PrayerType.isha: (l10n.isha, state.silentModeDuringPraysSettings.isha),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.chipBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: prayers.entries.map((entry) {
          final prayerType = entry.key;
          final prayerName = entry.value.$1;
          final prayerSettings = entry.value.$2;

          return Column(
            children: [
              // Ana ListTile (Namaz adı + Switch)
              ListTile(
                leading: Icon(
                  Icons.volume_off,
                  color: prayerSettings.isEnabled && mainEnabled
                      ? AppTheme.primaryGreen
                      : AppTheme.textWhite40,
                ),
                title: Text(
                  prayerName,
                  style: TextStyle(
                    color: mainEnabled ? AppTheme.textWhite : AppTheme.textWhite40,
                  ),
                ),
                trailing: Opacity(
                  opacity: mainEnabled ? 1.0 : 0.5,
                  child: Switch(
                    value: prayerSettings.isEnabled,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: mainEnabled
                        ? (value) {
                            context
                                .read<SettingsCubit>()
                                .updateSilentModeSetting(
                                  prayerType: prayerType,
                                  isEnabled: value,
                                );
                          }
                        : null,
                  ),
                ),
              ),

              if (prayerSettings.isEnabled && mainEnabled)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      // Before Kartı
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _showDurationPicker(
                              context,
                              prayerType,
                              prayerSettings.minutesBefore,
                              true,
                              l10n,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.chipActiveBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.chipActiveBorderColor),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: AppTheme.primaryGreen,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.beforeSilentMode,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  l10n.before,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${prayerSettings.minutesBefore} ${l10n.minutes}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // After Kartı
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _showDurationPicker(
                              context,
                              prayerType,
                              prayerSettings.minutesAfter,
                              false,
                              l10n,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.chipActiveBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.chipActiveBorderColor),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppTheme.primaryGreen,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.afterSilentMode,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  l10n.after,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${prayerSettings.minutesAfter} ${l10n.minutes}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDurationPicker(
    BuildContext context,
    PrayerType prayerType,
    int currentMinutes,
    bool isBefore,
    AppLocalizations l10n,
  ) {
    int selectedMinutes = currentMinutes;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkGreen,
          title: Text(
            isBefore
                ? '${l10n.before} ${l10n.selectTime}'
                : '${l10n.after} ${l10n.selectTime}',
            style: const TextStyle(color: AppTheme.textWhite),
          ),
          content: SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: (currentMinutes ~/ 5).clamp(1, 24) - 1,
              ),
              itemExtent: 50,
              onSelectedItemChanged: (index) {
                selectedMinutes = (index + 1) * 5;
              },
              children: List<Widget>.generate(24, (index) {
                final minutes = (index + 1) * 5;
                return Center(
                  child: Text(
                    '$minutes ${l10n.minutes}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppTheme.textWhite,
                    ),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: AppTheme.textWhite60),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().updateSilentModeSetting(
                  prayerType: prayerType,
                  minutesBefore: isBefore ? selectedMinutes : null,
                  minutesAfter: !isBefore ? selectedMinutes : null,
                );
                Navigator.pop(context);
              },
              child: Text(
                l10n.done,
                style: const TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkGreen,
        title: Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.permissionRequired,
                style: const TextStyle(color: AppTheme.textWhite),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.silentModePermissionMessage,
          style: TextStyle(color: AppTheme.textWhite70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppTheme.textWhite60),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);

              await PermissionHandler.openDoNotDisturbSetting();

              await Future.delayed(const Duration(seconds: 1));

              if (!context.mounted) return;

              final permissionGranted =
                  await PermissionHandler.permissionsGranted;

              if (!context.mounted) return;

              if (permissionGranted == true) {
                context.read<SettingsCubit>().enableSilentModeAfterPermission();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.silentModePermissionGranted),
                    backgroundColor: AppTheme.primaryGreen,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.silentModePermissionRequired),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            icon: const Icon(Icons.settings, color: AppTheme.textWhite),
            label: Text(
              l10n.openSettings,
              style: const TextStyle(color: AppTheme.textWhite),
            ),
          ),
        ],
      ),
    );
  }
}
