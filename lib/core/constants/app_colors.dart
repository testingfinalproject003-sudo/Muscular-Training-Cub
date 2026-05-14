import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBackground = Color(0xFF0D0A1A);
  static const Color secondaryBackground = Color(0xFF130F22);
  static const Color accentPurple = Color(0xFF7B2FBE);
  static const Color accentViolet = Color(0xFF9D4EDD);
  static const Color glowColor = Color(0xFFC77DFF);
  static const Color textPrimary = Color(0xFFF0E6FF);
  static const Color textSecondary = Color(0xFFA89BC2);
  static const Color border = Color.fromRGBO(155, 100, 255, 0.2);
  static const Color success = Color(0xFF39FF14);
  static const Color warning = Color(0xFFFF6B35);
  static const Color error = Color(0xFFFF3366);
  
  // Muscle group colors
  static const Color chestColor = Color(0xFFE63946);
  static const Color backColor = Color(0xFF2196F3);
  static const Color legsColor = Color(0xFF9C27B0);
  static const Color armsColor = Color(0xFFFF9800);
  static const Color shouldersColor = Color(0xFF00BCD4);
  static const Color coreColor = Color(0xFF4CAF50);
  static const Color cardioColor = Color(0xFFF44336);
  
  // BMI colors
  static const Color bmiUnderweight = Color(0xFF64B5F6);
  static const Color bmiNormal = Color(0xFF81C784);
  static const Color bmiOverweight = Color(0xFFFFB74D);
  static const Color bmiObese = Color(0xFFE57373);
  
  static Color getMuscleColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest': return chestColor;
      case 'back': return backColor;
      case 'legs': return legsColor;
      case 'arms': return armsColor;
      case 'shoulders': return shouldersColor;
      case 'core': return coreColor;
      case 'cardio': return cardioColor;
      default: return accentPurple;
    }
  }
  
  static Color getBmiColor(String category) {
    switch (category.toLowerCase()) {
      case 'underweight': return bmiUnderweight;
      case 'normal': return bmiNormal;
      case 'overweight': return bmiOverweight;
      case 'obese': return bmiObese;
      default: return accentPurple;
    }
  }
}