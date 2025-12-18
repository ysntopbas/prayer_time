import 'package:flutter/material.dart';
import 'package:prayer_time/l10n/app_localizations.dart';

enum AppSound {
  flute,
  flute2,
  bicyclering,
  wolfhowling,
  cleartone,
  fire,
  flute3,
  harp,
  hawk,
  positivesound,
  ticktockalarm,
  tictockalarm2,
  wolfpackhowling;

  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (this) {
      case AppSound.flute:
        return l10n.soundFlute;
      case AppSound.bicyclering:
        return l10n.soundBicycleRing;
      case AppSound.flute2:
        return l10n.soundFlute2;
      case AppSound.wolfhowling:
        return l10n.soundWolfHowling;
      case AppSound.cleartone:
        return l10n.soundClearTone;
      case AppSound.fire:
        return l10n.soundFire;
      case AppSound.flute3:
        return l10n.soundFlute3;
      case AppSound.harp:
        return l10n.soundHarp;
      case AppSound.hawk:
        return l10n.soundHawk;
      case AppSound.positivesound:
        return l10n.soundPositiveSound;
      case AppSound.ticktockalarm:
        return l10n.soundTickTockAlarm;
      case AppSound.tictockalarm2:
        return l10n.soundTickTockAlarm2;
      case AppSound.wolfpackhowling:
        return l10n.soundWolfPackHowling;
    }
  }

  // Geriye dönük uyumluluk için eski label metodu (opsiyonel)
  String get label {
    switch (this) {
      case AppSound.flute:
        return 'Flute';
      case AppSound.bicyclering:
        return 'Bicycle Ring';
      case AppSound.flute2:
        return 'Flute 2';
      case AppSound.wolfhowling:
        return 'Wolf Howling';
      case AppSound.cleartone:
        return 'Clear Tone';
      case AppSound.fire:
        return 'Fire';
      case AppSound.flute3:
        return 'Flute 3';
      case AppSound.harp:
        return 'Harp';
      case AppSound.hawk:
        return 'Hawk';
      case AppSound.positivesound:
        return 'Positive Sound';
      case AppSound.ticktockalarm:
        return 'Tick Tock Alarm';
      case AppSound.tictockalarm2:
        return 'Tick Tock Alarm 2';
      case AppSound.wolfpackhowling:
        return 'Wolf Pack Howling';
    }
  }

  String get filename {
    switch (this) {
      case AppSound.flute:
        return 'flute';
      case AppSound.bicyclering:
        return 'bicyclering';
      case AppSound.flute2:
        return 'flute2';
      case AppSound.wolfhowling:
        return 'wolfhowling';
      case AppSound.cleartone:
        return 'cleartone';
      case AppSound.fire:
        return 'fire';
      case AppSound.flute3:
        return 'flute3';
      case AppSound.harp:
        return 'harp';
      case AppSound.hawk:
        return 'hawk';
      case AppSound.positivesound:
        return 'positivesound';
      case AppSound.ticktockalarm:
        return 'ticktockalarm';
      case AppSound.tictockalarm2:
        return 'tictockalarm2';
      case AppSound.wolfpackhowling:
        return 'wolfpackhowling';
    }
  }

  String get assetPath => 'sounds/$filename.wav';
}
