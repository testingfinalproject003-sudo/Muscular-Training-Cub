import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  bool _isLoading = false;
  String _dietPlan = '';

  Future<void> _generateDiet() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final aiService = AIService(apiKey: '');

    try {
      final plan = await aiService.getDietSuggestions(authProvider.user!);
      if (mounted) {
        setState(() {
          _dietPlan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dietPlan = 'Unable to generate diet plan. Please try again later.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

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
          title: Text('AI Diet Plan', style: AppTextStyles.headingSmall),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calorie Info
                GlassCard(
                  enableGlow: true,
                  glowColor: AppColors.success,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${user?.dailyCalorieGoal.toStringAsFixed(0) ?? '2000'} kcal',
                        style: AppTextStyles.statNumber.copyWith(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daily Calorie Target',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Goal: ${user?.fitnessGoal.replaceAll('_', ' ').toUpperCase() ?? 'MAINTAIN'}',
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Macros
                Text('Suggested Macros', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroCard('Protein', '30%', Icons.egg_alt, AppColors.warning),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard('Carbs', '40%', Icons.grain, AppColors.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard('Fats', '30%', Icons.water_drop, AppColors.accentViolet),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                GradientButton(
                  text: 'GENERATE DIET PLAN',
                  isLoading: _isLoading,
                  onPressed: _generateDiet,
                ),
                const SizedBox(height: 24),

                if (_dietPlan.isNotEmpty) ...[
                  Text('Your Diet Plan', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _dietPlan,
                      style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
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

  Widget _buildMacroCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.statNumber.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.statLabel,
          ),
        ],
      ),
    );
  }
}