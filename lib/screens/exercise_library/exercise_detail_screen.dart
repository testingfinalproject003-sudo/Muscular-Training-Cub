import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final exercise = workoutProvider.getExerciseById(exerciseId);

    if (exercise == null) {
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
          ),
          body: const Center(child: Text('Exercise not found')),
        ),
      );
    }

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
            exercise.name,
            style: AppTextStyles.headingSmall,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card with REAL Image
                GlassCard(
                  enableGlow: true,
                  glowColor: AppColors.getMuscleColor(exercise.muscleGroup),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // REAL Exercise Image
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.getMuscleColor(exercise.muscleGroup),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Image.network(
                            exercise.displayImageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.2),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.glowColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.2),
                                child: Center(
                                  child: Icon(
                                    _getExerciseIcon(exercise.muscleGroup),
                                    size: 80,
                                    color: AppColors.getMuscleColor(exercise.muscleGroup),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        exercise.name,
                        style: AppTextStyles.headingMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          exercise.muscleGroup.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.getMuscleColor(exercise.muscleGroup),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Sets', '${exercise.sets}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Reps', exercise.reps),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Cal/min', exercise.caloriesPerMinute.toStringAsFixed(0)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Difficulty
                Text('Difficulty Level', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < exercise.difficulty ? Icons.star : Icons.star_border,
                          size: 32,
                          color: index < exercise.difficulty
                              ? AppColors.warning
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text('Description', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    exercise.description,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Muscle
                Text('Primary Muscle', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.getMuscleColor(exercise.muscleGroup),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        exercise.primaryMuscle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tips
                Text('Pro Tips', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb,
                          color: AppColors.warning,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          exercise.tips,
                          style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // START EXERCISE Button (NEW - starts single exercise)
                GradientButton(
                  text: 'START EXERCISE',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _startSingleExercise(context, exercise);
                  },
                ),
                const SizedBox(height: 12),

                // Add to Workout Button
                GradientButton(
                  text: 'ADD TO WORKOUT',
                  gradientColors: [AppColors.accentViolet, AppColors.accentPurple],
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showAddToWorkoutDialog(context, exercise);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startSingleExercise(BuildContext context, exercise) {
    // Create a temporary workout with just this exercise
    // Navigate to active workout with this single exercise
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Start Exercise', style: AppTextStyles.headingSmall),
        content: Text(
          'Start ${exercise.name}?\\n\\nSets: ${exercise.sets}\\nReps: ${exercise.reps}',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to active workout with a temporary single-exercise workout
              context.push('/active-workout/single_${exercise.id}');
            },
            child: Text('Start', style: TextStyle(color: AppColors.glowColor)),
          ),
        ],
      ),
    );
  }

  void _showAddToWorkoutDialog(BuildContext context, exercise) {
    final workoutProvider = context.read<WorkoutProvider>();
    final authProvider = context.read<AuthProvider>();
    final userWorkouts = workoutProvider.workouts.where((w) =>
      !w.id.startsWith('gain_') && !w.id.startsWith('loss_') && !w.id.startsWith('maintain_')
    ).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Add to Workout',
                style: AppTextStyles.headingSmall,
              ),
            ),
            if (userWorkouts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'No custom workouts yet. Create one first!',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/create-workout');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                      ),
                      child: const Text('Create Workout'),
                    ),
                  ],
                ),
              )
            else
              ...userWorkouts.map((workout) => ListTile(
                leading: Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.getMuscleColor(workout.muscleGroups.isNotEmpty ? workout.muscleGroups.first : 'chest'),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                title: Text(workout.name, style: AppTextStyles.bodyLarge),
                subtitle: Text('${workout.exercises.length} exercises', style: AppTextStyles.bodySmall),
                onTap: () async {
                  Navigator.pop(context);
                  if (authProvider.user != null) {
                    await workoutProvider.addExerciseToWorkout(
                      authProvider.user!.uid,
                      workout.id,
                      exercise,
                    );
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${exercise.name} to ${workout.name}'),
                        backgroundColor: AppColors.success.withValues(alpha: 0.9),
                      ),
                    );
                  }
                },
              )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.statNumber.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.statLabel,
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(String muscleGroup) {
    switch (muscleGroup) {
      case 'Chest': return Icons.fitness_center;
      case 'Back': return Icons.arrow_upward;
      case 'Legs': return Icons.directions_walk;
      case 'Arms': return Icons.sports_martial_arts;
      case 'Shoulders': return Icons.accessibility_new;
      case 'Core': return Icons.circle;
      case 'Cardio': return Icons.directions_run;
      default: return Icons.fitness_center;
    }
  }
}