import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/workout_model.dart';
import '../../models/exercise_model.dart';
import '../../models/workout_log_model.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/utils/calorie_calculator.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({super.key, required this.workoutId});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with TickerProviderStateMixin {
  late WorkoutModel _workout;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _repCount = 0;
  int _workoutDuration = 0; // total seconds
  int _exerciseTimer = 0;   // per-exercise countdown (5 min = 300s default)
  int _restTimer = 0;
  bool _isResting = false;
  bool _isPaused = false;
  double _totalCalories = 0;
  
  // Exercise completion tracking
 final  List<Map<String, dynamic>> _completedSets = []; // [{exerciseIndex, set, reps, duration}]
  
  Timer? _workoutTimer;
  Timer? _countdownTimer;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Constants
  static const int defaultExerciseTime = 300; // 5 minutes = 300 seconds
  static const int defaultRestTime = 60;      // 60 seconds rest

  @override
  void initState() {
    super.initState();
    _loadWorkout();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
    
    _startWorkoutTimer();
  }

  void _loadWorkout() {
    final workoutProvider = context.read<WorkoutProvider>();
    
    // Check if it's a single exercise workout (from Exercise Detail)
    if (widget.workoutId.startsWith('single_')) {
      final exerciseId = widget.workoutId.replaceFirst('single_', '');
      final exercise = workoutProvider.getExerciseById(exerciseId);
      if (exercise != null) {
        _workout = WorkoutModel(
          id: widget.workoutId,
          name: exercise.name,
          muscleGroups: [exercise.muscleGroup],
          exercises: [exercise],
          scheduledDays: [],
          estimatedDuration: 15,
          estimatedCalories: exercise.caloriesPerMinute * 15,
          createdAt: DateTime.now(),
        );
        _exerciseTimer = exercise.duration ?? defaultExerciseTime;
        _repCount = int.tryParse(exercise.reps.split('-').first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
      } else {
        _workout = _createDemoWorkout();
      }
    } else {
      _workout = workoutProvider.workouts.firstWhere(
        (w) => w.id == widget.workoutId,
        orElse: () => workoutProvider.workouts.isNotEmpty
            ? workoutProvider.workouts.first
            : _createDemoWorkout(),
      );
      _exerciseTimer = _workout.exercises.first.duration ?? defaultExerciseTime;
      _repCount = int.tryParse(_workout.exercises.first.reps.split('-').first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
    }
  }

  WorkoutModel _createDemoWorkout() {
    return WorkoutModel(
      id: 'demo',
      name: 'Quick Workout',
      muscleGroups: ['Chest'],
      exercises: [
        ExerciseModel(
          id: 'c1',
          name: 'Push-Up',
          muscleGroup: 'Chest',
          primaryMuscle: 'Pectoralis Major',
          sets: 3,
          reps: '15',
          caloriesPerMinute: 7,
          difficulty: 2,
          description: 'Classic push-up',
          tips: 'Keep core tight',
        ),
      ],
      scheduledDays: [],
      estimatedDuration: 15,
      estimatedCalories: 100,
      createdAt: DateTime.now(),
    );
  }

  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isResting) {
        setState(() {
          _workoutDuration++;
          if (_exerciseTimer > 0) {
            _exerciseTimer--;
          }
          _calculateCalories();
        });
        
        // Auto-complete set when timer reaches 0 (for timed exercises)
        if (_exerciseTimer == 0 && _currentExercise.duration != null) {
          _completeSet();
        }
      }
    });
  }

  void _calculateCalories() {
    final authProvider = context.read<AuthProvider>();
    final weight = authProvider.user?.weight ?? 70;
    final met = CalorieCalculator.getMETValue(_currentExercise.muscleGroup == 'Cardio' ? 'cardio' : 'weight_training');
    _totalCalories = CalorieCalculator.calculateCaloriesBurned(weight, met, _workoutDuration / 60);
  }

  void _startRestTimer() {
    _restTimer = defaultRestTime;
    _isResting = true;
    
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_restTimer > 0) {
            _restTimer--;
          } else {
            _isResting = false;
            timer.cancel();
            _nextSet();
          }
        });
      }
    });
  }

  void _completeSet() {
    HapticFeedback.mediumImpact();
    
    // Save this set's data
    _completedSets.add({
      'exerciseIndex': _currentExerciseIndex,
      'exerciseName': _currentExercise.name,
      'set': _currentSet,
      'reps': _repCount,
      'duration': _currentExercise.duration ?? defaultExerciseTime,
    });
    
    if (_currentSet < _currentExercise.sets) {
      _startRestTimer();
    } else {
      _nextExercise();
    }
  }

  void _nextSet() {
    setState(() {
      _currentSet++;
      _isResting = false;
      _exerciseTimer = _currentExercise.duration ?? defaultExerciseTime;
    });
  }

  void _nextExercise() {
    HapticFeedback.heavyImpact();
    if (_currentExerciseIndex < _workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _isResting = false;
        _exerciseTimer = _currentExercise.duration ?? defaultExerciseTime;
        _repCount = int.tryParse(_currentExercise.reps.split('-').first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
      });
    } else {
      _finishWorkout();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSet = 1;
        _isResting = false;
        _exerciseTimer = _currentExercise.duration ?? defaultExerciseTime;
        _repCount = int.tryParse(_currentExercise.reps.split('-').first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
      });
    }
  }

  void _skipRest() {
    HapticFeedback.lightImpact();
    _countdownTimer?.cancel();
    setState(() {
      _isResting = false;
      _restTimer = 0;
    });
    _nextSet();
  }

  void _skipExercise() {
    HapticFeedback.lightImpact();
    // Mark current exercise as skipped and move to next
    _completedSets.add({
      'exerciseIndex': _currentExerciseIndex,
      'exerciseName': _currentExercise.name,
      'set': _currentSet,
      'reps': 0,
      'skipped': true,
    });
    _nextExercise();
  }

  void _finishWorkout() async {
    _workoutTimer?.cancel();
    _countdownTimer?.cancel();
    
    final authProvider = context.read<AuthProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final firestoreService = FirestoreService();
    
    // Calculate total sets completed
    final totalSetsCompleted = _completedSets.where((s) => s['skipped'] != true).length;
    
    final log = WorkoutLogModel(
      id: const Uuid().v4(),
      workoutId: _workout.id,
      workoutName: _workout.name,
      date: DateTime.now(),
      duration: _workoutDuration,
      setsCompleted: totalSetsCompleted,
      caloriesBurned: _totalCalories,
      exerciseLogs: _completedSets.map((s) => ExerciseLog(
        exerciseId: 'ex_${s['exerciseIndex']}',
        exerciseName: s['exerciseName'],
        setsCompleted: s['skipped'] == true ? 0 : 1,
        repsPerSet: s['reps'] ?? 0,
        duration: s['duration'] ?? 0,
        caloriesBurned: s['skipped'] == true ? 0 : _totalCalories / max(1, _completedSets.length),
      )).toList(),
    );
    
    // Save to Firebase
    if (authProvider.user != null) {
      await firestoreService.saveWorkoutLog(authProvider.user!.uid, log);
      // Reload progress data
      await progressProvider.loadProgressData(authProvider.user!.uid);
    }
    
    // Save weekly progress locally
    await _saveWeeklyProgress();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildWorkoutCompleteDialog(log),
    );
  }

  Future<void> _saveWeeklyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = 'week_${now.year}_${now.month}_${_getWeekNumber(now)}';
    final currentProgress = prefs.getInt(weekKey) ?? 0;
    await prefs.setInt(weekKey, currentProgress + 1);
    
    // Save completion date for streak
    final today = now.toIso8601String().split('T').first;
    await prefs.setString('last_workout_date', today);
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() => _isPaused = !_isPaused);
  }

  ExerciseModel get _currentExercise => _workout.exercises[_currentExerciseIndex];

  Color get _timerColor {
    if (_isResting) return Colors.cyan;
    if (_exerciseTimer <= 10) return AppColors.error;
    if (_exerciseTimer <= 30) return AppColors.warning;
    return AppColors.accentPurple;
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => _showQuitDialog(),
            icon: const Icon(Icons.close, color: AppColors.error),
          ),
          title: Text(
            _workout.name,
            style: AppTextStyles.headingSmall,
          ),
          actions: [
            IconButton(
              onPressed: _togglePause,
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Stats Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTopStat('Time', _formatTime(_workoutDuration)),
                      _buildTopStat('Calories', _totalCalories.toStringAsFixed(0)),
                      _buildTopStat('Set', '$_currentSet/${_currentExercise.sets}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Exercise Info with Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Exercise Image (small preview)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.getMuscleColor(_currentExercise.muscleGroup),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _currentExercise.displayImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.getMuscleColor(_currentExercise.muscleGroup).withValues(alpha: 0.2),
                            child: Icon(
                              Icons.fitness_center,
                              color: AppColors.getMuscleColor(_currentExercise.muscleGroup),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentExercise.name,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.glowColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Exercise ${_currentExerciseIndex + 1} of ${_workout.exercises.length}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Timer Circle
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isResting ? 1.0 : _pulseAnimation.value,
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: _isResting
                                    ? 1 - (_restTimer / defaultRestTime)
                                    : 1 - (_exerciseTimer / (_currentExercise.duration ?? defaultExerciseTime)),
                                strokeWidth: 8,
                                backgroundColor: Colors.white.withValues(alpha:0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isResting) ...[
                                      Text(
                                        'REST',
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Text(
                                      _isResting
                                          ? '$_restTimer'
                                          : _formatTime(_exerciseTimer),
                                      style: AppTextStyles.orbitron.copyWith(
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold,
                                        color: _timerColor,
                                      ),
                                    ),
                                    Text(
                                      _isResting
                                          ? 'seconds'
                                          : 'remaining',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Controls
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Reps display for non-timed exercises
                    if (!_isResting && _currentExercise.duration == null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRepButton(Icons.remove, () {
                            HapticFeedback.lightImpact();
                            setState(() => _repCount = max(0, _repCount - 1));
                          }),
                          const SizedBox(width: 24),
                          Column(
                            children: [
                              Text(
                                '$_repCount',
                                style: AppTextStyles.statNumber.copyWith(fontSize: 36),
                              ),
                              Text(
                                'reps',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          _buildRepButton(Icons.add, () {
                            HapticFeedback.lightImpact();
                            setState(() => _repCount++);
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    if (_isResting) ...[
                      // Skip Rest Button
                      GradientButton(
                        text: 'SKIP REST',
                        gradientColors: [Colors.cyan, Colors.blue],
                        onPressed: _skipRest,
                      ),
                    ] else ...[
                      // Complete Set Button
                      GradientButton(
                        text: 'COMPLETE SET',
                        onPressed: _completeSet,
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                          icon: const Icon(Icons.skip_previous, color: AppColors.textSecondary),
                          label: Text(
                            'Prev',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _currentExerciseIndex > 0
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondary.withValues(alpha:0.3),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _skipExercise,
                          icon: const Icon(Icons.skip_next, color: AppColors.warning),
                          label: Text(
                            'Skip',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _finishWorkout,
                          icon: const Icon(Icons.check_circle, color: AppColors.success),
                          label: Text(
                            'Finish',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Exercise Queue
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _workout.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _workout.exercises[index];
                    final isCurrent = index == _currentExerciseIndex;
                    final isDone = index < _currentExerciseIndex;
                    
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.accentPurple.withValues(alpha:0.3)
                            : isDone
                                ? AppColors.success.withValues(alpha:0.1)
                                : Colors.white.withValues(alpha:0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.glowColor
                              : isDone
                                  ? AppColors.success.withValues(alpha:0.3)
                                  : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              exercise.displayImageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.fitness_center,
                                size: 20,
                                color: isCurrent ? AppColors.glowColor : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent
                                  ? AppColors.glowColor
                                  : isDone
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.statNumber.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.statLabel,
        ),
      ],
    );
  }

  Widget _buildRepButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.accentPurple.withValues(alpha:0.3),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentViolet),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Quit Workout?',
          style: AppTextStyles.headingSmall,
        ),
        content: Text(
          'Your progress will not be saved. Are you sure?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
              style: TextStyle(color: AppColors.glowColor),
            ),
          ),
          TextButton(
            onPressed: () {
              _workoutTimer?.cancel();
              _countdownTimer?.cancel();
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              'Quit',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCompleteDialog(WorkoutLogModel log) {
    return AlertDialog(
      backgroundColor: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 64,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            'Workout Complete!',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 20),
          _buildResultStat('Duration', _formatTime(log.duration)),
          _buildResultStat('Sets', '${log.setsCompleted}'),
          _buildResultStat('Calories', '${log.caloriesBurned.toStringAsFixed(0)} kcal'),
          _buildResultStat('Exercises', '${_workout.exercises.length}'),
          const SizedBox(height: 24),
          GradientButton(
            text: 'AWESOME!',
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/home/progress');
            },
            child: Text(
              'View History',
              style: TextStyle(color: AppColors.glowColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyLarge),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.glowColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}