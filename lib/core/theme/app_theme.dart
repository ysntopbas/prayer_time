import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // FONT AİLESİ
  // ═══════════════════════════════════════════════════════════════════════════
  static const String _fontFamily = 'Montserrat';

  static const double fontSizeXXL = 72.0;
  static const double fontSizeXL = 24.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeMD = 14.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // PADDING AİLESİ
  // ═══════════════════════════════════════════════════════════════════════════
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANA RENKLER (Primary Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1A2E1A);
  static const Color mediumGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color.fromARGB(255, 48, 140, 88);
  static const Color tealGreen = Color(0xFF0E978B);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEMA BAZLI RENKLER - Bu metotları kullanarak tema uyumlu renkler alın
  // ═══════════════════════════════════════════════════════════════════════════

  /// Helper: Tema dark mı kontrol et
  static bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Ana arka plan rengi
  static Color getBackgroundColor(BuildContext context) {
    return _isDark(context) ? darkGreen : const Color(0xFFF5F5F5);
  }

  /// Scaffold arka plan rengi
  static Color getScaffoldColor(BuildContext context) {
    return _isDark(context) ? darkGreen : Colors.white;
  }

  /// Kart arka plan rengi
  static Color getCardColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RENK YARDIMCI METODLARI (Color Helper Methods)
  // ═══════════════════════════════════════════════════════════════════════════

  // Ana metin rengi - Light'ta siyah, Dark'ta beyaz
  static Color getTextColor(BuildContext context) {
    return _isDark(context) ? textWhite : Colors.black87;
  }

  // İkincil metin rengi
  static Color getSecondaryTextColor(BuildContext context) {
    return _isDark(context) ? textWhite70 : Colors.black54;
  }

  // Üçüncül metin rengi
  static Color getTertiaryTextColor(BuildContext context) {
    return _isDark(context) ? textWhite50 : Colors.black45;
  }

  // AppBar rengi
  static Color getAppBarColor(BuildContext context) {
    return _isDark(context) ? darkGreen : lightGreen;
  }

  // Divider rengi
  static Color getDividerColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.2);
  }

  // Cami silüeti rengi
  static Color getMosqueColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF2D4A2D).withValues(alpha: 0.3)
        : primaryGreen.withValues(alpha: 0.1);
  }

  // ListTile başlık rengi
  static Color getListTileTitleColor(BuildContext context) {
    return _isDark(context) ? textWhite : Colors.black87;
  }

  // ListTile alt başlık rengi
  static Color getListTileSubtitleColor(BuildContext context) {
    return _isDark(context) ? textWhite70 : Colors.black54;
  }

  // Icon rengi (yeşil olmayan iconlar için)
  static Color getIconColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black45;
  }

  /// Border rengi
  static Color getBorderColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.2);
  }

  /// Aktif kart arka planı
  static Color getActiveCardBackground(BuildContext context) {
    return _isDark(context)
        ? primaryGreen.withValues(alpha: 0.15)
        : primaryGreen.withValues(alpha: 0.1);
  }

  /// Chip arka plan rengi
  static Color getChipBackground(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.1);
  }

  /// Countdown badge arka planı
  static Color getCountdownBadgeBackground(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.1);
  }

  /// Drawer gradient başlangıç
  static Color getDrawerGradientStart(BuildContext context) {
    return _isDark(context) ? lightGreen : lightGreen;
  }

  /// Drawer gradient bitiş
  static Color getDrawerGradientEnd(BuildContext context) {
    return _isDark(context)
        ? lightGreen.withValues(alpha: 0.7)
        : lightGreen.withValues(alpha: 0.85);
  }

  /// Dropdown arka plan
  static Color getDropdownBackground(BuildContext context) {
    return _isDark(context) ? darkGreen : Colors.white;
  }

  /// Dialog arka plan
  static Color getDialogBackground(BuildContext context) {
    return _isDark(context) ? darkGreen : Colors.white;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SABİT RENKLER (Tema değişmeyen)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color primaryGreenColor = primaryGreen;
  static const Color activeCardBorderColor = primaryGreen;
  static const Color badgeBackgroundColor = primaryGreen;
  static const Color badgeTextColor = Colors.white;
  static const Color activeIconColor = primaryGreen;
  static const Color activeIndicatorColor = primaryGreen;
  static const Color loadingColor = primaryGreen;
  static const Color errorButtonColor = primaryGreen;
  static const Color successColor = Colors.green;
  static const Color locationIconColor = primaryGreen;

  // ═══════════════════════════════════════════════════════════════════════════
  // ESKİ SABİT RENKLER (Geriye uyumluluk için - Yavaş yavaş kaldırılacak)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color prayerBackgroundColor = darkGreen;
  static const Color mosqueBackgroundColor = Color(0xFF2D4A2D);
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;
  static Color textWhite60 = Colors.white.withValues(alpha: 0.6);
  static Color textWhite50 = Colors.white.withValues(alpha: 0.5);
  static Color textWhite40 = Colors.white.withValues(alpha: 0.4);
  static Color textWhite30 = Colors.white.withValues(alpha: 0.3);
  static Color cardBorderColor = Colors.white.withValues(alpha: 0.1);
  static Color chipBackground = Colors.white.withValues(alpha: 0.05);
  static Color chipActiveBackground = primaryGreen.withValues(alpha: 0.2);
  static Color chipBorderColor = Colors.white.withValues(alpha: 0.1);
  static Color chipActiveBorderColor = primaryGreen.withValues(alpha: 0.5);
  static Color countdownBadgeBackground = Colors.white.withValues(alpha: 0.1);
  static Color countdownBadgeBorderColor = primaryGreen.withValues(alpha: 0.5);
  static Color normalIconColor = Colors.white.withValues(alpha: 0.5);
  static Color passedIndicatorColor = Colors.white.withValues(alpha: 0.3);
  static Color normalIndicatorBorderColor = Colors.white.withValues(alpha: 0.3);
  static const Color drawerGradientStart = lightGreen;
  static Color drawerGradientEnd = lightGreen.withValues(alpha: 0.7);
  static Color activeCardBackground = primaryGreen.withValues(alpha: 0.15);
  static Color activeCardBackgroundDark = mediumGreen.withValues(alpha: 0.3);

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
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: lightGreen,
      secondary: tealGreen,
      onPrimary: Colors.white,
      onSurface: Colors.black87,
      surface: Colors.white,
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightGreen,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.black87,
      iconColor: Colors.black54,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(primaryGreen),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryGreen.withValues(alpha: 0.5);
        }
        return Colors.grey.shade300;
      }),
    ),
    dividerTheme: const DividerThemeData(color: Colors.black12),
    cardTheme: const CardThemeData(color: Colors.white, elevation: 2),
    iconTheme: const IconThemeData(color: Colors.black54),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      contentTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.0,
        color: Colors.black87,
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // KOYU TEMA (Dark Theme)
  // ═══════════════════════════════════════════════════════════════════════════
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: darkGreen,
    colorScheme: const ColorScheme.dark(
      primary: tealGreen,
      secondary: Color.fromARGB(255, 8, 91, 84),
      onPrimary: Colors.white,
      surface: darkGreen,
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.white70,
      displayColor: Colors.white70,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkGreen,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tealGreen,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
