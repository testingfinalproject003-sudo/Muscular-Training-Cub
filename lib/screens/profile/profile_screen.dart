import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Profile', style: AppTextStyles.headingSmall),
          actions: [
            IconButton(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit, color: AppColors.glowColor),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar & Name
                GlassCard(
                  enableGlow: true,
                  glowColor: AppColors.accentPurple,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPurple, AppColors.accentViolet],
                          ),
                          border: Border.all(
                            color: AppColors.glowColor.withValues(alpha:0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.glowColor.withValues(alpha:0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: AppTextStyles.orbitron.copyWith(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: AppTextStyles.headingMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.getBmiColor(user.bmiCategory).withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.getBmiColor(user.bmiCategory).withValues(alpha:0.5),
                          ),
                        ),
                        child: Text(
                          user.fitnessGoal.toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                            color: AppColors.getBmiColor(user.bmiCategory),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '${progressProvider.totalWorkouts}',
                        'Workouts',
                        Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '${progressProvider.totalWorkoutMinutes}',
                        'Minutes',
                        Icons.timer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '(${progressProvider.totalCaloriesBurned.round().toString()})',
                        'Calories',
                        Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // BMI Card
                GestureDetector(
                  onTap: () => context.push('/bmi'),
                  child: GlassCard(
                    enableGlow: true,
                    glowColor: AppColors.getBmiColor(user.bmiCategory),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('BMI', style: AppTextStyles.headingSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.getBmiColor(user.bmiCategory).withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.bmiCategory.toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.getBmiColor(user.bmiCategory),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.bmi.toStringAsFixed(1),
                          style: AppTextStyles.orbitron.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getBmiColor(user.bmiCategory),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Body Mass Index',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Tap for details',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Calorie Tracker
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Calorie Goal', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: 0.65,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withValues(alpha:0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '65%',
                                        style: AppTextStyles.statNumber.copyWith(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Daily Goal',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '342 / ${user.dailyCalorieGoal.toStringAsFixed(0)} burned today',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text('Quick Actions', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                _buildActionTile(
                  Icons.insert_chart,
                  'View Charts',
                  () => context.push('/charts'),
                ),
                const SizedBox(height: 8),
                _buildActionTile(
                  Icons.smart_toy,
                  'AI Coach',
                  () => context.push('/ai-coach'),
                ),
                const SizedBox(height: 8),
                _buildActionTile(
                  Icons.restaurant_menu,
                  'Diet Plan',
                  () => context.push('/diet'),
                ),
                const SizedBox(height: 24),

                // Logout
                GradientButton(
                  text: 'LOGOUT',
                  gradientColors: [AppColors.error.withValues(alpha:0.8), AppColors.error],
                  onPressed: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.glowColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.statNumber.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.statLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return GlassCard(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.glowColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.error),
        ),
        title: Text(
          'Logout?',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}