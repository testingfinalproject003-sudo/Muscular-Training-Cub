import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final int setsCompleted;
  final int repsPerSet;
  final double weightUsed;
  final int duration; // seconds
  final double caloriesBurned;

  ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsPerSet,
    this.weightUsed = 0,
    required this.duration,
    required this.caloriesBurned,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      setsCompleted: json['setsCompleted'] ?? 0,
      repsPerSet: json['repsPerSet'] ?? 0,
      weightUsed: (json['weightUsed'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      caloriesBurned: (json['caloriesBurned'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setsCompleted': setsCompleted,
      'repsPerSet': repsPerSet,
      'weightUsed': weightUsed,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
    };
  }
}

class WorkoutLogModel {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime date;
  final int duration; // total seconds
  final int setsCompleted;
  final double caloriesBurned;
  final String? notes;
  final List<ExerciseLog> exerciseLogs;

  WorkoutLogModel({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.date,
    required this.duration,
    required this.setsCompleted,
    required this.caloriesBurned,
    this.notes,
    required this.exerciseLogs,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      id: json['id'] ?? '',
      workoutId: json['workoutId'] ?? '',
      workoutName: json['workoutName'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: json['duration'] ?? 0,
      setsCompleted: json['setsCompleted'] ?? 0,
      caloriesBurned: (json['caloriesBurned'] ?? 0).toDouble(),
      notes: json['notes'],
      exerciseLogs: (json['exerciseLogs'] as List?)
          ?.map((e) => ExerciseLog.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'setsCompleted': setsCompleted,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'exerciseLogs': exerciseLogs.map((e) => e.toJson()).toList(),
    };
  }
}