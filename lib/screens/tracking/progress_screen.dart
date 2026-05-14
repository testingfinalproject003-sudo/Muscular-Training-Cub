import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  double _weeklyPercentage = 0.0;
final int _weeklyGoal = 7;
  int _weeklyCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadWeeklyProgress();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<ProgressProvider>().loadProgressData(authProvider.user!.uid);
    }
  }

  Future<void> _loadWeeklyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = 'week_${now.year}_${now.month}_${_getWeekNumber(now)}';
    
    // Check if week changed - reset if needed
    final lastWeekKey = prefs.getString('last_active_week');
    if (lastWeekKey != null && lastWeekKey != weekKey) {
      // Week changed - percentage resets automatically because new weekKey
      // Old data stays in history (workoutLogs in Firebase)
    }
    await prefs.setString('last_active_week', weekKey);
    
    final completed = prefs.getInt(weekKey) ?? 0;
    setState(() {
      _weeklyCompleted = completed;
      _weeklyPercentage = (completed / _weeklyGoal).clamp(0.0, 1.0);
    });
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final user = authProvider.user;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Progress', style: AppTextStyles.headingSmall),
          actions: [
            IconButton(
              onPressed: () => context.push('/charts'),
              icon: const Icon(Icons.insert_chart, color: AppColors.glowColor),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadData();
              await _loadWeeklyProgress();
            },
            color: AppColors.glowColor,
            backgroundColor: AppColors.secondaryBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly Progress Card (Resets every week)
                  GlassCard(
                    enableGlow: true,
                    glowColor: AppColors.accentPurple,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Weekly Goal', style: AppTextStyles.headingSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accentPurple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_weeklyCompleted / $_weeklyGoal',
                                style: TextStyle(
                                  color: AppColors.glowColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: _weeklyPercentage,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _weeklyPercentage >= 1.0 ? AppColors.success : AppColors.glowColor,
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${(_weeklyPercentage * 100).toStringAsFixed(0)}%',
                                  style: AppTextStyles.statNumber.copyWith(fontSize: 24),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _weeklyPercentage >= 1.0
                              ? '🎉 Weekly goal achieved!'
                              : '${_weeklyGoal - _weeklyCompleted} more to reach your goal',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Overall Stats
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBigStat(
                          '${progressProvider.totalWorkouts}',
                          'Total\\nWorkouts',
                          Icons.fitness_center,
                          AppColors.accentPurple,
                        ),
                        _buildBigStat(
                          '${progressProvider.totalWorkoutMinutes}',
                          'Total\\nMinutes',
                          Icons.timer,
                          AppColors.accentViolet,
                        ),
                        _buildBigStat(
                          '${progressProvider.totalCaloriesBurned.round()}',
                          'Calories\\nBurned',
                          Icons.local_fire_department,
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // View History Button
                  GestureDetector(
                    onTap: () => context.push('/workout-history'),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.history, color: AppColors.success),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Workout History',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'View all completed workouts',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weight Section
                  Text('Weight Log', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  '${user?.weight.toStringAsFixed(1) ?? '--'} kg',
                                  style: AppTextStyles.statNumber.copyWith(fontSize: 28),
                                ),
                              ],
                            ),
                            if (progressProvider.weightChange != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: progressProvider.weightChange! <= 0
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : AppColors.error.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${progressProvider.weightChange! > 0 ? '+' : ''}${progressProvider.weightChange!.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    color: progressProvider.weightChange! <= 0
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (progressProvider.weightLogs.isEmpty)
                          _buildEmptyState('No weight logs yet')
                        else
                          ...progressProvider.weightLogs.take(5).map((log) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(log.date),
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    '${log.weight.toStringAsFixed(1)} kg',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Workouts
                  Text('Recent Workouts', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  if (progressProvider.workoutLogs.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: _buildEmptyState('No workouts completed yet'),
                    )
                  else
                    ...progressProvider.workoutLogs.take(5).map((log) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.accentPurple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: AppColors.glowColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.workoutName,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(log.date),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${log.caloriesBurned.toStringAsFixed(0)} cal',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.glowColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${log.duration ~/ 60} min',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTextStyles.statNumber.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.statLabel,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.show_chart,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}