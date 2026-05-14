import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final double height;
  final double weight;
  final int age;
  final String gender;
  final String fitnessGoal;
  final double bmi;
  final String bmiCategory;
  final double dailyCalorieGoal;
  final int currentStreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.fitnessGoal,
    required this.bmi,
    required this.bmiCategory,
    required this.dailyCalorieGoal,
    this.currentStreak = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'male',
      fitnessGoal: json['fitnessGoal'] ?? 'maintain',
      bmi: (json['bmi'] ?? 0).toDouble(),
      bmiCategory: json['bmiCategory'] ?? 'Normal',
      dailyCalorieGoal: (json['dailyCalorieGoal'] ?? 0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'fitnessGoal': fitnessGoal,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'dailyCalorieGoal': dailyCalorieGoal,
      'currentStreak': currentStreak,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? fitnessGoal,
    double? bmi,
    String? bmiCategory,
    double? dailyCalorieGoal,
    int? currentStreak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      currentStreak: currentStreak ?? this.currentStreak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}