import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/workout_log_model.dart';
import '../models/ai_plan_model.dart';
import '../core/constants/app_constants.dart';

class AIService {
  static const String _baseUrl = AppConstants.openRouterBaseUrl;
  static const String _model = AppConstants.openRouterModel;
  
  final String _apiKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AIService({required String apiKey}) : _apiKey = apiKey;

  // ========== EXISTING METHODS (Keep Working) ==========

  Future<String> generateWorkoutPlan(String goal, int days, String level) async {
    final prompt = '''Create a detailed $days-day workout plan for someone who wants to $goal. 
Fitness level: $level.
Include specific exercises, sets, reps, and rest periods for each day.
Format in Markdown with:
- ## Day 1, ## Day 2 headings
- Tables for exercises (Exercise | Sets | Reps | Rest)
- Notes for form and safety
- Warm-up and cool-down sections''';  
    
    return _sendMessage(prompt);
  }

  Future<String> getImprovementSuggestions(List<WorkoutLogModel> logs) async {
    if (logs.isEmpty) return 'Complete some workouts first to get personalized suggestions!';
    
    final summary = logs.take(5).map((log) => 
      "${log.workoutName}: ${log.duration ~/ 60}min, ${log.caloriesBurned.toStringAsFixed(0)} cal, ${log.setsCompleted} sets"
    ).join('\n');
    
    final prompt = '''Based on these recent workouts:\n$summary\n\nProvide 3-4 specific suggestions to improve performance, increase intensity, or optimize results. Keep it concise and actionable.''';  
    
    return _sendMessage(prompt);
  }

  Future<String> getDailyTip(UserModel user) async {
    final prompt = '''Give a single, motivational fitness tip for ${user.name} who wants to ${user.fitnessGoal}. 
BMI: ${user.bmi.toStringAsFixed(1)} (${user.bmiCategory}).
Keep it under 2 sentences, inspiring and practical.''';  
    
    return _sendMessage(prompt);
  }

  Future<String> getDietSuggestions(UserModel user) async {
    final prompt = '''Suggest a daily meal plan for someone who wants to ${user.fitnessGoal}.
Daily calorie goal: ${user.dailyCalorieGoal.toStringAsFixed(0)} kcal.
Format in Markdown with:
- ## Breakfast, ## Lunch, ## Dinner, ## Snacks headings
- Tables for meals (Food | Portion | Calories)
- Macro breakdown (Protein/Carbs/Fats percentages)
- Prep tips''';  
    
    return _sendMessage(prompt);
  }

  Future<String> askCoach(String question, UserModel? user) async {
    String context = '';
    if (user != null) {
      context = '''User: ${user.name}, Goal: ${user.fitnessGoal}, BMI: ${user.bmi.toStringAsFixed(1)}. ''';
    }
    final prompt = '''$context\nFitness question: $question\nProvide a helpful, accurate fitness response.''';  
    
    return _sendMessage(prompt);
  }

  // ========== NEW: FIREBASE SAVE METHODS ==========

  /// Generate workout plan AND save to Firebase
  Future<AIPlanModel> generateAndSaveWorkoutPlan({
    required UserModel user,
    required int days,
    required String level,
  }) async {
    final content = await generateWorkoutPlan(user.fitnessGoal, days, level);
    
    final plan = AIPlanModel(
      id: '',
      userId: user.uid,
      type: PlanType.workout,
      title: '$days-Day ${level[0].toUpperCase()}${level.substring(1)} Workout',
      content: content,
      status: PlanStatus.pending,
      createdAt: DateTime.now(),
      metadata: {
        'days': days,
        'level': level,
        'goal': user.fitnessGoal,
        'dailyCalories': user.dailyCalorieGoal,
      },
    );

    final docRef = await _firestore.collection('ai_plans').add(plan.toFirestore());
    return plan.copyWith(id: docRef.id);
  }

  /// Generate diet plan AND save to Firebase
  Future<AIPlanModel> generateAndSaveDietPlan({
    required UserModel user,
  }) async {
    final content = await getDietSuggestions(user);
    
    final plan = AIPlanModel(
      id: '',
      userId: user.uid,
      type: PlanType.diet,
      title: 'Diet Plan - ${DateTime.now().toString().split(' ')[0]}',
      content: content,
      status: PlanStatus.pending,
      createdAt: DateTime.now(),
      metadata: {
        'dailyCalories': user.dailyCalorieGoal,
        'goal': user.fitnessGoal,
        'bmi': user.bmi,
      },
    );

    final docRef = await _firestore.collection('ai_plans').add(plan.toFirestore());
    return plan.copyWith(id: docRef.id);
  }

  // ========== PRIVATE METHODS ==========

  Future<String> _sendMessage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://muscles-training-club.app',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional fitness coach and nutritionist. Provide accurate, safe, and motivating fitness advice. Always use Markdown formatting.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response received.';
      } else {
        return 'AI service temporarily unavailable. Please try again later.';
      }
    } catch (e) {
      return 'Connection error. Please check your internet and try again.';
    }
  }
}