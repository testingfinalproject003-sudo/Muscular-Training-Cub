import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/workout_model.dart';

class TodayWorkoutCard extends StatelessWidget {
  final WorkoutModel? workout;

  const TodayWorkoutCard({
    super.key,
    this.workout,
  });

  @override
  Widget build(BuildContext context) {
    final hasWorkout = workout != null;
    
    return GlassCard(
      enableGlow: true,
      glowColor: AppColors.accentPurple,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Workout',
                style: AppTextStyles.headingSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasWorkout
                      ? AppColors.success.withValues(alpha:0.2)
                      : AppColors.warning.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasWorkout ? AppColors.success : AppColors.warning,
                    width: 1,
                  ),
                ),
                child: Text(
                  hasWorkout ? 'SCHEDULED' : 'REST DAY',
                  style: TextStyle(
                    color: hasWorkout ? AppColors.success : AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasWorkout) ...[
            Text(
              workout!.name,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.glowColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip(
                  Icons.fitness_center,
                  '${workout!.exercises.length} exercises',
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  Icons.timer,
                  '${workout!.estimatedDuration} min',
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  Icons.local_fire_department,
                  '${workout!.estimatedCalories.toStringAsFixed(0)} cal',
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'START WORKOUT',
              onPressed: () => context.push('/active-workout/${workout!.id}'),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha:0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enjoy your rest day!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recovery is just as important as training.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentViolet),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}