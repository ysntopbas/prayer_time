// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get homePageTitle => 'Ana Sayfa';

  @override
  String get settingsPageTitle => 'Ayarlar';

  @override
  String get welcomeMessage => 'Namaz Vakti Uygulamasına Hoş Geldiniz!';

  @override
  String get drawerTitle => 'Namaz Vakti ';

  @override
  String get drawerHomePageTile => 'Ana Sayfa';

  @override
  String get drawerSettingsPageTile => 'Ayarlar';
}
