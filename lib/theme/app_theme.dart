import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand tokens locked from the Hi Pando mobile spec (section 2).
class AppColors {
  static const red = Color(0xFFE0322B);
  static const ink = Color(0xFF111111);
  static const cream = Color(0xFFF5E9C8);
  static const creamText = Color(0xFF4A3B1E);
  static const surface = Color(0xFFFFFFFF);
  static const bgWarm = Color(0xFFFAF7F2);
  static const mapDark = Color(0xFF0E1418);
  static const muted = Color(0xFF7A7A7A);
  static const green = Color(0xFF16A34A);
  static const pink = Color(0xFFFADCE4);
}

class AppText {
  static TextStyle serif({
    double size = 22,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    FontStyle style = FontStyle.normal,
    double? height,
  }) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontStyle: style,
        height: height,
      );

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ink,
    double? letterSpacing,
  }) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle microLabel({Color color = Colors.white}) => sans(
        size: 11,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: 1.6,
      );
}

class AppRadii {
  static const pill = 999.0;
  static const card = 22.0;
  static const sheet = 28.0;
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgWarm,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.red,
      primary: AppColors.red,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
  );
}
