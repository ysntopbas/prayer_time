import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/core/services/locationServices/location_service.dart';
import 'package:prayer_time/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/features/settings/presentation/widgets/battery_optimization_dialog.dart';
import 'package:prayer_time/features/settings/presentation/widgets/notification_switch_list_tile.dart';
import 'package:prayer_time/features/settings/presentation/widgets/slient_mode_list_tile.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;
    final appTheme = Theme.of(context);

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current.shouldShowBatteryDialog && !previous.shouldShowBatteryDialog,
      listener: (context, state) {
        if (state.shouldShowBatteryDialog) {
          _showBatteryOptimizationDialog(context);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10nL.settingsPageTitle,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: const Icon(Icons.mosque, color: Colors.white, size: 28),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Icon(
              Icons.settings,
              size: 100,
              color: appTheme.colorScheme.primary,
            ),
            Divider(
              height: 30,
              thickness: 5,
              color: appTheme.colorScheme.primary,
            ),
            // Tema
            BlocSelector<SettingsCubit, SettingsState, bool>(
              selector: (state) => state.isDarkMode,
              builder: (context, isDarkMode) {
                return SwitchListTile(
                  value: isDarkMode,
                  inactiveThumbColor: appTheme.colorScheme.primary,
                  onChanged: (bool value) {
                    context.read<SettingsCubit>().toggleDarkMode();
                  },
                  secondary: Icon(
                    Icons.brightness_6,
                    color: appTheme.colorScheme.primary,
                  ),
                  title: Text(l10nL.darkMode),
                );
              },
            ),
            Divider(color: appTheme.colorScheme.primary),

            // Dil Seçeneği
            BlocSelector<SettingsCubit, SettingsState, String>(
              selector: (state) => state.languageCode,
              builder: (context, languageCode) {
                return ListTile(
                  leading: Icon(
                    Icons.language,
                    color: appTheme.colorScheme.primary,
                  ),
                  title: Text(l10nL.language),
                  subtitle: Text(
                    languageCode == 'en'
                        ? 'English'
                        : languageCode == 'tr'
                        ? 'Türkçe'
                        : 'Unknown',
                  ),
                  onTap: () {
                    _showLanguageSelectionDialog(context);
                  },
                );
              },
            ),
            Divider(color: appTheme.colorScheme.primary),

            // Konum Güncelleme
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: appTheme.colorScheme.primary,
                  ),
                  title: Text(l10nL.updateLocation),
                  subtitle: state.cityName != null
                      ? Text('${state.cityName}, ${state.countryName}')
                      : Text(l10nL.setFirstLocation),
                  trailing: state.isLocationLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.refresh,
                          color: appTheme.colorScheme.primary,
                        ),
                  onTap: state.isLocationLoading
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final settingsCubit = context.read<SettingsCubit>();

                          final locationService = LocationService();
                          final isServiceEnabled = await locationService
                              .isLocationServiceEnabled();

                          if (!isServiceEnabled) {
                            if (!context.mounted) return;

                            final shouldOpenSettings =
                                await _showLocationServiceDialog(context);

                            if (shouldOpenSettings) {
                              await Geolocator.openLocationSettings();
                              await Future.delayed(
                                const Duration(milliseconds: 1500),
                              );

                              final isNowEnabled = await locationService
                                  .isLocationServiceEnabled();
                              if (!isNowEnabled) {
                                if (context.mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(l10nL.locationCantUpdated),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }
                            } else {
                              return;
                            }
                          }

                          try {
                            await settingsCubit.updateLocation();
                            if (context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(l10nL.locationUpdated)),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10nL.locationCantUpdated),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                );
              },
            ),
            Divider(color: appTheme.colorScheme.primary),
            NotificationSwitchListTile(),
            Divider(color: appTheme.colorScheme.primary),
            SilentModeListTile(),
            Divider(color: appTheme.colorScheme.primary),
            ElevatedButton(
              onPressed: () {
                FlutterBackgroundService().invoke('setAsForeground');
              },
              child: Text("Foreground Service Test"),
            ),
            ElevatedButton(
              onPressed: () {
                FlutterBackgroundService().invoke('setAsBackground');
              },
              child: Text("Background Service Test"),
            ),
            ElevatedButton(
              onPressed: () async {
                final service = FlutterBackgroundService();
                final isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke('stopService');
                  log('Service Stopped');
                } else {
                  service.startService();
                  log('Service Started');
                }
              },
              child: Text("Start/Stop Service Test"),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatteryOptimizationDialog(BuildContext context) {
    final navigator = Navigator.of(context);
    final settingsCubit = context.read<SettingsCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BatteryOptimizationDialog(
        onConfirm: () async {
          navigator.pop();

          await settingsCubit.requestBatteryPermission();
          await settingsCubit.markBatteryDialogShown();
          settingsCubit.clearBatteryDialogFlag();
        },
        onCancel: () async {
          navigator.pop();

          await settingsCubit.markBatteryDialogShown();
          settingsCubit.clearBatteryDialogFlag();
        },
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10nL.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  context.read<SettingsCubit>().changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Türkçe'),
                onTap: () {
                  context.read<SettingsCubit>().changeLanguage('tr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showLocationServiceDialog(BuildContext context) async {
    final navigator = Navigator.of(context);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Konum Servisi Kapalı"),
            content: const Text(
              "Konumunuzu güncellemek için cihazınızın GPS'ini açmanız gerekmektedir.",
            ),
            actions: [
              TextButton(
                onPressed: () => navigator.pop(false),
                child: const Text(
                  "Vazgeç",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => navigator.pop(true),
                child: const Text("Ayarları Aç"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
