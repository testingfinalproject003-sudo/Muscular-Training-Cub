import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_log_model.dart';
import '../models/progress_model.dart';
// import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER ====================
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update({
      ...user.toJson(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<UserModel?> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
      (snapshot) => snapshot.exists
          ? UserModel.fromJson(snapshot.data()!)
          : null,
    );
  }

  // ==================== WORKOUTS ====================
  Future<void> saveWorkout(String uid, WorkoutModel workout) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(workout.id)
        .set(workout.toJson());
  }

  Future<List<WorkoutModel>> getWorkouts(String uid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => WorkoutModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<WorkoutModel>> streamWorkouts(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> deleteWorkout(String uid, String workoutId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }

  // ==================== WORKOUT LOGS ====================
  Future<void> saveWorkoutLog(String uid, WorkoutLogModel log) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .doc(log.id)
        .set(log.toJson());
  }

  Stream<List<WorkoutLogModel>> streamWorkoutLogs(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutLogModel.fromJson(doc.data()))
            .toList());
  }

  Future<List<WorkoutLogModel>> getWorkoutLogs(String uid, {int limit = 50}) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => WorkoutLogModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ==================== WEIGHT LOGS ====================
  Future<void> addWeightLog(String uid, WeightLogModel log) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('weightLogs')
        .doc(log.id)
        .set(log.toJson());
  }

  Stream<List<WeightLogModel>> streamWeightLogs(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('weightLogs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeightLogModel.fromJson(doc.data()))
            .toList());
  }

  // ==================== MEASUREMENTS ====================
  Future<void> addMeasurement(String uid, BodyMeasurementModel measurement) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('measurements')
        .doc(measurement.id)
        .set(measurement.toJson());
  }

  Stream<List<BodyMeasurementModel>> streamMeasurements(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('measurements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BodyMeasurementModel.fromJson(doc.data()))
            .toList());
  }

  // ==================== WATER LOGS ====================
  Future<void> updateWaterLog(String uid, String date, int cups, int ml) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('waterLogs')
        .doc(date)
        .set({'cups': cups, 'ml': ml, 'date': date});
  }

  Stream<Map<String, dynamic>?> streamWaterLog(String uid, String date) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('waterLogs')
        .doc(date)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  // ==================== PERSONAL RECORDS ====================
  Future<void> updatePersonalRecord(String uid, PersonalRecordModel record) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('personalRecords')
        .doc(record.exerciseId)
        .set(record.toJson());
  }

  Stream<List<PersonalRecordModel>> streamPersonalRecords(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('personalRecords')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PersonalRecordModel.fromJson(doc.data()))
            .toList());
  }

  // ==================== EXERCISE LIBRARY ====================
  Future<void> addCustomExercise(String uid, ExerciseModel exercise) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('customExercises')
        .doc(exercise.id)
        .set(exercise.toJson());
  }

  Future<List<ExerciseModel>> getCustomExercises(String uid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('customExercises')
        .get();
    
    return snapshot.docs
        .map((doc) => ExerciseModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}