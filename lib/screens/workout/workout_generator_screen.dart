import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';
import '../../models/ai_plan_model.dart';
import '../../core/constants/app_constants.dart';
class WorkoutGeneratorScreen extends StatefulWidget {
  const WorkoutGeneratorScreen({super.key});

  @override
  State<WorkoutGeneratorScreen> createState() => _WorkoutGeneratorScreenState();
}

class _WorkoutGeneratorScreenState extends State<WorkoutGeneratorScreen> {
  int _selectedDays = 3;
  String _selectedLevel = 'beginner';
  bool _isLoading = false;
  AIPlanModel? _generatedPlan;

  final List<int> _daysOptions = [2, 3, 4, 5, 6];
  final List<String> _levels = ['beginner', 'intermediate', 'advanced'];

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final aiService = AIService(apiKey: AppConstants.openRouterApiKey);

    try {
      // Generate AND save to Firebase
      final plan = await aiService.generateAndSaveWorkoutPlan(
        user: authProvider.user!,
        days: _selectedDays,
        level: _selectedLevel,
      );

      if (mounted) {
        setState(() {
          _generatedPlan = plan;
          _isLoading = false;
        });

        // Show success with navigation option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Plan saved! Check Home screen to accept.'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'View Home',
              textColor: Colors.white,
              onPressed: () => context.go('/home'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text('Workout Generator', style: AppTextStyles.headingSmall),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configure Plan', style: AppTextStyles.headingSmall),
                const SizedBox(height: 20),

                // Days selector
                Text('Days per week', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _daysOptions.map((days) {
                    final isSelected = _selectedDays == days;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedDays = days);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentPurple.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.glowColor : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$days',
                            style: TextStyle(
                              color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Level selector
                Text('Fitness Level', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 12),
                ..._levels.map((level) {
                  final isSelected = _selectedLevel == level;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedLevel = level);
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: isSelected
                            ? AppColors.glowColor.withValues(alpha: 0.5)
                            : AppColors.border,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                                  width: 2,
                                ),
                                color: isSelected ? AppColors.glowColor : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level[0].toUpperCase() + level.substring(1),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    level == 'beginner'
                                        ? 'New to fitness, building foundation'
                                        : level == 'intermediate'
                                            ? 'Regular training, moderate intensity'
                                            : 'Experienced, high intensity training',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                GradientButton(
                  text: 'GENERATE & SAVE PLAN',
                  isLoading: _isLoading,
                  onPressed: _generatePlan,
                ),
                const SizedBox(height: 24),

                // Preview generated plan with Markdown
                if (_generatedPlan != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Preview', style: AppTextStyles.headingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PENDING',
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
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: MarkdownBody(
                      data: _generatedPlan!.content,
                      styleSheet: MarkdownStyleSheet(
                        h1: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
                        h2: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
                        p: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                        listBullet: AppTextStyles.bodyLarge.copyWith(color: AppColors.glowColor),
                        tableHead: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.glowColor,
                        ),
                        tableBody: AppTextStyles.bodyMedium,
                        blockquote: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '👉 Go to Home screen to Accept or Decline this plan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.glowColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}