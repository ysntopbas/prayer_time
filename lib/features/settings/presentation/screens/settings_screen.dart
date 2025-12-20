import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time/core/constants/notification_sounds.dart';
import 'package:prayer_time/core/init/locator.dart' as di;
import 'package:prayer_time/core/services/cache_service.dart';
import 'package:prayer_time/core/services/locationServices/location_service.dart';
import 'package:prayer_time/core/services/notificationServices/instant_notification_service.dart';
import 'package:prayer_time/core/widgets/custom_app_bar.dart';
import 'package:prayer_time/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:prayer_time/features/settings/presentation/widgets/notification_switch_list_tile.dart';
import 'package:prayer_time/features/settings/presentation/widgets/slient_mode_list_tile.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10nL = AppLocalizations.of(context)!;
    final appTheme = Theme.of(context);

    return Scaffold(
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
          Icon(Icons.settings, size: 100, color: appTheme.colorScheme.primary),
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
                    : Icon(Icons.refresh, color: appTheme.colorScheme.primary),
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
          BlocSelector<SettingsCubit, SettingsState, String>(
            selector: (state) => state.notificationSound,

            builder: (context, notificationSound) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: DropdownMenu<AppSound>(
                  leadingIcon: Icon(
                    Icons.music_note,
                    color: appTheme.colorScheme.primary,
                  ),
                  initialSelection: AppSound.values.firstWhere(
                    (sound) => sound.filename == notificationSound,
                    orElse: () => AppSound.flute,
                  ),
                  width: double.infinity,
                  dropdownMenuEntries: AppSound.values
                      .map<DropdownMenuEntry<AppSound>>((AppSound sound) {
                        return DropdownMenuEntry(
                          value: sound,
                          label: sound.getLocalizedLabel(context),
                        );
                      })
                      .toList(),
                  onSelected: (AppSound? sound) {
                    if (sound != null) {
                      context.read<SettingsCubit>().changeNotificationSound(
                        sound.filename,
                      );
                    }
                  },
                ),
              );
            },
          ),
          // Test Notification butonu için bu kodu kullanın:
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                // Güncel sesi async işlemlerden ÖNCE al
                final currentSound = context
                    .read<SettingsCubit>()
                    .state
                    .notificationSound;

                try {
                  // Önce önceki test bildirimini iptal et
                  await InstantNotificationService().cancelNotification(999);

                  // Kısa bekleme
                  await Future.delayed(const Duration(milliseconds: 300));

                  log('🎵 Testing notification with sound: $currentSound');

                  // Her test için benzersiz channel ID (timestamp ile)
                  final timestamp = DateTime.now().millisecondsSinceEpoch;
                  final channelId = 'test_channel_$timestamp';

                  // Test bildirimi gönder
                  await InstantNotificationService().showNotification(
                    id: 999,
                    title: 'Test Notification',
                    body: 'Sound: $currentSound',
                    channelId: channelId, // Her seferinde YENİ channel!
                    channelName: 'Test Notifications',
                    channelDescription: 'Testing notification sounds',
                  );

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('✅ Test sent with sound: $currentSound'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  log('❌ Test notification error: $e');
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Notification Sound'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),

          // Play Sound Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                final currentSoundString = context
                    .read<SettingsCubit>()
                    .state
                    .notificationSound;

                final currentSoundEnum = AppSound.values.firstWhere(
                  (e) => e.filename == currentSoundString,
                  orElse: () => AppSound.flute,
                );

                final player = AudioPlayer();
                try {
                  await player.stop();
                  await player.play(AssetSource(currentSoundEnum.assetPath));
                } catch (e) {
                  log("Hata: $e");
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10nL.playSound),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),

          Divider(color: appTheme.colorScheme.primary),

          NotificationSwitchListTile(),
          Divider(color: appTheme.colorScheme.primary),

          //İOS'da sessiz mod ayarı yok çünkü fiziksel anahtarla kontrol ediliyor
          Platform.isIOS ? const SizedBox.shrink() : SilentModeListTile(),
          Platform.isIOS
              ? const SizedBox.shrink()
              : Divider(color: appTheme.colorScheme.primary),
          ElevatedButton(
            onPressed: () async {
              try {
                await di.sl<CacheService>().clearAllCache();
              } catch (e) {
                log("Cache hatası: $e");
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10nL.cacheCleared),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              await Future.delayed(const Duration(seconds: 2));
              if (context.mounted) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              }
              await di.resetLocator();
              if (context.mounted) {
                Phoenix.rebirth(context);
              }
            },
            child: Text(l10nL.cleanCache),
          ),

          //TEST SCREEN BUTTON
          // ElevatedButton(
          //   onPressed: () {
          //     context.push('/sound-mode-change-test');
          //   },
          //   child: Text('Sound Mode Change Test Screen'),
          // ),
        ],
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
    final l10nL = AppLocalizations.of(context)!;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10nL.locationServiceDisabled),
            content: Text(l10nL.locationServiceMessage),
            actions: [
              TextButton(
                onPressed: () => navigator.pop(false),
                child: Text(l10nL.cancel, style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => navigator.pop(true),
                child: Text(l10nL.openSettings),
              ),
            ],
          ),
        ) ??
        false;
  }
}
