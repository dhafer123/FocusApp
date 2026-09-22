import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusColors extends ThemeExtension<FocusColors> {
  const FocusColors({
    required this.background,
    required this.backgroundRaised,
    required this.focusAccent,
    required this.shortBreakAccent,
    required this.longBreakAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.blockShadow,
  });

  final Color background;
  final Color backgroundRaised;
  final Color focusAccent;
  final Color shortBreakAccent;
  final Color longBreakAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color blockShadow;

  @override
  FocusColors copyWith({
    Color? background,
    Color? backgroundRaised,
    Color? focusAccent,
    Color? shortBreakAccent,
    Color? longBreakAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? blockShadow,
  }) => FocusColors(
        background: background ?? this.background,
        backgroundRaised: backgroundRaised ?? this.backgroundRaised,
        focusAccent: focusAccent ?? this.focusAccent,
        shortBreakAccent: shortBreakAccent ?? this.shortBreakAccent,
        longBreakAccent: longBreakAccent ?? this.longBreakAccent,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        blockShadow: blockShadow ?? this.blockShadow,
      );

  @override
  FocusColors lerp(covariant FocusColors? other, double t) {
    if (other == null) return this;
    return FocusColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundRaised: Color.lerp(backgroundRaised, other.backgroundRaised, t)!,
      focusAccent: Color.lerp(focusAccent, other.focusAccent, t)!,
      shortBreakAccent: Color.lerp(shortBreakAccent, other.shortBreakAccent, t)!,
      longBreakAccent: Color.lerp(longBreakAccent, other.longBreakAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      blockShadow: Color.lerp(blockShadow, other.blockShadow, t)!,
    );
  }
}

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
    return _buildTheme(
      dark,
      const FocusColors(
        background: background,
        backgroundRaised: backgroundRaised,
        focusAccent: focusAccent,
        shortBreakAccent: shortBreakAccent,
        longBreakAccent: longBreakAccent,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        blockShadow: blockShadow,
      ),
      Brightness.dark,
    );
  }

  static ThemeData get lightTheme {
    final light = ThemeData.light(useMaterial3: true);
    return _buildTheme(
      light,
      const FocusColors(
        background: Color(0xFFD2CCC5),
        backgroundRaised: Color(0xFFDED7CF),
        focusAccent: Color(0xFFA96627),
        shortBreakAccent: Color(0xFF467A37),
        longBreakAccent: Color(0xFF326C8E),
        textPrimary: Color(0xFF302A32),
        textSecondary: Color(0xFF5F5961),
        blockShadow: Color(0xFF8F8780),
      ),
      Brightness.light,
    );
  }

  static ThemeData _buildTheme(
    ThemeData base,
    FocusColors colors,
    Brightness brightness,
  ) {
    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.focusAccent,
        brightness: brightness,
      ),
      textTheme: GoogleFonts.pixelifySansTextTheme(base.textTheme).apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      extensions: [colors],
    );
  }

  static FocusColors colors(BuildContext context) =>
      Theme.of(context).extension<FocusColors>()!;

    static BoxDecoration block({Color? color, FocusColors? palette}) => BoxDecoration(
      color: color ?? palette?.backgroundRaised ?? backgroundRaised,
      border: Border.all(color: palette?.blockShadow ?? blockShadow, width: 2),
        boxShadow: [
          BoxShadow(
            color: palette?.blockShadow ?? blockShadow,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      );

  static TextStyle pixelText({double size = 16, Color? color, FontWeight? weight}) => GoogleFonts.pixelifySans(
        fontSize: size,
        color: color ?? textPrimary,
        fontWeight: weight,
      );

    static TextStyle timerText({double size = 64, Color? color}) => GoogleFonts.silkscreen(
        fontSize: size,
      color: color ?? textPrimary,
      );
}
