import 'package:flutter/material.dart';

class AppTheme {
  static const Color nero = Color(0xFF1A1A1A);
  static const Color bianco = Color(0xFFFAFAFA);
  static const Color grigio = Color(0xFF757575);
  static const Color grigioChiaro = Color(0xFFE0E0E0);
  static const Color accent = Color(0xFF2C2C2C);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bianco,
      colorScheme: const ColorScheme.light(
        primary: nero,
        onPrimary: bianco,
        secondary: accent,
        onSecondary: bianco,
        surface: bianco,
        onSurface: nero,
        outline: grigioChiaro,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bianco,
        foregroundColor: nero,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: nero,
          letterSpacing: 1.5,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: nero,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: nero,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: nero,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: nero,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Lato',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: nero,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Lato',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: nero,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Lato',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: nero,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Lato',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: grigio,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Lato',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: nero,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nero,
          foregroundColor: bianco,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: nero,
          side: const BorderSide(color: nero, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: nero, size: 24),
      dividerTheme: const DividerThemeData(color: grigioChiaro, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bianco,
        selectedItemColor: nero,
        unselectedItemColor: grigio,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: bianco,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: grigioChiaro, width: 0.5),
        ),
      ),
    );
  }
}
