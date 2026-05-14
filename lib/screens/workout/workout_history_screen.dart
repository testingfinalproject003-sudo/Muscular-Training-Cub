import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<ProgressProvider>().loadProgressData(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final workoutLogs = progressProvider.workoutLogs;

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
          title: Text('Workout History', style: AppTextStyles.headingSmall),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.glowColor,
            backgroundColor: AppColors.secondaryBackground,
            child: workoutLogs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: workoutLogs.length,
                    itemBuilder: (context, index) {
                      final log = workoutLogs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                          DateFormat('MMM dd, yyyy · HH:mm').format(log.date),
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'DONE',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildHistoryStat(
                                    Icons.timer,
                                    _formatDuration(log.duration),
                                    'Duration',
                                  ),
                                  _buildHistoryStat(
                                    Icons.fitness_center,
                                    '${log.setsCompleted}',
                                    'Sets',
                                  ),
                                  _buildHistoryStat(
                                    Icons.local_fire_department,
                                    '(${log.caloriesBurned.toStringAsFixed(0)})',
                                    'Calories',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.accentViolet),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.statNumber.copyWith(fontSize: 16),
        ),
        Text(
          label,
          style: AppTextStyles.statLabel,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Workouts Yet',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first workout to see history here!',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Start Workout'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}m ${secs}s';
  }
}