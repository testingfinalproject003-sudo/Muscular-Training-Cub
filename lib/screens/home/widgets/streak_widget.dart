import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';

class StreakWidget extends StatelessWidget {
  final int streak;
  final int maxStreak;

  const StreakWidget({
    super.key,
    required this.streak,
    this.maxStreak = 7,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.warning,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '$streak Day Streak',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(maxStreak, (index) {
              final isActive = index < streak;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.warning
                        : Colors.white.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.warning.withValues(alpha:0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            streak >= maxStreak
                ? 'Amazing! You\'re on fire! Keep it up!'
                : '${maxStreak - streak} more days to complete the week!',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}