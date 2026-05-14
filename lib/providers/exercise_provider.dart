import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../services/firestore_service.dart';

class ExerciseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ExerciseModel> _customExercises = [];
  bool _isLoading = false;
  String? _error;

  List<ExerciseModel> get customExercises => _customExercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomExercises(String uid) async {
    _setLoading(true);
    try {
      _customExercises = await _firestoreService.getCustomExercises(uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addCustomExercise(String uid, ExerciseModel exercise) async {
    _setLoading(true);
    try {
      await _firestoreService.addCustomExercise(uid, exercise);
      _customExercises.add(exercise);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}