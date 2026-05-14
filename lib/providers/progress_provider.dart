import 'package:flutter/material.dart';
import '../models/progress_model.dart';
import '../models/workout_log_model.dart';
import '../services/firestore_service.dart';

class ProgressProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
 final  List<WeightLogModel> _weightLogs = [];
 final  List<BodyMeasurementModel> _measurements = [];
 final  List<PersonalRecordModel> _personalRecords = [];
  List<WorkoutLogModel> _workoutLogs = [];
  bool _isLoading = false;
  String? _error;

  List<WeightLogModel> get weightLogs => _weightLogs;
  List<BodyMeasurementModel> get measurements => _measurements;
  List<PersonalRecordModel> get personalRecords => _personalRecords;
  List<WorkoutLogModel> get workoutLogs => _workoutLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double? get latestWeight => _weightLogs.isNotEmpty ? _weightLogs.first.weight : null;
  double? get startingWeight => _weightLogs.isNotEmpty ? _weightLogs.last.weight : null;
  
  double? get weightChange {
    if (_weightLogs.length < 2) return null;
    return _weightLogs.first.weight - _weightLogs.last.weight;
  }

  int get totalWorkouts => _workoutLogs.length;
  int get totalWorkoutMinutes => _workoutLogs.fold(0, (sum, log) => sum + log.duration ~/ 60);
  double get totalCaloriesBurned => _workoutLogs.fold(0, (sum, log) => sum + log.caloriesBurned);

  Future<void> loadProgressData(String uid) async {
    _setLoading(true);
    try {
      _workoutLogs = await _firestoreService.getWorkoutLogs(uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addWeightLog(String uid, WeightLogModel log) async {
    _setLoading(true);
    try {
      await _firestoreService.addWeightLog(uid, log);
      _weightLogs.insert(0, log);
      _weightLogs.sort((a, b) => b.date.compareTo(a.date));
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addMeasurement(String uid, BodyMeasurementModel measurement) async {
    _setLoading(true);
    try {
      await _firestoreService.addMeasurement(uid, measurement);
      _measurements.insert(0, measurement);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> updatePersonalRecord(String uid, PersonalRecordModel record) async {
    _setLoading(true);
    try {
      await _firestoreService.updatePersonalRecord(uid, record);
      final existingIndex = _personalRecords.indexWhere((r) => r.exerciseId == record.exerciseId);
      if (existingIndex >= 0) {
        _personalRecords[existingIndex] = record;
      } else {
        _personalRecords.add(record);
      }
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