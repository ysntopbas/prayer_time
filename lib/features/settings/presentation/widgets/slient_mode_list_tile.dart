import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_time/features/settings/extensions/settings_cubit_extension.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/l10n/app_localizations.dart';
import 'package:sound_mode/permission_handler.dart';

class SilentModeListTile extends StatelessWidget {
  const SilentModeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context);
    final appTheme = Theme.of(context);

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.needsPermissionDialog != current.needsPermissionDialog,
      listener: (context, state) {
        if (state.needsPermissionDialog) {
          // Dialog göster
          _showPermissionDialog(context);
          // Flag'i temizle
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
                  color: appTheme.colorScheme.primary,
                ),
                title: Text(l10nL!.silentMode),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: mainSilentModeEnabled,
                      onChanged: (value) {
                        context.read<SettingsCubit>().mainToggleSilentMode();
                      },
                    ),
                    Icon(
                      mainSilentModeEnabled
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
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
                  appTheme,
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
    ThemeData theme,
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
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
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
                title: Text(
                  prayerName,
                  style: TextStyle(color: mainEnabled ? null : Colors.grey),
                ),
                trailing: Opacity(
                  opacity: mainEnabled ? 1.0 : 0.5,
                  child: Switch(
                    value: prayerSettings.isEnabled,
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
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.beforeSilentMode,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  l10n.before,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  '${prayerSettings.minutesBefore} ${l10n.minutes}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
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
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.afterSilentMode,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  l10n.after,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${prayerSettings.minutesAfter} ${l10n.minutes}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
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
          title: Text(
            isBefore
                ? '${l10n.before} ${l10n.selectTime}'
                : '${l10n.after} ${l10n.selectTime}',
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
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
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
              child: Text(l10n.done),
            ),
          ],
        );
      },
    );
  }

  /// Kullanıcıya izin vermesi gerektiğini anlatan pencere
  void _showPermissionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.permissionRequired)),
          ],
        ),
        content: Text(l10n.silentModePermissionMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Do Not Disturb ayarlarını aç
              await PermissionHandler.openDoNotDisturbSetting();

              // Kullanıcı ayarlardan geri döndüğünde izni kontrol et
              await Future.delayed(const Duration(seconds: 1));

              if (!context.mounted) return;

              final permissionGranted =
                  await PermissionHandler.permissionsGranted;

              if (!context.mounted) return;

              if (permissionGranted == true) {
                // İzin verildi, sessiz modu aç
                context.read<SettingsCubit>().enableSilentModeAfterPermission();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.silentModePermissionGranted),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                // İzin verilmedi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.silentModePermissionRequired),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.settings),
            label: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }
}
