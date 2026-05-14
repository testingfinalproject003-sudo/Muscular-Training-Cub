import '../constants/app_colors.dart';

class BMICalculator {
  BMICalculator._();
  
  static double calculateBMI(double weightKg, double heightCm) {
    double heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
  
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
  
  static String getBMICategoryDescription(String category) {
    switch (category) {
      case 'Underweight':
        return 'You are below the healthy weight range. Consider increasing your calorie intake with nutrient-dense foods and strength training.';
      case 'Normal':
        return 'You are in the healthy weight range. Maintain your current lifestyle with balanced nutrition and regular exercise.';
      case 'Overweight':
        return 'You are above the healthy weight range. Focus on a calorie deficit diet and increase cardiovascular activities.';
      case 'Obese':
        return 'You are significantly above the healthy weight range. Consult a healthcare provider and start with low-impact exercises.';
      default:
        return '';
    }
  }
  
  static Map<String, dynamic> getBMIInfo(double bmi) {
    String category = getBMICategory(bmi);
    return {
      'bmi': bmi,
      'category': category,
      'color': AppColors.getBmiColor(category),
      'description': getBMICategoryDescription(category),
    };
  }
  
  static Map<String, double> getIdealWeightRange(double heightCm) {
    double heightM = heightCm / 100;
    double minWeight = 18.5 * heightM * heightM;
    double maxWeight = 24.9 * heightM * heightM;
    return {'min': minWeight, 'max': maxWeight};
  }
}