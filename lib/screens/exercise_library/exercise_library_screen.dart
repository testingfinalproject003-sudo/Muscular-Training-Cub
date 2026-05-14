import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _selectedMuscle = 'All';
  final List<String> _muscleGroups = [
    'All', 'Chest', 'Back', 'Legs', 'Arms', 'Shoulders', 'Core', 'Cardio'
  ];

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final exercises = _selectedMuscle == 'All'
        ? workoutProvider.exercises
        : workoutProvider.getExercisesByMuscleGroup(_selectedMuscle);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Exercise Library',
            style: AppTextStyles.headingSmall,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Muscle Group Filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _muscleGroups.length,
                  itemBuilder: (context, index) {
                    final muscle = _muscleGroups[index];
                    final isSelected = _selectedMuscle == muscle;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedMuscle = muscle);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentPurple.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.glowColor : AppColors.border,
                            ),
                          ),
                          child: Text(
                            muscle,
                            style: TextStyle(
                              color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Exercise Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${exercises.length} Exercises',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Exercise Grid with REAL Images
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return GestureDetector(
                      onTap: () => context.push('/exercise/${exercise.id}'),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // REAL Exercise Image from Network
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      exercise.displayImageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.2),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
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
                                              size: 48,
                                              color: AppColors.getMuscleColor(exercise.muscleGroup),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Gradient overlay for better text readability
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Quick Add Button (top right)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _showAddToWorkoutDialog(context, exercise),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentPurple.withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Info Area
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        exercise.muscleGroup.toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.getMuscleColor(exercise.muscleGroup),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.fitness_center, size: 12, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${exercise.sets}x${exercise.reps}',
                                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                                        ),
                                        const SizedBox(width: 8),
                                        ...List.generate(5, (i) {
                                          return Icon(
                                            i < exercise.difficulty ? Icons.star : Icons.star_border,
                                            size: 10,
                                            color: i < exercise.difficulty
                                                ? AppColors.warning
                                                : AppColors.textSecondary.withValues(alpha: 0.3),
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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