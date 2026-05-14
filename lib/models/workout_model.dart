import 'exercise_model.dart';

class WorkoutModel {
  final String id;
  final String name;
  final List<String> muscleGroups;
  final List<ExerciseModel> exercises;
  final List<int> scheduledDays; // 0=Mon, 6=Sun
  final int estimatedDuration; // minutes
  final double estimatedCalories;
  final bool isCustom;
  final DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.exercises,
    required this.scheduledDays,
    required this.estimatedDuration,
    required this.estimatedCalories,
    this.isCustom = false,
    required this.createdAt,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      exercises: (json['exercises'] as List?)
          ?.map((e) => ExerciseModel.fromJson(e))
          .toList() ?? [],
      scheduledDays: List<int>.from(json['scheduledDays'] ?? []),
      estimatedDuration: json['estimatedDuration'] ?? 45,
      estimatedCalories: (json['estimatedCalories'] ?? 0).toDouble(),
      isCustom: json['isCustom'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroups': muscleGroups,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'scheduledDays': scheduledDays,
      'estimatedDuration': estimatedDuration,
      'estimatedCalories': estimatedCalories,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WorkoutModel copyWith({
    String? id,
    String? name,
    List<String>? muscleGroups,
    List<ExerciseModel>? exercises,
    List<int>? scheduledDays,
    int? estimatedDuration,
    double? estimatedCalories,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      exercises: exercises ?? this.exercises,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}