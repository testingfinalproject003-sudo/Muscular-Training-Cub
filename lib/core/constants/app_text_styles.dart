import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();
  
  static TextStyle get orbitron => GoogleFonts.orbitron();
  static TextStyle get rajdhani => GoogleFonts.rajdhani();
  static TextStyle get nunito => GoogleFonts.nunito();
  
  // Headings
  static TextStyle headingLarge = orbitron.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );
  
  static TextStyle headingMedium = orbitron.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );
  
  static TextStyle headingSmall = orbitron.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body
  static TextStyle bodyLarge = nunito.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static TextStyle bodyMedium = nunito.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static TextStyle bodySmall = nunito.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Labels
  static TextStyle labelLarge = rajdhani.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.glowColor,
    letterSpacing: 1.0,
  );
  
  static TextStyle labelMedium = rajdhani.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.accentViolet,
    letterSpacing: 0.5,
  );
  
  // Special
  static TextStyle logo = orbitron.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.glowColor,
    shadows: [
      Shadow(
        color: AppColors.accentPurple.withValues(alpha:0.8),
        blurRadius: 20,
        offset: const Offset(0, 0),
      ),
    ],
  );
  
  static TextStyle statNumber = orbitron.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.glowColor,
  );
  
  static TextStyle statLabel = rajdhani.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}