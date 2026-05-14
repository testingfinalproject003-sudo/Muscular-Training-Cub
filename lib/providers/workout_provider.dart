import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../services/firestore_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<WorkoutModel> _workouts = [];
  List<ExerciseModel> _exercises = [];
  bool _isLoading = false;
  String? _error;

  List<WorkoutModel> get workouts => _workouts;
  List<ExerciseModel> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WorkoutProvider() {
    _loadBuiltInExercises();
    _loadPrebuiltPlans();
  }

  void _loadBuiltInExercises() {
    _exercises = _getBuiltInExercises();
  }

  void _loadPrebuiltPlans() {
    _workouts = _getPrebuiltPlans();
  }

  Future<void> loadWorkouts(String uid) async {
    _setLoading(true);
    try {
      final userWorkouts = await _firestoreService.getWorkouts(uid);
      // Merge prebuilt + user custom workouts
      _workouts = [..._getPrebuiltPlans(), ...userWorkouts];
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addWorkout(String uid, WorkoutModel workout) async {
    _setLoading(true);
    try {
      await _firestoreService.saveWorkout(uid, workout);
      _workouts.insert(0, workout);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> deleteWorkout(String uid, String workoutId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteWorkout(uid, workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  List<WorkoutModel> getWorkoutsForDay(int dayIndex) {
    return _workouts.where((w) => w.scheduledDays.contains(dayIndex)).toList();
  }

  List<ExerciseModel> getExercisesByMuscleGroup(String muscleGroup) {
    return _exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  ExerciseModel? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  List<WorkoutModel> getPrebuiltPlansByGoal(String goal) {
    return _workouts.where((w) => w.id.startsWith(goal)).toList();
  }

  /// Add exercise to existing workout (from Exercise Library)
  Future<void> addExerciseToWorkout(String uid, String workoutId, ExerciseModel exercise) async {
    _setLoading(true);
    try {
      final workoutIndex = _workouts.indexWhere((w) => w.id == workoutId);
      if (workoutIndex == -1) throw Exception('Workout not found');

      final workout = _workouts[workoutIndex];
      final updatedExercises = [...workout.exercises, exercise];
      
      // Recalculate estimates
      final totalDuration = updatedExercises.fold<int>(
        0,
        (sum, e) => sum + ((e.duration ?? 300) * e.sets ~/ 60) + (e.sets * 60 ~/ 60),
      );
      final totalCalories = updatedExercises.fold<double>(
        0,
        (sum, e) => sum + (e.caloriesPerMinute * ((e.duration ?? 300) * e.sets / 60)),
      );

      final updatedWorkout = workout.copyWith(
        exercises: updatedExercises,
        estimatedDuration: totalDuration,
        estimatedCalories: totalCalories,
      );

      await _firestoreService.saveWorkout(uid, updatedWorkout);
      _workouts[workoutIndex] = updatedWorkout;
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

  List<ExerciseModel> _getBuiltInExercises() {
    return [
      // ========== CHEST ==========
      ExerciseModel(id: 'c1', name: 'Barbell Bench Press', muscleGroup: 'Chest', primaryMuscle: 'Pectoralis Major', sets: 4, reps: '8-12', caloriesPerMinute: 8, difficulty: 4, description: 'Lie on a flat bench, grip the bar slightly wider than shoulder-width, lower to chest, press up.', tips: 'Keep feet flat on floor, retract shoulder blades, controlled descent.'),
      ExerciseModel(id: 'c2', name: 'Incline Dumbbell Press', muscleGroup: 'Chest', primaryMuscle: 'Upper Chest', sets: 3, reps: '10-12', caloriesPerMinute: 7, difficulty: 3, description: 'Set bench to 30-45 degrees, press dumbbells from chest to full extension.', tips: 'Focus on squeezing upper chest at top, controlled movement.'),
      ExerciseModel(id: 'c3', name: 'Decline Push-Up', muscleGroup: 'Chest', primaryMuscle: 'Lower Chest', sets: 3, reps: '15', caloriesPerMinute: 6, difficulty: 3, description: 'Feet elevated on bench, hands on floor, push up focusing on lower chest.', tips: 'Keep body straight, lower chest to floor, explode up.'),
      ExerciseModel(id: 'c4', name: 'Cable Crossover', muscleGroup: 'Chest', primaryMuscle: 'Chest Isolation', sets: 3, reps: '12', caloriesPerMinute: 6, difficulty: 3, description: 'Stand between cable machines, bring handles together in front of chest.', tips: 'Slight bend in elbows, squeeze chest at peak contraction.'),
      ExerciseModel(id: 'c5', name: 'Dumbbell Flyes', muscleGroup: 'Chest', primaryMuscle: 'Chest Stretch', sets: 3, reps: '12', caloriesPerMinute: 6, difficulty: 3, description: 'Lie on bench, arms extended with dumbbells, lower in arc motion.', tips: 'Feel the stretch, do not go too deep to protect shoulders.'),
      ExerciseModel(id: 'c6', name: 'Push-Up', muscleGroup: 'Chest', primaryMuscle: 'Full Chest', sets: 4, reps: '20', caloriesPerMinute: 7, difficulty: 2, description: 'Classic bodyweight exercise. Hands shoulder-width, lower chest to floor.', tips: 'Keep core tight, full range of motion.'),
      ExerciseModel(id: 'c7', name: 'Chest Dip', muscleGroup: 'Chest', primaryMuscle: 'Lower Pecs', sets: 3, reps: '12', caloriesPerMinute: 8, difficulty: 4, description: 'Lean forward on dip bars, lower until shoulders below elbows, push up.', tips: 'Lean forward to target chest, not triceps.'),
      ExerciseModel(id: 'c8', name: 'Pec Deck Machine', muscleGroup: 'Chest', primaryMuscle: 'Chest Isolation', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Sit facing machine, bring handles together squeezing chest.', tips: 'Keep elbows slightly bent, focus on contraction.'),
      ExerciseModel(id: 'c9', name: 'Landmine Press', muscleGroup: 'Chest', primaryMuscle: 'Upper Chest', sets: 3, reps: '10', caloriesPerMinute: 7, difficulty: 3, description: 'Press barbell end upward from chest level using landmine attachment.', tips: 'Keep core engaged, press at slight upward angle.'),
      ExerciseModel(id: 'c10', name: 'Svend Press', muscleGroup: 'Chest', primaryMuscle: 'Inner Chest', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Press palms together with plate, extend arms squeezing inner chest.', tips: 'Focus on squeezing inner chest throughout movement.'),

      // ========== BACK ==========
      ExerciseModel(id: 'b1', name: 'Deadlift', muscleGroup: 'Back', primaryMuscle: 'Entire Back', sets: 4, reps: '6', caloriesPerMinute: 10, difficulty: 5, description: 'Lift barbell from floor to hip level with straight back.', tips: 'Keep back neutral, drive through heels, engage lats.'),
      ExerciseModel(id: 'b2', name: 'Pull-Up', muscleGroup: 'Back', primaryMuscle: 'Lats', sets: 3, reps: '8', caloriesPerMinute: 8, difficulty: 4, description: 'Hang from bar, pull body up until chin over bar.', tips: 'Full range of motion, controlled descent, engage lats.'),
      ExerciseModel(id: 'b3', name: 'Barbell Row', muscleGroup: 'Back', primaryMuscle: 'Mid Back', sets: 4, reps: '8-10', caloriesPerMinute: 8, difficulty: 4, description: 'Bend at hips, pull barbell to lower chest/upper abs.', tips: 'Keep back flat, pull to lower chest, squeeze shoulder blades.'),
      ExerciseModel(id: 'b4', name: 'Lat Pulldown', muscleGroup: 'Back', primaryMuscle: 'Latissimus Dorsi', sets: 3, reps: '12', caloriesPerMinute: 7, difficulty: 3, description: 'Pull bar down to upper chest while seated.', tips: 'Lean back slightly, pull with elbows not hands.'),
      ExerciseModel(id: 'b5', name: 'Seated Cable Row', muscleGroup: 'Back', primaryMuscle: 'Rhomboids', sets: 3, reps: '12', caloriesPerMinute: 6, difficulty: 3, description: 'Sit at cable row machine, pull handles to midsection.', tips: 'Squeeze shoulder blades, controlled return.'),
      ExerciseModel(id: 'b6', name: 'Single Arm DB Row', muscleGroup: 'Back', primaryMuscle: 'Lats+Rhomboids', sets: 3, reps: '10', caloriesPerMinute: 7, difficulty: 3, description: 'One knee on bench, pull dumbbell to hip.', tips: 'Keep back parallel to floor, pull to hip not chest.'),
      ExerciseModel(id: 'b7', name: 'T-Bar Row', muscleGroup: 'Back', primaryMuscle: 'Thickness', sets: 3, reps: '10', caloriesPerMinute: 8, difficulty: 4, description: 'Straddle T-bar, pull weight to chest.', tips: 'Keep chest supported, pull with elbows back.'),
      ExerciseModel(id: 'b8', name: 'Face Pull', muscleGroup: 'Back', primaryMuscle: 'Rear Delts+Traps', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Pull rope to face level, external rotation at end.', tips: 'Pull apart at face, external rotate, squeeze rear delts.'),
      ExerciseModel(id: 'b9', name: 'Good Morning', muscleGroup: 'Back', primaryMuscle: 'Erector Spinae', sets: 3, reps: '12', caloriesPerMinute: 6, difficulty: 3, description: 'Barbell on shoulders, hinge at hips keeping legs straight.', tips: 'Keep back straight, feel stretch in hamstrings.'),
      ExerciseModel(id: 'b10', name: 'Hyperextension', muscleGroup: 'Back', primaryMuscle: 'Lower Back', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'On hyperextension bench, lower torso then raise to parallel.', tips: 'Do not hyperextend, controlled movement.'),

      // ========== LEGS ==========
      ExerciseModel(id: 'l1', name: 'Barbell Squat', muscleGroup: 'Legs', primaryMuscle: 'Quads+Glutes', sets: 4, reps: '8', caloriesPerMinute: 10, difficulty: 5, description: 'Barbell on shoulders, squat down to parallel, drive up.', tips: 'Keep chest up, knees track over toes, drive through heels.'),
      ExerciseModel(id: 'l2', name: 'Romanian Deadlift', muscleGroup: 'Legs', primaryMuscle: 'Hamstrings', sets: 3, reps: '10', caloriesPerMinute: 9, difficulty: 4, description: 'Hold barbell, hinge at hips lowering bar along legs.', tips: 'Slight knee bend, feel hamstring stretch, keep bar close.'),
      ExerciseModel(id: 'l3', name: 'Leg Press', muscleGroup: 'Legs', primaryMuscle: 'Quads', sets: 4, reps: '12', caloriesPerMinute: 8, difficulty: 3, description: 'Sit in leg press machine, press weight away.', tips: 'Do not lock knees, full range without rounding lower back.'),
      ExerciseModel(id: 'l4', name: 'Walking Lunge', muscleGroup: 'Legs', primaryMuscle: 'Glutes+Quads', sets: 3, reps: '12/leg', caloriesPerMinute: 8, difficulty: 3, description: 'Step forward into lunge, alternate legs walking.', tips: 'Keep torso upright, back knee close to floor.'),
      ExerciseModel(id: 'l5', name: 'Leg Curl', muscleGroup: 'Legs', primaryMuscle: 'Hamstrings', sets: 3, reps: '12', caloriesPerMinute: 6, difficulty: 2, description: 'Lie on leg curl machine, curl heels to glutes.', tips: 'Keep hips down, squeeze hamstrings at top.'),
      ExerciseModel(id: 'l6', name: 'Leg Extension', muscleGroup: 'Legs', primaryMuscle: 'Quads Isolation', sets: 3, reps: '15', caloriesPerMinute: 6, difficulty: 2, description: 'Sit in extension machine, extend legs straight.', tips: 'Do not lock knees, squeeze quads at top.'),
      ExerciseModel(id: 'l7', name: 'Bulgarian Split Squat', muscleGroup: 'Legs', primaryMuscle: 'Quads+Glutes', sets: 3, reps: '10', caloriesPerMinute: 8, difficulty: 4, description: 'Rear foot elevated on bench, lower into deep lunge.', tips: 'Keep front knee stable, deep stretch, drive up.'),
      ExerciseModel(id: 'l8', name: 'Calf Raise', muscleGroup: 'Legs', primaryMuscle: 'Gastrocnemius', sets: 4, reps: '20', caloriesPerMinute: 5, difficulty: 2, description: 'Raise heels as high as possible, lower slowly.', tips: 'Full stretch at bottom, pause at top contraction.'),
      ExerciseModel(id: 'l9', name: 'Hack Squat', muscleGroup: 'Legs', primaryMuscle: 'Quads', sets: 3, reps: '10', caloriesPerMinute: 9, difficulty: 4, description: 'Machine squat with back supported, feet forward on platform.', tips: 'Focus on quads, controlled descent.'),
      ExerciseModel(id: 'l10', name: 'Glute Bridge', muscleGroup: 'Legs', primaryMuscle: 'Glutes', sets: 3, reps: '15', caloriesPerMinute: 6, difficulty: 2, description: 'Lie on back, feet flat, thrust hips up squeezing glutes.', tips: 'Squeeze glutes hard at top, do not overarch back.'),

      // ========== ARMS ==========
      ExerciseModel(id: 'a1', name: 'Barbell Curl', muscleGroup: 'Arms', primaryMuscle: 'Biceps', sets: 3, reps: '10', caloriesPerMinute: 6, difficulty: 3, description: 'Curl barbell from hip to shoulder level.', tips: 'Keep elbows fixed, do not swing, squeeze at top.'),
      ExerciseModel(id: 'a2', name: 'Tricep Pushdown', muscleGroup: 'Arms', primaryMuscle: 'Triceps', sets: 3, reps: '12', caloriesPerMinute: 6, difficulty: 2, description: 'Push cable bar down until arms fully extended.', tips: 'Keep elbows at sides, fully extend, squeeze triceps.'),
      ExerciseModel(id: 'a3', name: 'Hammer Curl', muscleGroup: 'Arms', primaryMuscle: 'Brachialis', sets: 3, reps: '12', caloriesPerMinute: 5, difficulty: 2, description: 'Curl dumbbells with neutral grip (palms facing).', tips: 'Neutral grip targets brachialis, keep elbows fixed.'),
      ExerciseModel(id: 'a4', name: 'Skull Crusher', muscleGroup: 'Arms', primaryMuscle: 'Triceps Long', sets: 3, reps: '10', caloriesPerMinute: 6, difficulty: 3, description: 'Lie on bench, lower barbell to forehead, extend arms.', tips: 'Keep upper arms still, lower to forehead not face.'),
      ExerciseModel(id: 'a5', name: 'Incline DB Curl', muscleGroup: 'Arms', primaryMuscle: 'Biceps Peak', sets: 3, reps: '12', caloriesPerMinute: 5, difficulty: 3, description: 'Sit on incline bench, curl dumbbells with arms behind body.', tips: 'Feel stretch at bottom, peak contraction at top.'),
      ExerciseModel(id: 'a6', name: 'Close-Grip Bench', muscleGroup: 'Arms', primaryMuscle: 'Triceps', sets: 3, reps: '10', caloriesPerMinute: 7, difficulty: 4, description: 'Bench press with narrow grip focusing on triceps.', tips: 'Elbows tucked, lower to lower chest, press with triceps.'),
      ExerciseModel(id: 'a7', name: 'Concentration Curl', muscleGroup: 'Arms', primaryMuscle: 'Biceps Isolation', sets: 3, reps: '12', caloriesPerMinute: 5, difficulty: 2, description: 'Sit on bench, elbow on inner thigh, curl dumbbell.', tips: 'Isolate biceps, no swinging, peak squeeze.'),
      ExerciseModel(id: 'a8', name: 'Overhead Tricep Ext', muscleGroup: 'Arms', primaryMuscle: 'Long Head', sets: 3, reps: '12', caloriesPerMinute: 5, difficulty: 2, description: 'Hold dumbbell overhead, lower behind head, extend.', tips: 'Keep elbows close to head, full stretch at bottom.'),
      ExerciseModel(id: 'a9', name: 'Preacher Curl', muscleGroup: 'Arms', primaryMuscle: 'Lower Biceps', sets: 3, reps: '10', caloriesPerMinute: 5, difficulty: 3, description: 'Curl on preacher bench with arms supported.', tips: 'Full stretch at bottom, no swinging, controlled.'),
      ExerciseModel(id: 'a10', name: 'Diamond Push-Up', muscleGroup: 'Arms', primaryMuscle: 'Triceps', sets: 3, reps: '15', caloriesPerMinute: 6, difficulty: 3, description: 'Hands close forming diamond, push up targeting triceps.', tips: 'Keep elbows tucked, lower chest to hands.'),

      // ========== SHOULDERS ==========
      ExerciseModel(id: 's1', name: 'Overhead Press', muscleGroup: 'Shoulders', primaryMuscle: 'Anterior Delt', sets: 4, reps: '8', caloriesPerMinute: 8, difficulty: 4, description: 'Press barbell from shoulder to overhead.', tips: 'Brace core, press straight up, do not arch back.'),
      ExerciseModel(id: 's2', name: 'Lateral Raise', muscleGroup: 'Shoulders', primaryMuscle: 'Medial Delt', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Raise dumbbells to sides until parallel with floor.', tips: 'Slight bend in elbows, lead with elbows not hands.'),
      ExerciseModel(id: 's3', name: 'Front Raise', muscleGroup: 'Shoulders', primaryMuscle: 'Anterior Delt', sets: 3, reps: '12', caloriesPerMinute: 5, difficulty: 2, description: 'Raise dumbbells to front until parallel with floor.', tips: 'Control the weight, do not swing, alternate arms.'),
      ExerciseModel(id: 's4', name: 'Arnold Press', muscleGroup: 'Shoulders', primaryMuscle: 'All 3 Heads', sets: 3, reps: '10', caloriesPerMinute: 7, difficulty: 3, description: 'Start with palms facing you, rotate and press overhead.', tips: 'Smooth rotation, full range of motion, controlled.'),
      ExerciseModel(id: 's5', name: 'Upright Row', muscleGroup: 'Shoulders', primaryMuscle: 'Traps+Delts', sets: 3, reps: '12', caloriesPerMinute: 6, difficulty: 3, description: 'Pull barbell up to chin level keeping close to body.', tips: 'Lead with elbows, do not go too high to protect shoulders.'),
      ExerciseModel(id: 's6', name: 'Rear Delt Fly', muscleGroup: 'Shoulders', primaryMuscle: 'Posterior Delt', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Bend over, raise dumbbells to sides squeezing rear delts.', tips: 'Slight bend in elbows, squeeze rear delts, controlled.'),
      ExerciseModel(id: 's7', name: 'Shrug', muscleGroup: 'Shoulders', primaryMuscle: 'Trapezius', sets: 4, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Hold weights, shrug shoulders up to ears.', tips: 'Hold at top, do not roll shoulders, straight up and down.'),
      ExerciseModel(id: 's8', name: 'Push Press', muscleGroup: 'Shoulders', primaryMuscle: 'Explosive Delt', sets: 3, reps: '8', caloriesPerMinute: 8, difficulty: 4, description: 'Use leg drive to help press barbell overhead.', tips: 'Dip and drive, explosive press, control descent.'),
      ExerciseModel(id: 's9', name: 'Cable Lateral Raise', muscleGroup: 'Shoulders', primaryMuscle: 'Medial Delt', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Use cable for constant tension lateral raise.', tips: 'Constant tension, lead with elbow, controlled.'),
      ExerciseModel(id: 's10', name: 'Face Pull', muscleGroup: 'Shoulders', primaryMuscle: 'Rear+Rotator Cuff', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Pull rope to face, external rotate at end.', tips: 'High elbows, external rotation, squeeze rear delts.'),

      // ========== CORE ==========
      ExerciseModel(id: 'co1', name: 'Plank', muscleGroup: 'Core', primaryMuscle: 'Transverse Abs', sets: 3, reps: '60s', duration: 60, caloriesPerMinute: 4, difficulty: 2, description: 'Hold push-up position on forearms, keep body straight.', tips: 'Brace core, do not let hips sag, breathe normally.'),
      ExerciseModel(id: 'co2', name: 'Crunch', muscleGroup: 'Core', primaryMuscle: 'Rectus Abdominis', sets: 3, reps: '20', caloriesPerMinute: 5, difficulty: 1, description: 'Lie on back, curl shoulders off floor squeezing abs.', tips: 'Do not pull neck, focus on curling with abs.'),
      ExerciseModel(id: 'co3', name: 'Russian Twist', muscleGroup: 'Core', primaryMuscle: 'Obliques', sets: 3, reps: '20', caloriesPerMinute: 5, difficulty: 2, description: 'Sit with feet up, twist torso side to side.', tips: 'Keep feet elevated, twist with core not arms.'),
      ExerciseModel(id: 'co4', name: 'Leg Raise', muscleGroup: 'Core', primaryMuscle: 'Lower Abs', sets: 3, reps: '15', caloriesPerMinute: 5, difficulty: 2, description: 'Lie on back, raise legs to 90 degrees, lower controlled.', tips: 'Keep lower back pressed to floor, controlled descent.'),
      ExerciseModel(id: 'co5', name: 'Mountain Climber', muscleGroup: 'Core', primaryMuscle: 'Core+Cardio', sets: 3, reps: '45s', duration: 45, caloriesPerMinute: 9, difficulty: 3, description: 'Plank position, alternate driving knees to chest rapidly.', tips: 'Keep hips low, fast pace, core engaged.'),
      ExerciseModel(id: 'co6', name: 'Ab Wheel Rollout', muscleGroup: 'Core', primaryMuscle: 'Deep Core', sets: 3, reps: '10', caloriesPerMinute: 6, difficulty: 4, description: 'Kneel, roll wheel forward extending body, pull back.', tips: 'Do not arch back, controlled rollout, engage core.'),
      ExerciseModel(id: 'co7', name: 'Side Plank', muscleGroup: 'Core', primaryMuscle: 'Obliques', sets: 3, reps: '45s/side', duration: 45, caloriesPerMinute: 4, difficulty: 3, description: 'Support body on one forearm, keep body straight.', tips: 'Stack feet or stagger, do not let hips drop.'),
      ExerciseModel(id: 'co8', name: 'Bicycle Crunch', muscleGroup: 'Core', primaryMuscle: 'Obliques+Rectus', sets: 3, reps: '20', caloriesPerMinute: 6, difficulty: 2, description: 'Alternate elbow to opposite knee in cycling motion.', tips: 'Rotate with core, extend leg fully, controlled.'),
      ExerciseModel(id: 'co9', name: 'Dragon Flag', muscleGroup: 'Core', primaryMuscle: 'Full Core', sets: 3, reps: '8', caloriesPerMinute: 7, difficulty: 5, description: 'Lie on bench, hold behind head, raise and lower body.', tips: 'Advanced move, keep body straight, do not bend hips.'),
      ExerciseModel(id: 'co10', name: 'Dead Bug', muscleGroup: 'Core', primaryMuscle: 'Stabilization', sets: 3, reps: '10', caloriesPerMinute: 4, difficulty: 2, description: 'Lie on back, extend opposite arm and leg, return.', tips: 'Keep lower back flat, slow and controlled movement.'),

      // ========== CARDIO ==========
      ExerciseModel(id: 'cd1', name: 'Treadmill Run', muscleGroup: 'Cardio', primaryMuscle: 'Full Body', sets: 1, reps: '30min', duration: 1800, caloriesPerMinute: 11, difficulty: 3, description: 'Run on treadmill at moderate to high intensity.', tips: 'Maintain steady pace, use incline for variation.'),
      ExerciseModel(id: 'cd2', name: 'Jump Rope', muscleGroup: 'Cardio', primaryMuscle: 'Full Body', sets: 1, reps: '15min', duration: 900, caloriesPerMinute: 13, difficulty: 3, description: 'Jump rope continuously at steady rhythm.', tips: 'Stay on balls of feet, wrists rotate rope, relax shoulders.'),
      ExerciseModel(id: 'cd3', name: 'Cycling', muscleGroup: 'Cardio', primaryMuscle: 'Legs+Cardio', sets: 1, reps: '30min', duration: 1800, caloriesPerMinute: 9, difficulty: 2, description: 'Ride stationary bike or cycle outdoors.', tips: 'Maintain cadence, adjust resistance, keep posture.'),
      ExerciseModel(id: 'cd4', name: 'Burpees', muscleGroup: 'Cardio', primaryMuscle: 'Full Body', sets: 5, reps: '10', caloriesPerMinute: 14, difficulty: 4, description: 'Squat, jump back to plank, push-up, jump forward, jump up.', tips: 'Explosive movement, full range, land softly.'),
      ExerciseModel(id: 'cd5', name: 'Box Jump', muscleGroup: 'Cardio', primaryMuscle: 'Legs+Explosive', sets: 4, reps: '10', caloriesPerMinute: 12, difficulty: 4, description: 'Jump onto box from squat position, step down.', tips: 'Land softly with full feet, stand tall at top.'),
      ExerciseModel(id: 'cd6', name: 'Rowing Machine', muscleGroup: 'Cardio', primaryMuscle: 'Back+Legs+Cardio', sets: 1, reps: '20min', duration: 1200, caloriesPerMinute: 10, difficulty: 3, description: 'Row with legs, back, and arms in sequence.', tips: 'Legs first, then back, then arms. Smooth rhythm.'),
      ExerciseModel(id: 'cd7', name: 'Jumping Jacks', muscleGroup: 'Cardio', primaryMuscle: 'Full Body', sets: 1, reps: '10min', duration: 600, caloriesPerMinute: 8, difficulty: 1, description: 'Jump feet apart and together while raising arms.', tips: 'Light on feet, full arm movement, steady pace.'),
      ExerciseModel(id: 'cd8', name: 'Sprint Intervals', muscleGroup: 'Cardio', primaryMuscle: 'Full Body', sets: 8, reps: '30s on/30s off', duration: 30, caloriesPerMinute: 15, difficulty: 5, description: 'Sprint 30 seconds, rest 30 seconds, repeat.', tips: 'All-out effort on sprints, full recovery between.'),
      ExerciseModel(id: 'cd9', name: 'Stair Climber', muscleGroup: 'Cardio', primaryMuscle: 'Legs+Cardio', sets: 1, reps: '20min', duration: 1200, caloriesPerMinute: 10, difficulty: 3, description: 'Continuously climb stairs on machine.', tips: 'Stand upright, full steps, do not lean on rails.'),
      ExerciseModel(id: 'cd10', name: 'Battle Ropes', muscleGroup: 'Cardio', primaryMuscle: 'Arms+Core+Cardio', sets: 5, reps: '30s', duration: 30, caloriesPerMinute: 13, difficulty: 4, description: 'Create waves with heavy ropes attached to anchor.', tips: 'Generate power from core, maintain rhythm, stay low.'),
    ];
  }

  List<WorkoutModel> _getPrebuiltPlans() {
    final exercises = _getBuiltInExercises();

    ExerciseModel getEx(String id) => exercises.firstWhere((e) => e.id == id);

    return [
      // ===== GAIN MUSCLE PLANS =====
      WorkoutModel(
        id: 'gain_chest',
        name: 'Mass Builder: Chest',
        muscleGroups: ['Chest'],
        exercises: [getEx('c1'), getEx('c2'), getEx('c7'), getEx('c5'), getEx('c6')],
        scheduledDays: [0, 3],
        estimatedDuration: 55,
        estimatedCalories: 420,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'gain_back',
        name: 'Mass Builder: Back',
        muscleGroups: ['Back'],
        exercises: [getEx('b1'), getEx('b2'), getEx('b3'), getEx('b4'), getEx('b6')],
        scheduledDays: [1, 4],
        estimatedDuration: 60,
        estimatedCalories: 480,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'gain_legs',
        name: 'Mass Builder: Legs',
        muscleGroups: ['Legs'],
        exercises: [getEx('l1'), getEx('l2'), getEx('l3'), getEx('l7'), getEx('l8')],
        scheduledDays: [2, 5],
        estimatedDuration: 65,
        estimatedCalories: 520,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'gain_arms',
        name: 'Mass Builder: Arms',
        muscleGroups: ['Arms'],
        exercises: [getEx('a1'), getEx('a2'), getEx('a3'), getEx('a4'), getEx('a6')],
        scheduledDays: [3, 6],
        estimatedDuration: 45,
        estimatedCalories: 340,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'gain_shoulders',
        name: 'Mass Builder: Shoulders',
        muscleGroups: ['Shoulders'],
        exercises: [getEx('s1'), getEx('s2'), getEx('s4'), getEx('s7'), getEx('s8')],
        scheduledDays: [4],
        estimatedDuration: 50,
        estimatedCalories: 380,
        isCustom: false,
        createdAt: DateTime.now(),
      ),

      // ===== LOSE WEIGHT PLANS =====
      WorkoutModel(
        id: 'loss_hiit',
        name: 'Fat Burner: HIIT Cardio',
        muscleGroups: ['Cardio'],
        exercises: [getEx('cd4'), getEx('cd5'), getEx('cd8'), getEx('cd10'), getEx('cd2')],
        scheduledDays: [0, 2, 4],
        estimatedDuration: 35,
        estimatedCalories: 480,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'loss_fullbody',
        name: 'Fat Burner: Full Body',
        muscleGroups: ['Legs', 'Chest', 'Back'],
        exercises: [getEx('l1'), getEx('c6'), getEx('b2'), getEx('l4'), getEx('cd7')],
        scheduledDays: [1, 3, 5],
        estimatedDuration: 45,
        estimatedCalories: 420,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'loss_core_cardio',
        name: 'Fat Burner: Core & Cardio',
        muscleGroups: ['Core', 'Cardio'],
        exercises: [getEx('co5'), getEx('cd3'), getEx('co1'), getEx('cd6'), getEx('co8')],
        scheduledDays: [2, 5],
        estimatedDuration: 40,
        estimatedCalories: 390,
        isCustom: false,
        createdAt: DateTime.now(),
      ),

      // ===== MAINTAIN PLANS =====
      WorkoutModel(
        id: 'maintain_upper',
        name: 'Balanced: Upper Body',
        muscleGroups: ['Chest', 'Back', 'Arms', 'Shoulders'],
        exercises: [getEx('c1'), getEx('b3'), getEx('a1'), getEx('s2'), getEx('c4')],
        scheduledDays: [0, 3],
        estimatedDuration: 50,
        estimatedCalories: 380,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'maintain_lower',
        name: 'Balanced: Lower Body',
        muscleGroups: ['Legs', 'Core'],
        exercises: [getEx('l1'), getEx('l2'), getEx('l4'), getEx('co1'), getEx('l8')],
        scheduledDays: [1, 4],
        estimatedDuration: 50,
        estimatedCalories: 360,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'maintain_full',
        name: 'Balanced: Full Body',
        muscleGroups: ['Chest', 'Back', 'Legs', 'Core'],
        exercises: [getEx('c6'), getEx('b2'), getEx('l3'), getEx('co3'), getEx('s1')],
        scheduledDays: [2],
        estimatedDuration: 55,
        estimatedCalories: 400,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      WorkoutModel(
        id: 'maintain_cardio',
        name: 'Balanced: Active Recovery',
        muscleGroups: ['Cardio', 'Core'],
        exercises: [getEx('cd3'), getEx('co1'), getEx('cd6'), getEx('co7'), getEx('cd9')],
        scheduledDays: [5],
        estimatedDuration: 40,
        estimatedCalories: 320,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}