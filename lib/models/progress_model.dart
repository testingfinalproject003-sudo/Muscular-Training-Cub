import 'package:cloud_firestore/cloud_firestore.dart';

class WeightLogModel {
  final String id;
  final DateTime date;
  final double weight;
  final String? notes;

  WeightLogModel({
    required this.id,
    required this.date,
    required this.weight,
    this.notes,
  });

  factory WeightLogModel.fromJson(Map<String, dynamic> json) {
    return WeightLogModel(
      id: json['id'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weight: (json['weight'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'notes': notes,
    };
  }
}

class BodyMeasurementModel {
  final String id;
  final DateTime date;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? arms;
  final double? thighs;

  BodyMeasurementModel({
    required this.id,
    required this.date,
    this.chest,
    this.waist,
    this.hips,
    this.arms,
    this.thighs,
  });

  factory BodyMeasurementModel.fromJson(Map<String, dynamic> json) {
    return BodyMeasurementModel(
      id: json['id'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      arms: json['arms']?.toDouble(),
      thighs: json['thighs']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'arms': arms,
      'thighs': thighs,
    };
  }
}

class PersonalRecordModel {
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime date;

  PersonalRecordModel({
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.date,
  });

  factory PersonalRecordModel.fromJson(Map<String, dynamic> json) {
    return PersonalRecordModel(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      reps: json['reps'] ?? 0,
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'date': Timestamp.fromDate(date),
    };
  }
}