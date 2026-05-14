import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';

class DailyTipCard extends StatelessWidget {
  final String tip;
  final bool isLoading;

  const DailyTipCard({
    super.key,
    required this.tip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      enableGlow: true,
      glowColor: AppColors.accentViolet,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.glowColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Daily Tip',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.glowColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isLoading
              ? Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              : Text(
                  tip.isEmpty ? 'Loading your daily fitness tip...' : tip,
                  style: AppTextStyles.bodyLarge.copyWith(
                    height: 1.5,
                  ),
                ),
        ],
      ),
    );
  }
}