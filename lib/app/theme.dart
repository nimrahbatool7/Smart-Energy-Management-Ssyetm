import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

class VioraTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VioraColors.primaryBackground,
      primaryColor: VioraColors.energyGlow,
      colorScheme: const ColorScheme.dark(
        primary: VioraColors.energyGlow,
        secondary: VioraColors.savingGreen,
        surface: VioraColors.primaryBackground,
        error: VioraColors.dangerRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: VioraColors.textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: VioraColors.textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: VioraColors.textPrimary),
        bodyMedium: GoogleFonts.inter(color: VioraColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      useMaterial3: true,
    );
  }
}
