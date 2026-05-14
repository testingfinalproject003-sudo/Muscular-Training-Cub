// import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final String primaryMuscle;
  final int sets;
  final String reps;
  final int? duration; // seconds per set (if timed exercise like plank)
  final double caloriesPerMinute;
  final int difficulty; // 1-5
  final String description;
  final String tips;
  final bool isCustom;
  final String? imageUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.primaryMuscle,
    required this.sets,
    required this.reps,
    this.duration,
    required this.caloriesPerMinute,
    required this.difficulty,
    required this.description,
    required this.tips,
    this.isCustom = false,
    this.imageUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      muscleGroup: json['muscleGroup'] ?? '',
      primaryMuscle: json['primaryMuscle'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? '10',
      duration: json['duration'],
      caloriesPerMinute: (json['caloriesPerMinute'] ?? 0).toDouble(),
      difficulty: json['difficulty'] ?? 3,
      description: json['description'] ?? '',
      tips: json['tips'] ?? '',
      isCustom: json['isCustom'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'primaryMuscle': primaryMuscle,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'caloriesPerMinute': caloriesPerMinute,
      'difficulty': difficulty,
      'description': description,
      'tips': tips,
      'isCustom': isCustom,
      'imageUrl': imageUrl,
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? primaryMuscle,
    int? sets,
    String? reps,
    int? duration,
    double? caloriesPerMinute,
    int? difficulty,
    String? description,
    String? tips,
    bool? isCustom,
    String? imageUrl,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      caloriesPerMinute: caloriesPerMinute ?? this.caloriesPerMinute,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      tips: tips ?? this.tips,
      isCustom: isCustom ?? this.isCustom,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Get real exercise image URL from free-exercise-db
  /// Falls back to muscle group placeholder if not found
  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    return _getExerciseImageUrl();
  }

  static String _getBaseImageUrl() =>
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

  String _getExerciseImageUrl() {
    // Map exercise names to free-exercise-db image IDs
    final Map<String, String> exerciseImageMap = {
      // CHEST
      'Barbell Bench Press': 'Barbell_Bench_Press',
      'Incline Dumbbell Press': 'Incline_Dumbbell_Bench_Press',
      'Decline Push-Up': 'Push_Up',
      'Cable Crossover': 'Cable_Crossover',
      'Dumbbell Flyes': 'Dumbbell_Flyes',
      'Push-Up': 'Push_Up',
      'Chest Dip': 'Chest_Dip',
      'Pec Deck Machine': 'Pec_Deck_Fly',
      'Landmine Press': 'Landmine_Press',
      'Svend Press': 'Svend_Press',
      // BACK
      'Deadlift': 'Barbell_Deadlift',
      'Pull-Up': 'Pull_Up',
      'Barbell Row': 'Bent_Over_Row',
      'Lat Pulldown': 'Lat_Pulldown',
      'Seated Cable Row': 'Seated_Cable_Row',
      'Single Arm DB Row': 'One_Arm_Dumbbell_Row',
      'T-Bar Row': 'T-Bar_Row',
      'Face Pull': 'Face_Pull',
      'Good Morning': 'Good_Morning',
      'Hyperextension': 'Back_Extension',
      // LEGS
      'Barbell Squat': 'Barbell_Squat',
      'Romanian Deadlift': 'Romanian_Deadlift',
      'Leg Press': 'Leg_Press',
      'Walking Lunge': 'Dumbbell_Walking_Lunge',
      'Leg Curl': 'Leg_Curl',
      'Leg Extension': 'Leg_Extension',
      'Bulgarian Split Squat': 'Bulgarian_Split_Squat',
      'Calf Raise': 'Standing_Calf_Raise',
      'Hack Squat': 'Hack_Squat',
      'Glute Bridge': 'Glute_Bridge',
      // ARMS
      'Barbell Curl': 'Barbell_Curl',
      'Tricep Pushdown': 'Triceps_Pushdown',
      'Hammer Curl': 'Hammer_Curl',
      'Skull Crusher': 'Skull_Crusher',
      'Incline DB Curl': 'Incline_Dumbbell_Curl',
      'Close-Grip Bench': 'Close_Grip_Bench_Press',
      'Concentration Curl': 'Concentration_Curl',
      'Overhead Tricep Ext': 'Overhead_Triceps_Extension',
      'Preacher Curl': 'Preacher_Curl',
      'Diamond Push-Up': 'Diamond_Push_Up',
      // SHOULDERS
      'Overhead Press': 'Overhead_Press',
      'Lateral Raise': 'Lateral_Raise',
      'Front Raise': 'Front_Raise',
      'Arnold Press': 'Arnold_Press',
      'Upright Row': 'Upright_Row',
      'Rear Delt Fly': 'Reverse_Fly',
      'Shrug': 'Barbell_Shrug',
      'Push Press': 'Push_Press',
      'Cable Lateral Raise': 'Cable_Lateral_Raise',
      // CORE
      'Plank': 'Plank',
      'Crunch': 'Crunch',
      'Russian Twist': 'Russian_Twist',
      'Leg Raise': 'Leg_Raise',
      'Mountain Climber': 'Mountain_Climber',
      'Ab Wheel Rollout': 'Ab_Wheel_Rollout',
      'Side Plank': 'Side_Plan',
      'Bicycle Crunch': 'Bicycle_Crunch',
      'Dragon Flag': 'Dragon_Flag',
      'Dead Bug': 'Dead_Bug',
      // CARDIO
      'Treadmill Run': 'Treadmill_Run',
      'Jump Rope': 'Jump_Rope',
      'Cycling': 'Cycling',
      'Burpees': 'Burpees',
      'Box Jump': 'Box_Jump',
      'Rowing Machine': 'Rowing_Machine',
      'Jumping Jacks': 'Jumping_Jacks',
      'Sprint Intervals': 'Sprint',
      'Stair Climber': 'Stair_Climber',
      'Battle Ropes': 'Battle_Ropes',
    };

    final mappedName = exerciseImageMap[name];
    if (mappedName != null) {
      return '${_getBaseImageUrl()}$mappedName/0.jpg';
    }

    // Fallback to muscle group placeholder
    return _getMuscleGroupPlaceholder();
  }

  String _getMuscleGroupPlaceholder() {
    final Map<String, String> muscleImages = {
      'Chest': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
      'Back': 'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=400',
      'Legs': 'https://images.unsplash.com/photo-1434608519344-49d77a699ded?w=400',
      'Arms': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
      'Shoulders': 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
      'Core': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'Cardio': 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=400',
    };
    return muscleImages[muscleGroup] ??
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400';
  }
}