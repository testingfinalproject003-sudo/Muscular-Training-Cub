import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muscular_training_club/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      primaryColor: AppColors.accentPurple,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPurple,
        secondary: AppColors.accentViolet,
        surface: AppColors.secondaryBackground,
        // background: AppColors.primaryBackground,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        // onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.glowColor,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.accentViolet,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14, color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12, color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.glowColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppColors.accentPurple.withValues(alpha:0.4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha:0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentViolet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.nunito(
          color: AppColors.textSecondary.withValues(alpha:0.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha:0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.secondaryBackground.withValues(alpha:0.9),
        selectedItemColor: AppColors.glowColor,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12, fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12, fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondaryBackground,
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.textPrimary, fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}