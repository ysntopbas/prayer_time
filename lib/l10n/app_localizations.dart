import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @afternoonPrayer.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Prayer'**
  String get afternoonPrayer;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @compassTile.
  ///
  /// In en, this message translates to:
  /// **'Qıblah Compass'**
  String get compassTile;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkMode;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dawnPrayer.
  ///
  /// In en, this message translates to:
  /// **'Dawn Prayer'**
  String get dawnPrayer;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @dhuAlHijjah.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Hijjah'**
  String get dhuAlHijjah;

  /// No description provided for @dhuAlQiDah.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Qi\'dah'**
  String get dhuAlQiDah;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// Drawer item for home page
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get drawerHomePageTile;

  /// Drawer item for settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettingsPageTile;

  /// No description provided for @drawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get drawerTitle;

  /// Drawer item for monthlyPrayerTime page
  ///
  /// In en, this message translates to:
  /// **'Monthly Prayers Calendar'**
  String get drawermonthlyPrayerTimePageTile;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @headerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get headerTitle;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @imsak.
  ///
  /// In en, this message translates to:
  /// **'Imsak'**
  String get imsak;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @jumadaAlAwwal.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-awwal'**
  String get jumadaAlAwwal;

  /// No description provided for @jumadaAlThani.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-thani'**
  String get jumadaAlThani;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelect;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightMode;

  /// No description provided for @locationCantUpdated.
  ///
  /// In en, this message translates to:
  /// **'Failed to update location'**
  String get locationCantUpdated;

  /// No description provided for @locationNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get locationNotSpecified;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location Updated'**
  String get locationUpdated;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// The title of the monthlyPrayerTime page
  ///
  /// In en, this message translates to:
  /// **'Calendar Page'**
  String get monthlyPrayerTimePageTitle;

  /// No description provided for @muharram.
  ///
  /// In en, this message translates to:
  /// **'Muharram'**
  String get muharram;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @nightPrayer.
  ///
  /// In en, this message translates to:
  /// **'Night Prayer'**
  String get nightPrayer;

  /// No description provided for @noonMiddayPrayer.
  ///
  /// In en, this message translates to:
  /// **'Noon/Midday Prayer'**
  String get noonMiddayPrayer;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Created by atQs'**
  String get ownerName;

  /// No description provided for @prayTimeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No prayer times available'**
  String get prayTimeNotAvailable;

  /// No description provided for @prayTimes.
  ///
  /// In en, this message translates to:
  /// **'Pray Times'**
  String get prayTimes;

  /// No description provided for @rabiAlThani.
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-thani\t'**
  String get rabiAlThani;

  /// No description provided for @rabialAwwal.
  ///
  /// In en, this message translates to:
  /// **'Rabi\' al-awwal\t'**
  String get rabialAwwal;

  /// No description provided for @rajab.
  ///
  /// In en, this message translates to:
  /// **'Rajab'**
  String get rajab;

  /// No description provided for @ramadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get ramadan;

  /// No description provided for @safar.
  ///
  /// In en, this message translates to:
  /// **'Safar\t'**
  String get safar;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// The title of the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @shaban.
  ///
  /// In en, this message translates to:
  /// **'Sha\'ban'**
  String get shaban;

  /// No description provided for @shawwal.
  ///
  /// In en, this message translates to:
  /// **'Shawwal'**
  String get shawwal;

  /// No description provided for @sunRise.
  ///
  /// In en, this message translates to:
  /// **'Sun Rise '**
  String get sunRise;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @sunsetPrayer.
  ///
  /// In en, this message translates to:
  /// **'Sunset Prayer'**
  String get sunsetPrayer;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @todaysPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Prayer Times'**
  String get todaysPrayerTimes;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update my location'**
  String get updateLocation;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @weeklyPrayCalendar.
  ///
  /// In en, this message translates to:
  /// **'Weekly Prayers Calendar'**
  String get weeklyPrayCalendar;

  /// No description provided for @weeklyPrayerTimePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Prayer Times'**
  String get weeklyPrayerTimePageTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
