import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF1A1726);
  static const Color backgroundRaised = Color(0xFF252135);
  static const Color focusAccent = Color(0xFFFDD5B5);
  static const Color shortBreakAccent = Color(0xFF7FBF5F);
  static const Color longBreakAccent = Color(0xFF5FA8D3);
  static const Color textPrimary = Color(0xFFF4EDE4);
  static const Color textSecondary = Color(0xFF9A93A8);
  static const Color blockShadow = Color(0xFF12101B);

  static ThemeData get theme {
    final dark = ThemeData.dark(useMaterial3: true);
    return dark.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: focusAccent,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.pixelifySansTextTheme(dark.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }

  static BoxDecoration block({Color? color}) => BoxDecoration(
        color: color ?? backgroundRaised,
        border: Border.all(color: blockShadow, width: 2),
        boxShadow: const [
          BoxShadow(color: blockShadow, offset: Offset(4, 4), blurRadius: 0),
        ],
      );

  static TextStyle pixelText({double size = 16, Color? color, FontWeight? weight}) => GoogleFonts.pixelifySans(
        fontSize: size,
        color: color ?? textPrimary,
        fontWeight: weight,
      );

  static TextStyle timerText({double size = 64}) => GoogleFonts.silkscreen(
        fontSize: size,
        color: textPrimary,
      );
}
