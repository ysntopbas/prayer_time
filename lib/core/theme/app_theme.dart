import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // 2. Font ailesini sabit bir değişkene atıyoruz (opsiyonel ama temiz)
  static const String _fontFamily = 'Montserrat';

  // 3. Renk paletimizi tanımlıyoruz
  static const Color _lightPrimaryColor = Color(0xFF308C58);
  static const Color _lightSecondaryColor = Color(0xFF0E978B);
  static const Color _lightOnPrimaryColor = Colors.white;
  static const Color _lightBackgroundColor = Colors.white;
  static const Color _lightTextColor = Colors.black;

  static const Color _darkPrimaryColor = Color(0xFF0E978B);
  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color _darkTextColor = Colors.white70;

  // 4. Tekrar kullanılacak TEMEL Metin Stillerini (TextTheme) tanımlıyoruz
  // Bu, sorduğunuz "başlıkları, metinleri tek yerden kontrol etme" kısmıdır.
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

  // 5. AÇIK TEMA (Light Theme)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: _lightBackgroundColor,

    // Renk şeması
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
      surface: _lightBackgroundColor,
    ),

    // Metin stillerini (renkleriyle birlikte) ayarla
    textTheme: _textTheme.apply(
      bodyColor: _lightTextColor,
      displayColor: _lightTextColor,
    ),

    // Diğer widget'ların temalarını özelleştir
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: _lightOnPrimaryColor,
      ),
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: _lightOnPrimaryColor,
        textStyle: _textTheme.labelLarge,
      ),
    ),
  );

  // 6. KOYU TEMA (Dark Theme)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: _darkBackgroundColor,

    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      onPrimary: _darkOnPrimaryColor,
      surface: _darkBackgroundColor,
    ),

    // Metin stillerini (renkleriyle birlikte) ayarla
    textTheme: _textTheme.apply(
      bodyColor: _darkTextColor,
      displayColor: _darkTextColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: _darkOnPrimaryColor,
      ),
      iconTheme: const IconThemeData(color: _darkOnPrimaryColor),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: _darkOnPrimaryColor,
        textStyle: _textTheme.labelLarge,
      ),
    ),
  );
}


//308c58 yeşil kodu #308c58 gradient first
//0e978b mavi kodu #0e978b gradient last