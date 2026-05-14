class MealModel {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime date;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.mealType,
    required this.date,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      mealType: json['mealType'] ?? 'snack',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType,
      'date': date.toIso8601String(),
    };
  }
}