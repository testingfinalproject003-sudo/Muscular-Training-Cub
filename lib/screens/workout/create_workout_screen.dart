import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/animated_background.dart';
import '../../models/workout_model.dart';
import '../../models/exercise_model.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Legs', 'Arms', 'Shoulders', 'Core', 'Cardio'
  ];
  final List<String> _selectedMuscles = [];
  final List<int> _selectedDays = [];
  final List<ExerciseModel> _selectedExercises = [];
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMuscle(String muscle) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedMuscles.contains(muscle)) {
        _selectedMuscles.remove(muscle);
      } else {
        _selectedMuscles.add(muscle);
      }
    });
  }

  void _toggleDay(int day) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _addExercise(ExerciseModel exercise) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedExercises.add(exercise);
    });
    Navigator.pop(context);
  }

  void _showExercisePicker() {
    final workoutProvider = context.read<WorkoutProvider>();
    final exercises = workoutProvider.exercises;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Exercise',
                style: AppTextStyles.headingSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      onTap: () => _addExercise(exercise),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.getMuscleColor(exercise.muscleGroup),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${exercise.muscleGroup} · ${exercise.sets} sets × ${exercise.reps}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.glowColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeExercise(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) {
      _showError('Add at least one exercise');
      return;
    }

    HapticFeedback.mediumImpact();

    final totalDuration = _selectedExercises.fold<int>(
      0,
      (sum, e) => sum + ((e.duration ?? 45) * e.sets ~/ 60) + (e.sets * 60 ~/ 60),
    );

    final totalCalories = _selectedExercises.fold<double>(
      0,
      (sum, e) => sum + (e.caloriesPerMinute * ((e.duration ?? 45) * e.sets / 60)),
    );

    final workout = WorkoutModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      muscleGroups: _selectedMuscles,
      exercises: _selectedExercises,
      scheduledDays: _selectedDays..sort(),
      estimatedDuration: totalDuration,
      estimatedCalories: totalCalories,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    final authProvider = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    if (authProvider.user != null) {
      await workoutProvider.addWorkout(authProvider.user!.uid, workout);
    }

    if (!mounted) return;
    context.pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error.withValues(alpha:0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          title: Text(
            'Create Workout',
            style: AppTextStyles.headingSmall,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Workout Name',
                    hint: 'e.g., Chest Day Blast',
                    controller: _nameController,
                    validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  Text('Muscle Groups', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _muscleGroups.map((muscle) {
                      final isSelected = _selectedMuscles.contains(muscle);
                      return GestureDetector(
                        onTap: () => _toggleMuscle(muscle),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.getMuscleColor(muscle).withValues(alpha:0.3)
                                : Colors.white.withValues(alpha:0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.getMuscleColor(muscle)
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            muscle,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.getMuscleColor(muscle)
                                  : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('Schedule Days', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      final isSelected = _selectedDays.contains(index);
                      return GestureDetector(
                        onTap: () => _toggleDay(index),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentPurple.withValues(alpha:0.4)
                                : Colors.white.withValues(alpha:0.05),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.glowColor : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              days[index],
                              style: TextStyle(
                                color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Exercises', style: AppTextStyles.headingSmall),
                      TextButton.icon(
                        onPressed: _showExercisePicker,
                        icon: const Icon(Icons.add, color: AppColors.glowColor),
                        label: Text(
                          'Add',
                          style: TextStyle(color: AppColors.glowColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedExercises.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 40,
                              color: AppColors.textSecondary.withValues(alpha:0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No exercises added yet',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Add" to select exercises',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._selectedExercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.getMuscleColor(exercise.muscleGroup),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${exercise.sets} sets × ${exercise.reps}',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeExercise(index),
                                icon: const Icon(Icons.remove_circle, color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 24),
                  if (_selectedExercises.isNotEmpty) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat('Exercises', '${_selectedExercises.length}'),
                          _buildSummaryStat('Est. Duration', '~${_selectedExercises.fold<int>(0, (sum, e) => sum + ((e.duration ?? 45) * e.sets ~/ 60) + e.sets)} min'),
                          _buildSummaryStat('Est. Calories', '~${_selectedExercises.fold<double>(0, (sum, e) => sum + (e.caloriesPerMinute * ((e.duration ?? 45) * e.sets / 60))).toStringAsFixed(0)} cal'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  GradientButton(
                    text: 'SAVE WORKOUT',
                    onPressed: _saveWorkout,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.statNumber.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.statLabel,
        ),
      ],
    );
  }
}