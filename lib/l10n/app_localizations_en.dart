// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homePageTitle => 'Home Page';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get welcomeMessage => 'Welcome to the Prayer Time App!';

  @override
  String get drawerTitle => 'Prayer Time ';

  @override
  String get drawerHomePageTile => 'Home Page';

  @override
  String get drawerSettingsPageTile => 'Settings';
}
