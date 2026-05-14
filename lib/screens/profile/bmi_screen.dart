import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../providers/auth_provider.dart';

class BMIScreen extends StatelessWidget {
  const BMIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    final bmiInfo = BMICalculator.getBMIInfo(user.bmi);
    final idealWeight = BMICalculator.getIdealWeightRange(user.height);

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
          title: Text('BMI Details', style: AppTextStyles.headingSmall),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BMI Display
                GlassCard(
                  enableGlow: true,
                  glowColor: bmiInfo['color'] as Color,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.bmi.toStringAsFixed(1),
                        style: AppTextStyles.orbitron.copyWith(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: bmiInfo['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: (bmiInfo['color'] as Color).withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (bmiInfo['category'] as String).toUpperCase(),
                          style: TextStyle(
                            color: bmiInfo['color'] as Color,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // BMI Scale
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BMI Scale', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 16),
                      _buildBmiScaleItem('Underweight', '< 18.5', AppColors.bmiUnderweight, user.bmi < 18.5),
                      _buildBmiScaleItem('Normal', '18.5 - 24.9', AppColors.bmiNormal, user.bmi >= 18.5 && user.bmi < 25),
                      _buildBmiScaleItem('Overweight', '25 - 29.9', AppColors.bmiOverweight, user.bmi >= 25 && user.bmi < 30),
                      _buildBmiScaleItem('Obese', '≥ 30', AppColors.bmiObese, user.bmi >= 30),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What this means', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 12),
                      Text(
                        bmiInfo['description'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Ideal Weight
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ideal Weight Range', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeightStat('Min', '${idealWeight['min']!.toStringAsFixed(1)} kg'),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.border,
                          ),
                          _buildWeightStat('Max', '${idealWeight['max']!.toStringAsFixed(1)} kg'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'For your height of ${user.height.toStringAsFixed(0)} cm',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Calorie Goal
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Calorie Goal', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '${user.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                          style: AppTextStyles.statNumber.copyWith(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on Harris-Benedict equation with ${user.fitnessGoal.replaceAll('_', ' ')} goal',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBmiScaleItem(String label, String range, Color color, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha:0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? color : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            range,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? color : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value) {
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
}