import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // FONT AİLESİ
  // ═══════════════════════════════════════════════════════════════════════════
  static const String _fontFamily = 'Montserrat';

  // ═══════════════════════════════════════════════════════════════════════════
  // ANA RENKLER (Primary Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ana yeşil renk - Butonlar, vurgular, aktif durumlar için
  static const Color primaryGreen = Color(0xFF4CAF50);

  /// Koyu yeşil - Arka plan için
  static const Color darkGreen = Color(0xFF1A2E1A);

  /// Orta yeşil - Vurgulu arka planlar için
  static const Color mediumGreen = Color(0xFF2E7D32);

  /// Açık yeşil - Gradient ve ikincil vurgular için
  static const Color lightGreen = Color.fromARGB(255, 48, 140, 88);

  /// Turkuaz yeşil - Gradient için
  static const Color tealGreen = Color(0xFF0E978B);

  // ═══════════════════════════════════════════════════════════════════════════
  // ARKA PLAN RENKLERİ (Background Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Prayer ekranları için ana arka plan
  static const Color prayerBackgroundColor = Color(0xFF1A2E1A);

  /// Cami silüeti için arka plan rengi
  static const Color mosqueBackgroundColor = Color(0xFF2D4A2D);

  /// Light tema arka plan
  static const Color lightBackgroundColor = Colors.white;

  /// Dark tema arka plan
  static const Color darkBackgroundColor = Color(0xFF1A1A1A);

  // ═══════════════════════════════════════════════════════════════════════════
  // METİN RENKLERİ (Text Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Beyaz metin - Koyu arka planlar için
  static const Color textWhite = Colors.white;

  /// Beyaz metin %70 opacity
  static const Color textWhite70 = Colors.white70;

  /// Beyaz metin %60 opacity
  static Color textWhite60 = Colors.white.withValues(alpha: 0.6);

  /// Beyaz metin %50 opacity
  static Color textWhite50 = Colors.white.withValues(alpha: 0.5);

  /// Beyaz metin %40 opacity
  static Color textWhite40 = Colors.white.withValues(alpha: 0.4);

  /// Beyaz metin %30 opacity
  static Color textWhite30 = Colors.white.withValues(alpha: 0.3);

  /// Light tema metin rengi
  static const Color lightTextColor = Colors.black;

  /// Dark tema metin rengi
  static const Color darkTextColor = Colors.white70;

  // ═══════════════════════════════════════════════════════════════════════════
  // KART VE BORDER RENKLERİ (Card & Border Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Aktif kart arka planı (bugün, seçili)
  static Color activeCardBackground = primaryGreen.withValues(alpha: 0.15);

  /// Aktif kart arka planı koyu versiyon
  static Color activeCardBackgroundDark = mediumGreen.withValues(alpha: 0.3);

  /// Normal kart border rengi
  static Color cardBorderColor = Colors.white.withValues(alpha: 0.1);

  /// Aktif kart border rengi
  static const Color activeCardBorderColor = primaryGreen;

  /// Chip arka plan rengi
  static Color chipBackground = Colors.white.withValues(alpha: 0.05);

  /// Chip aktif arka plan rengi
  static Color chipActiveBackground = primaryGreen.withValues(alpha: 0.2);

  /// Chip border rengi
  static Color chipBorderColor = Colors.white.withValues(alpha: 0.1);

  /// Chip aktif border rengi
  static Color chipActiveBorderColor = primaryGreen.withValues(alpha: 0.5);

  // ═══════════════════════════════════════════════════════════════════════════
  // BADGE VE ETİKET RENKLERİ (Badge & Label Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Badge arka plan rengi (BUGÜN, CUMA vb.)
  static const Color badgeBackgroundColor = primaryGreen;

  /// Badge metin rengi
  static const Color badgeTextColor = Colors.white;

  /// Countdown badge arka planı
  static Color countdownBadgeBackground = Colors.white.withValues(alpha: 0.1);

  /// Countdown badge border rengi
  static Color countdownBadgeBorderColor = primaryGreen.withValues(alpha: 0.5);

  // ═══════════════════════════════════════════════════════════════════════════
  // İKON RENKLERİ (Icon Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Aktif ikon rengi
  static const Color activeIconColor = primaryGreen;

  /// Normal ikon rengi
  static Color normalIconColor = Colors.white.withValues(alpha: 0.5);

  /// Konum ikonu rengi
  static const Color locationIconColor = primaryGreen;

  // ═══════════════════════════════════════════════════════════════════════════
  // DURUM GÖSTERGELERİ (Status Indicators)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Aktif durum göstergesi
  static const Color activeIndicatorColor = primaryGreen;

  /// Geçmiş durum göstergesi
  static Color passedIndicatorColor = Colors.white.withValues(alpha: 0.3);

  /// Normal gösterge border rengi (gün numarası çemberi)
  static Color normalIndicatorBorderColor = Colors.white.withValues(alpha: 0.3);

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING VE BUTTON RENKLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Loading indicator rengi
  static const Color loadingColor = primaryGreen;

  /// Hata durumu button rengi
  static const Color errorButtonColor = primaryGreen;

  /// Success rengi
  static const Color successColor = Colors.green;

  // ═══════════════════════════════════════════════════════════════════════════
  // DRAWER RENKLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Drawer header gradient başlangıç
  static const Color drawerGradientStart = lightGreen;

  /// Drawer header gradient bitiş
  static Color drawerGradientEnd = lightGreen.withValues(alpha: 0.7);

  /// Drawer arka plan rengi
  static const Color drawerBackgroundColor = prayerBackgroundColor;

  /// Drawer item arka plan rengi (hover/aktif)
  static Color drawerItemBackground = primaryGreen.withValues(alpha: 0.15);

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTINGS EKRANI RENKLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Settings tile ikon arka planı
  static Color settingsIconBackground = primaryGreen.withValues(alpha: 0.15);

  /// Dropdown arka plan rengi
  static const Color dropdownBackgroundColor = darkGreen;

  // ═══════════════════════════════════════════════════════════════════════════
  // METİN STİLLERİ (Text Theme)
  // ═══════════════════════════════════════════════════════════════════════════
  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // AÇIK TEMA (Light Theme)
  // ═══════════════════════════════════════════════════════════════════════════
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: lightBackgroundColor,

    colorScheme: const ColorScheme.light(
      primary: lightGreen,
      secondary: tealGreen,
      onPrimary: textWhite,
      surface: lightBackgroundColor,
    ),

    textTheme: _textTheme.apply(
      bodyColor: lightTextColor,
      displayColor: lightTextColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: lightGreen,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: textWhite,
      ),
      iconTheme: IconThemeData(color: textWhite),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: textWhite,
        textStyle: _textTheme.labelLarge,
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // KOYU TEMA (Dark Theme)
  // ═══════════════════════════════════════════════════════════════════════════
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: darkBackgroundColor,

    colorScheme: const ColorScheme.dark(
      primary: tealGreen,
      secondary: Color.fromARGB(255, 8, 91, 84),
      onPrimary: textWhite,
      surface: darkBackgroundColor,
    ),

    textTheme: _textTheme.apply(
      bodyColor: darkTextColor,
      displayColor: darkTextColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: textWhite,
      ),
      iconTheme: const IconThemeData(color: textWhite),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tealGreen,
        foregroundColor: textWhite,
        textStyle: _textTheme.labelLarge,
      ),
    ),
  );
}
