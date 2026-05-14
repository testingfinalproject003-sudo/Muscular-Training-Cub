import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../models/ai_plan_model.dart';
import '../../../models/workout_model.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final workoutProvider = context.watch<WorkoutProvider>();
    
    if (user == null) return const Center(child: CircularProgressIndicator());

    // Get prebuilt plans by category
    final gainPlans = workoutProvider.getPrebuiltPlansByGoal('gain');
    final lossPlans = workoutProvider.getPrebuiltPlansByGoal('loss');
    final maintainPlans = workoutProvider.getPrebuiltPlansByGoal('maintain');
    
    // Get today's workout
    final todayIndex = DateTime.now().weekday - 1;
    final todayWorkouts = workoutProvider.getWorkoutsForDay(todayIndex);

    return StreamBuilder<QuerySnapshot>(
      // AI Plans query - no orderBy to avoid index requirement
      stream: FirebaseFirestore.instance
          .collection('ai_plans')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'accepted'])
          .snapshots(),
      builder: (context, snapshot) {
        // Sort AI plans client-side
        List<AIPlanModel> aiPlans = [];
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          docs.sort((a, b) {
            final aDate = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bDate = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            return bDate.compareTo(aDate);
          });
          aiPlans = docs.map((doc) => AIPlanModel.fromFirestore(doc)).toList();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Welcome, ${user.name}',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Let\'s crush your goals today!',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Today's Workout Card
              if (todayWorkouts.isNotEmpty) ...[
                _buildSectionHeader('Today\'s Workout', Icons.today),
                const SizedBox(height: 12),
                _buildTodayWorkoutCard(context, todayWorkouts.first),
                const SizedBox(height: 24),
              ],

              // AI Plans Section
              if (aiPlans.isNotEmpty) ...[
                _buildSectionHeader('Your AI Plans', Icons.auto_awesome),
                const SizedBox(height: 12),
                ...aiPlans.map((plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(plan: plan),
                )),
                const SizedBox(height: 24),
              ] else if (snapshot.connectionState == ConnectionState.waiting) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 24),
              ],

              // Gain Muscle Plans
              if (gainPlans.isNotEmpty) ...[
                _buildSectionHeader('Gain Muscle', Icons.fitness_center, AppColors.chestColor),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: gainPlans.length,
                    itemBuilder: (context, index) {
                      return _buildPrebuiltPlanCard(context, gainPlans[index]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Lose Weight Plans
              if (lossPlans.isNotEmpty) ...[
                _buildSectionHeader('Lose Weight', Icons.local_fire_department, AppColors.warning),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: lossPlans.length,
                    itemBuilder: (context, index) {
                      return _buildPrebuiltPlanCard(context, lossPlans[index]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Maintain Plans
              if (maintainPlans.isNotEmpty) ...[
                _buildSectionHeader('Maintain', Icons.balance, AppColors.success),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: maintainPlans.length,
                    itemBuilder: (context, index) {
                      return _buildPrebuiltPlanCard(context, maintainPlans[index]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // No Plans Empty State
              if (aiPlans.isEmpty && gainPlans.isEmpty && lossPlans.isEmpty && maintainPlans.isEmpty)
                _buildEmptyState(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, [Color? color]) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.glowColor, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.headingSmall,
        ),
      ],
    );
  }

  Widget _buildTodayWorkoutCard(BuildContext context, WorkoutModel workout) {
    return GlassCard(
      enableGlow: true,
      glowColor: AppColors.accentPurple,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  workout.name,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.glowColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SCHEDULED',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(Icons.fitness_center, '${workout.exercises.length} exercises'),
              const SizedBox(width: 12),
              _buildStatChip(Icons.timer, '${workout.estimatedDuration} min'),
              const SizedBox(width: 12),
              _buildStatChip(Icons.local_fire_department, '${workout.estimatedCalories.toStringAsFixed(0)} cal'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/active-workout/${workout.id}'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('START NOW'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
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
Widget _buildPrebuiltPlanCard(BuildContext context, WorkoutModel workout) {
  final color = AppColors.getMuscleColor(
    workout.muscleGroups.isNotEmpty ? workout.muscleGroups.first : 'chest'
  );
  
  return GestureDetector(
    onTap: () => context.push('/workout/${workout.id}'),
    child: Container(
      width: 280, // Thoda bada card for exercises
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        enableGlow: true,
        glowColor: color,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Name
            Text(
              workout.name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Stats
            Row(
              children: [
                Icon(Icons.fitness_center, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${workout.exercises.length} exercises', 
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                const SizedBox(width: 8),
                Icon(Icons.timer, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${workout.estimatedDuration}m', 
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),
            // Exercises List with Images!
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            exercise.displayImageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 50,
                              height: 50,
                              color: color.withValues(alpha: 0.2),
                              child: Icon(Icons.fitness_center, size: 20, color: color),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.name,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No plans yet',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Generate an AI plan or explore prebuilt workouts!',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {}, // Navigate to workout generator
            icon: const Icon(Icons.add),
            label: const Text('Generate Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final AIPlanModel plan;
  const _PlanCard({required this.plan});

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _expanded = false;

  Future<void> _updateStatus(PlanStatus status) async {
    try {
      await FirebaseFirestore.instance
          .collection('ai_plans')
          .doc(widget.plan.id)
          .update({
        'status': status.name,
        if (status == PlanStatus.accepted) 'acceptedAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == PlanStatus.accepted 
                ? '✅ Plan accepted!' 
                : '❌ Plan declined'),
            backgroundColor: status == PlanStatus.accepted 
                ? AppColors.success 
                : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.plan.status == PlanStatus.pending;

    return GlassCard(
      enableGlow: widget.plan.status == PlanStatus.accepted,
      glowColor: widget.plan.status == PlanStatus.accepted 
          ? AppColors.success 
          : AppColors.warning,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                widget.plan.type == PlanType.workout 
                    ? Icons.fitness_center 
                    : Icons.restaurant_menu,
                color: widget.plan.type == PlanType.workout 
                    ? AppColors.accentPurple 
                    : AppColors.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.title,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      widget.plan.statusLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: widget.plan.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Content Preview
          if (!_expanded)
            Text(
              '${widget.plan.content.substring(
                0, 
                widget.plan.content.length > 100 ? 100 : widget.plan.content.length,
              )}...',
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            MarkdownBody(
              data: widget.plan.content,
              styleSheet: MarkdownStyleSheet(
                h1: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
                h2: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                p: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                listBullet: AppTextStyles.bodyMedium.copyWith(color: AppColors.glowColor),
              ),
            ),

          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Show Less' : 'Read More'),
          ),

          // Action Buttons
          if (isPending) ...[
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(PlanStatus.accepted),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success.withValues(alpha: 0.2),
                      foregroundColor: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(PlanStatus.rejected),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}