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

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final workout = workoutProvider.workouts.firstWhere(
      (w) => w.id == workoutId,
      orElse: () => workoutProvider.workouts.isNotEmpty
          ? workoutProvider.workouts.first
          : throw Exception('Workout not found'),
    );

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
            workout.name,
            style: AppTextStyles.headingSmall,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Exercises', '${workout.exercises.length}'),
                      _buildDivider(),
                      _buildStat('Duration', '${workout.estimatedDuration} min'),
                      _buildDivider(),
                      _buildStat('Calories', '(${workout.estimatedCalories.toStringAsFixed(0)})'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Muscle Groups
                Text(
                  'Muscle Groups',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: workout.muscleGroups.map((muscle) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.getMuscleColor(muscle).withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.getMuscleColor(muscle).withValues(alpha:0.5),
                        ),
                      ),
                      child: Text(
                        muscle.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.getMuscleColor(muscle),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Exercises
                Text(
                  'Exercises',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 16),
                ...workout.exercises.asMap().entries.map((entry) {
  final index = entry.key;
  final exercise = entry.value;
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // REAL IMAGE HERE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              exercise.displayImageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AppColors.getMuscleColor(exercise.muscleGroup),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
                  '${exercise.sets} sets × ${exercise.reps}${exercise.duration != null ? ' · ${exercise.duration}s' : ''}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/exercise/${exercise.id}'),
            icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}),
                
                const SizedBox(height: 24),
                GradientButton(
                  text: 'START WORKOUT',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.push('/active-workout/$workoutId');
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.statNumber.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.statLabel,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }
}