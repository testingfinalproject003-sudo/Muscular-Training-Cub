import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
// import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/ai_service.dart';
import '../../services/firestore_service.dart';
// import '../../models/workout_model.dart';
import '../home/widgets/daily_tip_card.dart';
import '../home/widgets/today_workout_card.dart';
// import '../home/widgets/streak_widget.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  int _selectedDay = DateTime.now().weekday - 1;
  String _dailyTip = '';
  bool _isLoadingTip = true;
  int _waterCups = 0;
  int _waterMl = 0;
  final int _cupSize = 250;
  final int _waterGoal = 2000;
  String _selectedPlanCategory = 'All';
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _planCategories = ['All', 'Gain Muscle', 'Lose Weight', 'Maintain'];

  @override
  void initState() {
    super.initState();
    _loadDailyTip();
    _loadWorkouts();
    _loadWaterFromFirestore();
  }

  Future<void> _loadWaterFromFirestore() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      final dateStr = DateTime.now().toIso8601String().split('T').first;
      final firestoreService = FirestoreService();
      firestoreService.streamWaterLog(authProvider.user!.uid, dateStr).listen((data) {
        if (data != null && mounted) {
          setState(() {
            _waterCups = data['cups'] ?? 0;
            _waterMl = data['ml'] ?? 0;
          });
        }
      });
    }
  }

  Future<void> _loadDailyTip() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      try {
        final aiService = AIService(apiKey: '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');
        final tip = await aiService.getDailyTip(authProvider.user!);
        if (mounted) {
          setState(() {
            _dailyTip = tip;
            _isLoadingTip = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _dailyTip = 'Consistency is key! Show up every day and the results will follow.';
            _isLoadingTip = false;
          });
        }
      }
    }
  }

  void _loadWorkouts() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<WorkoutProvider>().loadWorkouts(authProvider.user!.uid);
    }
  }

  void _toggleWaterCup(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (index < _waterCups) {
        _waterCups = index;
      } else {
        _waterCups = index + 1;
      }
      _waterMl = _waterCups * _cupSize;
    });
    _saveWaterToFirestore();
  }

  Future<void> _saveWaterToFirestore() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      final firestoreService = FirestoreService();
      final dateStr = DateTime.now().toIso8601String().split('T').first;
      await firestoreService.updateWaterLog(
        authProvider.user!.uid,
        dateStr,
        _waterCups,
        _waterMl,
      );
    }
  }

  Future<void> _deleteWorkout(String workoutId) async {
    final authProvider = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    if (authProvider.user != null) {
      await workoutProvider.deleteWorkout(authProvider.user!.uid, workoutId);
    }
  }

  void _showDeleteConfirm(String workoutId, String workoutName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.error),
        ),
        title: Text('Delete Workout?', style: AppTextStyles.headingSmall.copyWith(color: AppColors.error)),
        content: Text('Delete "$workoutName"? This cannot be undone.', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWorkout(workoutId);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final user = authProvider.user;

    final todayWorkouts = workoutProvider.getWorkoutsForDay(_selectedDay);
    final greeting = _getGreeting();

    
    return AnimatedBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadWorkouts();
            await _loadDailyTip();
          },
          color: AppColors.glowColor,
          backgroundColor: AppColors.secondaryBackground,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.accentPurple, AppColors.accentViolet],
                              ),
                              border: Border.all(
                                color: AppColors.glowColor.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting,',
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                user?.name.split(' ').first ?? 'Athlete',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Calories',
                        progressProvider.totalCaloriesBurned.round().toString(),
                        '/${user?.dailyCalorieGoal.toStringAsFixed(0) ?? '2000'}',
                        Icons.local_fire_department,
                        AppColors.warning,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Workouts',
                        progressProvider.totalWorkouts.toString(),
                        '/7 weekly',
                        Icons.fitness_center,
                        AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Streak',
                        '${user?.currentStreak ?? 0}',
                        'days',
                        Icons.local_fire_department,
                        AppColors.glowColor,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              ),

              // Today's Workout
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TodayWorkoutCard(
                    workout: todayWorkouts.isNotEmpty ? todayWorkouts.first : null,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
              ),

              // Horizontal Weekly Schedule
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly Schedule', style: AppTextStyles.headingMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedDay == index;
                            final isToday = DateTime.now().weekday - 1 == index;
                            final dayWorkouts = workoutProvider.getWorkoutsForDay(index);

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedDay = index);
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accentPurple.withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.glowColor
                                        : isToday
                                            ? AppColors.glowColor.withValues(alpha: 0.5)
                                            : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _days[index],
                                      style: TextStyle(
                                        color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (dayWorkouts.isNotEmpty)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.getMuscleColor(dayWorkouts.first.muscleGroups.isNotEmpty ? dayWorkouts.first.muscleGroups.first : 'chest'),
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${dayWorkouts.length}',
                                      style: TextStyle(
                                        color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                                        fontSize: 12,
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
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              ),

              // Plan Category Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prebuilt Plans', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _planCategories.length,
                          itemBuilder: (context, index) {
                            final category = _planCategories[index];
                            final isSelected = _selectedPlanCategory == category;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedPlanCategory = category);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
              ),

              // Workouts List for Selected Day
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_days[_selectedDay]} Workouts',
                        style: AppTextStyles.headingSmall,
                      ),
                      const SizedBox(height: 16),
                      if (todayWorkouts.isEmpty)
                        _buildEmptyState('No workouts for ${_days[_selectedDay]}')
                      else
                        ...todayWorkouts.map((workout) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () => context.push('/workout/${workout.id}'),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.getMuscleColor(
                                      workout.muscleGroups.isNotEmpty
                                          ? workout.muscleGroups.first
                                          : 'chest',
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout.name,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workout.exercises.length} exercises · ${workout.estimatedDuration} min · ${workout.estimatedCalories.toStringAsFixed(0)} cal',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!workout.id.startsWith('gain_') && !workout.id.startsWith('loss_') && !workout.id.startsWith('maintain_'))
                                  IconButton(
                                    onPressed: () => _showDeleteConfirm(workout.id, workout.name),
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  )
                                else
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                              ],
                            ),
                          ),
                        )),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
              ),

              // Water Tracker
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildWaterTracker(),
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              ),

              // AI Daily Tip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DailyTipCard(
                    tip: _dailyTip,
                    isLoading: _isLoadingTip,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: AppTextStyles.headingSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildQuickAction(
                            Icons.add_circle,
                            'Create\nWorkout',
                            () => context.push('/create-workout'),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickAction(
                            Icons.library_books,
                            'Exercise\nLibrary',
                            () => context.push('/home/library'),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickAction(
                            Icons.trending_up,
                            'View\nProgress',
                            () => context.push('/home/progress'),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickAction(
                            Icons.smart_toy,
                            'AI\nCoach',
                            () => context.push('/ai-coach'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String sub, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.statLabel,
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: value,
                style: AppTextStyles.statNumber.copyWith(fontSize: 22),
                children: [
                  TextSpan(
                    text: ' $sub',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTracker() {
    final progress = _waterMl / _waterGoal;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Intake',
                style: AppTextStyles.headingSmall,
              ),
              Text(
                '$_waterMl / $_waterGoal ml',
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(8, (index) {
              final isFilled = index < _waterCups;
              return GestureDetector(
                onTap: () => _toggleWaterCup(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? Colors.cyan.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isFilled ? Colors.cyan : AppColors.border,
                      width: isFilled ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: isFilled ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.water_drop,
                        size: 20,
                        color: isFilled ? Colors.cyan : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: AppColors.glowColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a workout or select a prebuilt plan!',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}