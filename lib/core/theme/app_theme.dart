import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0F172A);
  static const Color focusAccent = Color(0xFF2DD4BF);
  static const Color shortBreakAccent = Color(0xFF4ADE80);
  static const Color longBreakAccent = Color(0xFFFBBF24);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get theme {
    final dark = ThemeData.dark();
    return dark.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: focusAccent,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(dark.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF111C30),
        indicatorColor: focusAccent.withAlpha(40),
      ),
    );
  }
}
