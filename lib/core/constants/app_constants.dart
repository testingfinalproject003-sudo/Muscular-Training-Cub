class AppConstants {
  AppConstants._();
  
  static const String appName = 'Muscles Training Club';
  static const String appVersion = '1.0.0';
  
  // API
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String openRouterModel = "openai/gpt-4o-mini";
   static const String openRouterApiKey = '';
  // Shared Preferences Keys
  static const String prefUserData = 'user_data';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefTheme = 'app_theme';
  
  // Default Values
  static const double defaultWaterGoal = 2000; // ml
  static const int defaultWaterCups = 8;
  static const double defaultCupSize = 250; // ml
  
  // MET Values
  static const Map<String, double> metValues = {
    'running': 9.8,
    'cycling': 8.0,
    'weight_training': 5.0,
    'hiit': 10.0,
    'yoga': 3.0,
    'cardio': 8.0,
    'core': 4.0,
  };
  
  // Activity Multipliers
  static const double activityMultiplierSedentary = 1.2;
  static const double activityMultiplierLight = 1.375;
  static const double activityMultiplierModerate = 1.55;
  static const double activityMultiplierActive = 1.725;
  static const double activityMultiplierVeryActive = 1.9;
  
  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 1000);
}