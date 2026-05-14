import 'package:muscular_training_club/core/constants/app_constants.dart';

class CalorieCalculator {
  CalorieCalculator._();
  
  /// Harris-Benedict Equation for BMR
  static double calculateBMR(double weightKg, double heightCm, int age, String gender) {
    if (gender.toLowerCase() == 'male') {
      return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }
  }
  
  /// TDEE = BMR * activity multiplier
  static double calculateTDEE(double bmr, String fitnessGoal, {double activityMultiplier = 1.55}) {
    double tdee = bmr * activityMultiplier;
    if (fitnessGoal == 'lose_weight') return tdee - 500;
    if (fitnessGoal == 'gain_muscle') return tdee + 300;
    return tdee;
  }
  
  /// MET-based calorie burn during exercise
  static double calculateCaloriesBurned(double weightKg, double metValue, double durationMinutes) {
    return (metValue * weightKg * 3.5 / 200) * durationMinutes;
  }
  
  /// Get MET value for exercise type
  static double getMETValue(String exerciseType) {
    return AppConstants.metValues[exerciseType.toLowerCase()] ?? 5.0;
  }
  
  /// Calculate calories for a specific exercise
  static double calculateExerciseCalories(
    double weightKg, 
    String exerciseType, 
    double durationMinutes,
  ) {
    double met = getMETValue(exerciseType);
    return calculateCaloriesBurned(weightKg, met, durationMinutes);
  }
  
  static String formatCalories(double calories) {
    return calories.toStringAsFixed(0);
  }
  
  static String getGoalLabel(String goal) {
    switch (goal) {
      case 'lose_weight': return 'Lose Weight';
      case 'gain_muscle': return 'Gain Muscle';
      case 'maintain': return 'Maintain Weight';
      default: return 'Maintain Weight';
    }
  }
}